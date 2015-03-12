--Computer Org. and Arch. Project Part 2
--Tai Hung (Henry) Lu, Saki Kajita, Jeffrey Tichelman, Francois Parent
--Description: Top level entity description for Part 2

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

Entity part2 is
	Generic (
		File_Address_Read : string :="Init.dat";
		File_Address_Write : string :="MemCon.dat";
		Mem_Size_in_Word : integer:=1024;	
		Num_Bytes_in_Word: integer:=4;
		Num_Bits_in_Byte: integer := 8; 
		Read_Delay: integer:=0; 
		Write_Delay:integer:=0
	);
	Port (
		clock : in std_logic;
		initialize : in std_logic;
		dump : in std_logic
	);
end part2;

Architecture implementation of part2 is
	--Component declarations
	Component fetch_stage is 
		Port (
			clock: in std_logic;
			
			--Memory ports
			address_mem: out integer;
			word_byte_mem : out std_logic;
			write_en : out std_logic;
			write_done : in std_logic;
			read_en : out std_logic;
			read_ready : in std_logic;
			data_mem : inout std_logic_vector((Num_Bytes_in_Word*Num_Bits_in_Byte)-1 downto 0);
			
			--Branch ports
			pc_in : in integer;
			instruction_in : in std_logic_vector(31 downto 0);
			branch_check : in std_logic;
			
			--Output ports
			instruction_out : out std_logic_vector(31 downto 0);
			pc_out : out integer
		);
	End component;
	
	--ID stage
	--EX stage
	--MEM stage
	--WB stage
	
	--Signal Declarations
	--Connecting stages together
	
	Begin
	
End implementation;