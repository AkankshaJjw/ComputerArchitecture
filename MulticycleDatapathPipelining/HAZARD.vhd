-- ECE 3055 Computer Architecture and Operating Systems
-- MIPS Processor VHDL Behavioral Model			
-- Top Level Structural Model for MIPS Processor Core
-- School of Electrical & Computer Engineering
-- Georgia Institute of Technology
-- Atlanta, GA 30332

--Akanksha Jhunjhunwala
--ajhunjhunwala6
--903331929
--file added to implement hazard detection unit
LIBRARY IEEE; 			
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY hazard IS
	PORT(	SIGNAL read_register_1_address		: IN STD_LOGIC_VECTOR( 4 DOWNTO 0 );
            SIGNAL read_register_2_address		: IN STD_LOGIC_VECTOR( 4 DOWNTO 0 );
            SIGNAL rd1          : IN    STD_LOGIC_VECTOR( 4 DOWNTO 0 );
            SIGNAL rd2          : IN    STD_LOGIC_VECTOR( 4 DOWNTO 0 );
            SIGNAL rd3          : IN    STD_LOGIC_VECTOR( 4 DOWNTO 0 );
            SIGNAL beq1         : IN    STD_LOGIC;
            SIGNAL beq2         : IN    STD_LOGIC;
            SIGNAL ID_EX_Rd     : IN    STD_LOGIC_VECTOR( 4 DOWNTO 0 );
            SIGNAL EX_MEM_Rd    : IN    STD_LOGIC_VECTOR( 4 DOWNTO 0 );
            SIGNAL MEM_WB_Rd    : IN    STD_LOGIC_VECTOR( 4 DOWNTO 0 );
            SIGNAL PC_plus_4 	: OUT   STD_LOGIC_VECTOR( 9 DOWNTO 0 );
            SIGNAL RegDst 		: OUT 	STD_LOGIC;
            SIGNAL ALUSrc 		: OUT 	STD_LOGIC;
            SIGNAL MemtoReg 	: OUT 	STD_LOGIC;
            SIGNAL RegWrite 	: OUT 	STD_LOGIC;
            SIGNAL MemRead 		: OUT 	STD_LOGIC;
            SIGNAL MemWrite 	: OUT 	STD_LOGIC;
            SIGNAL Branch 		: OUT 	STD_LOGIC;
            SIGNAL PCWrite 		: OUT 	STD_LOGIC;
            SIGNAL IF_IDWrite 	: OUT 	STD_LOGIC;
            SIGNAL ALUop 		: OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
            SIGNAL clock, reset	: IN 	STD_LOGIC );
END hazard;

ARCHITECTURE behavior OF hazard IS
    -- signal declaration (of internal signals rs, rt)
    SIGNAL rs, rt: STD_LOGIC_VECTOR( 4 DOWNTO 0 );

BEGIN
rs <= read_register_1_address;
rt <= read_register_1_address;
PROCESS(clock, rs, rt, rd1, rd2, rd3) --depends on these signals
           BEGIN
               IF (clock = '0' and clock'EVENT) THEN --check if any hazard condition is true
                   IF ((rs=rd1) or (rt=rd1) or (rs=rd2) or (rt=rd2) or (rs=rd3) or (rt=rd3) or (beq1 = "000100") or (beq2 = "000100")) THEN
                      PCWrite <= '0'; --stop pc+4 from updating
                      IF_IDWrite <= '0'; --stop if_id reg from getting loaded
                      --set all control bits to 0
                      RegDst    <=  '0';
                      ALUSrc  	<=  '0';
                      MemtoReg 	<=  '0';
                      RegWrite 	<=  '0';
                      MemRead 	<=  '0';
                      MemWrite 	<=  '0'; 
                      Branch    <=  '0';
                      ALUOp( 1 )<=  '0';
                      ALUOp( 0 )<=  '0';
                   ELSE
                    PCWrite <= '1'; 
                    IF_IDWrite <= '1';   
                    --copy of the logic from control
                    RegDst    	<=  R_format;
                    ALUSrc  	<=  Lw OR Sw;
                    MemtoReg 	<=  Lw;
                    RegWrite 	<=  R_format OR Lw;
                    MemRead 	<=  Lw;
                    MemWrite 	<=  Sw; 
                    Branch      <=  Beq;
                    ALUOp( 1 ) 	<=  R_format;
                    ALUOp( 0 ) 	<=  Beq;
                   END IF;
               
               END IF;               
       END PROCESS;

END behavior;