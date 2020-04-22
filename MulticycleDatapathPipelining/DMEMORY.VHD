-- ECE 3055 Computer Architecture and Operating Systems
-- MIPS Processor VHDL Behavioral Model			
-- Top Level Structural Model for MIPS Processor Core
-- School of Electrical & Computer Engineering
-- Georgia Institute of Technology
-- Atlanta, GA 30332

--Akanksha Jhunjhunwala
--ajhunjhunwala6
--903331929
--This file represents the decode stage and has been modified to implement to load the ex_mem reg
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;

ENTITY dmemory IS
	PORT(	read_data 			 : OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        	address 			    : IN 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
        	write_data 			 : IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	   	MemRead, Memwrite  : IN 	STD_LOGIC;
         clock,reset		  	 : IN 	STD_LOGIC;
         -- the memory stage takes input from em/mem reg and sends output to mem/wb reg
         EX_MEM	        : IN    STD_LOGIC_VECTOR( 199 DOWNTO 0);
			MEM_WB	        : OUT   STD_LOGIC_VECTOR( 199 DOWNTO 0));
END dmemory;

ARCHITECTURE behavior OF dmemory IS 
   TYPE DATA_RAM IS ARRAY (0 to 31) OF STD_LOGIC_VECTOR (7 DOWNTO 0);
   SIGNAL ram: DATA_RAM := (
      X"55",
      X"55",
      X"55",
      X"55",
      X"AA",
      X"AA",
      X"AA",
      X"AA",
      X"00",
      X"00",
      X"00",
      X"00",
      X"00",
      X"00",
      X"00",
      X"00",
      X"00",
      X"00",
      X"00",
      X"00",
      X"00",
      X"00",
      X"00",
      X"00",
      X"00",
      X"00",
      X"00",
      X"00",
      X"00",
      X"00",
      X"00",
      X"00"
   );
   BEGIN
       PROCESS(clock, MemRead, Memwrite, address)
           BEGIN
               IF (clock = '0' and clock'EVENT) THEN
                   IF (MemRead = '1') THEN
                      read_data (7 DOWNTO 0) <= ram(CONV_INTEGER(address));
                      read_data (15 DOWNTO 8) <= ram(CONV_INTEGER(address+1));
                      read_data (23 DOWNTO 16) <= ram(CONV_INTEGER(address+2));
                      read_data (31 DOWNTO 24) <= ram(CONV_INTEGER(address+3));
                   ELSIF (Memwrite = '1') THEN
                      ram(CONV_INTEGER(address)) <= write_data (7 DOWNTO 0);
                      ram(CONV_INTEGER(address+1)) <= write_data (15 DOWNTO 8);
                      ram(CONV_INTEGER(address+2)) <= write_data (23 DOWNTO 16);
                      ram(CONV_INTEGER(address+3)) <= write_data (31 DOWNTO 24);   
                   END IF;
               -- load the mem_wb reg at the pos edge of the clock
               MEM_WB(31 DOWNTO 0) <= address;
               MEM_WB(63 DOWNTO 32) <= read_data;
               MEM_WB(64) <= EX_MEM(78);  --RegWrite
               MEM_WB(65) <= EX_MEM(80) --MemtoReg;
               MEM_WB(70 DOWNTO 66) <= EX_MEM(85 DOWNTO 81) -- MEM_WB.Rd
               END IF;               
       END PROCESS;
   END behavior;
  

