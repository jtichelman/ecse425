--Computer Org. and Arch. Project Part 2
--Tai Hung (Henry) Lu, Saki Kajita, Jeffrey Tichelman, Francois Parent
--Description: Write-back stage (WB) stage of multi-stage processor

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

Entity writeback_stage is
	Generic (
		Mem_Size_in_Word : integer:=1024;	
		Num_Bytes_in_Word: integer:=4;
		Num_Bits_in_Byte: integer := 8; 
		Read_Delay: integer:=0; 
		Write_Delay:integer:=0
	);
	Port (
		clock : in std_logic;
		from_mem : in std_logic_vector (31 downto 0);
		from_alu : in std_logic_vector (31 downto 0);
		instruction: in std_logic_vector (31 downto 0);
		
		write_data : out std_logic_vector (31 downto 0);
		reg_address : out integer range 0 to 31;
		reg_enable : in std_logic
	);
End writeback_stage;

Architecture implementation of writeback_stage is
	Begin
	
	writeback_process : process(clock)
	Begin
		if (clock = '1' and clock'event) then
		
			--Set the data to be written
			if (instruction(31 downto 26) = "010100" OR		--If load word instruction,
			    instruction(31 downto 26) = "010101") then	--Or if load byte instruction
				write_data <=from_mem;	--Write to registers from Memory
			else
				write_data<= from_alu;	--Write to registers from ALU
			end if;
			
			--Set which register to write to
			if (instruction(31 downto 26) = "000010" OR
				instruction(31 downto 26) = "000110" OR
				instruction(31 downto 26) = "001011" OR
				instruction(31 downto 26) = "001100" OR
				instruction(31 downto 26) = "001101" OR
				instruction(31 downto 26) = "010000" OR
				instruction(31 downto 26) = "010100" OR
				instruction(31 downto 26) = "010101") then
				reg_address<=to_integer(unsigned(instruction(20 downto 16)));	--Store in register t
			
			elsif (	instruction(31 downto 26) = "010001" OR
					instruction(31 downto 26) = "010010" OR
					instruction(31 downto 26) = "010011") then
				reg_address<=to_integer(unsigned(instruction(25 downto 21)));	--Store in register S
			
			else 
				reg_address<=to_integer(unsigned(instruction(15 downto 11)));	--Store in register D
			end if;
		end if;
	End process;
End implementation;