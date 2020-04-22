-- ECE 3055 Computer Architecture and Operating Systems
-- MIPS Processor VHDL Behavioral Model			
-- Top Level Structural Model for MIPS Processor Core
-- School of Electrical & Computer Engineering
-- Georgia Institute of Technology
-- Atlanta, GA 30332

--Akanksha Jhunjhunwala
--ajhunjhunwala6
--903331929
--This file represents the decode stage and has been modified to implement to load the id_ex reg

LIBRARY IEEE; 			
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Idecode IS
	  PORT(	read_data_1	: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			read_data_2	: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Instruction : IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			read_data 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			ALU_result	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			RegWrite 	: IN 	STD_LOGIC;
			MemtoReg 	: IN 	STD_LOGIC;
			RegDst 		: IN 	STD_LOGIC;
			Sign_extend : OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			clock,reset	: IN 	STD_LOGIC;
			-- the decode stage takes input if/id reg and sends output to id/ex reg
			IF_ID	    : IN   STD_LOGIC_VECTOR( 99 DOWNTO 0);
			ID_EX	    : OUT    STD_LOGIC_VECTOR( 199 DOWNTO 0));
END Idecode;


ARCHITECTURE behavior OF Idecode IS
TYPE register_file IS ARRAY ( 0 TO 31 ) OF STD_LOGIC_VECTOR( 31 DOWNTO 0 );

	SIGNAL register_array				: register_file;
	SIGNAL write_register_address 		: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL write_data					: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL read_register_1_address		: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL read_register_2_address		: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL write_register_address_1		: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL write_register_address_0		: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL Instruction_immediate_value	: STD_LOGIC_VECTOR( 15 DOWNTO 0 );

BEGIN
	read_register_1_address 	<= Instruction( 25 DOWNTO 21 );
   	read_register_2_address 	<= Instruction( 20 DOWNTO 16 );
   	write_register_address_1	<= Instruction( 15 DOWNTO 11 );
   	write_register_address_0 	<= Instruction( 20 DOWNTO 16 );
   	Instruction_immediate_value <= Instruction( 15 DOWNTO 0 );
					-- Read Register 1 Operation
	read_data_1 <= register_array( 
			      CONV_INTEGER( read_register_1_address ) );
					-- Read Register 2 Operation		 
	read_data_2 <= register_array( 
			      CONV_INTEGER( read_register_2_address ) );
					-- Mux for Register Write Address
    	write_register_address <= write_register_address_1 
			WHEN RegDst = '1'  			ELSE write_register_address_0;
					-- Mux to bypass data memory for Rformat instructions
	write_data <= ALU_result( 31 DOWNTO 0 ) 
			WHEN ( MemtoReg = '0' ) 	ELSE read_data;
					-- Sign Extend 16-bits to 32-bits
    	Sign_extend <= X"0000" & Instruction_immediate_value
		WHEN Instruction_immediate_value(15) = '0'
		ELSE	X"FFFF" & Instruction_immediate_value;

PROCESS
	BEGIN
		WAIT UNTIL clock'EVENT AND clock = '1';
		IF reset = '1' THEN
					-- Initial register values on reset are register = reg#
					-- use loop to automatically generate reset logic 
					-- for all registers
			FOR i IN 0 TO 31 LOOP
				register_array(i) <= CONV_STD_LOGIC_VECTOR( i, 32 );
 			END LOOP;
					-- Write back to register - don't write to register 0
  		ELSIF RegWrite = '1' AND write_register_address /= 0 THEN
		      register_array( CONV_INTEGER( write_register_address)) <= write_data;
		END IF;
		-- load id_ex internal register at the pos edge of the clock
		ID_EX(4 DOWNTO 0) <= Instruction( 15 DOWNTO 11 ); --rd
		ID_EX(9 DOWNTO 5) <= Instruction( 20 DOWNTO 16 ); --rt
		ID_EX(41 DOWNTO 10) <= Sign_extend; --sign extended immediate
		ID_EX(73 DOWNTO 42) <= read_data_2;
		ID_EX(105 DOWNTO 74) <= read_data_1;
		ID_EX(115 DOWNTO 106) <= IF_ID(41 DOWNTO 32); --pc+4
		--control signals
		ID_EX(116) <= ALUSrc;
		ID_EX(118 DOWNTO 117) <=ALUOp;
		ID_EX(119) <= RegDst; --ID_EX.Rd
		ID_EX(120) <= Branch; 
		ID_EX(121) <= RegWrite;
		ID_EX(122) <= MemtoReg;

		

	END PROCESS;
END behavior;


