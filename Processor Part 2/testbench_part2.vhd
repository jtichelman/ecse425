--Computer Organization and Architecture Project, Part 1
--Names: Henry Lu, Saki Kajita, Francois Parent, Jeffrey Tichelman
--Description: Testbench for part 2 of project

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

Entity testbench_part2 is
End testbench_part2;

Architecture implementation of testbench_part2 is
	--Constants
	Constant Num_Bits_in_Word: integer := 8; 
	Constant Memory_Size:integer := 1024;
	constant clock_period : time := 1 ns;
	
	--Component Declarations
	Component part2 is
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
	End component;
	
	--Signal declarations
	signal clock : std_logic := '0';
	signal initialize : std_logic := '0';
	signal dump : std_logic := '0';
	
	Begin
		dut : part2
			Port Map (
				clock=>clock, initialize=>initialize, dump=>dump
			);
	
		clock_process : process
		Begin
			clock <= '0';
			wait for clock_period/2;
			clock <= '1';
			wait for clock_period/2;
		end process;
		
		--Testbench begins here
		test_process : process
		Begin
		  --Load contents of init.dat file into memory
			wait for clock_period;
			initialize <='1';
			wait for clock_period;
			initialize <='0';
			wait for 2000 ns;	--Wait until all instructions have been executed, then dump. Simulate for longer than this amount!!
			dump<='1';
			wait for clock_period;
			dump<='0';
			
			wait;
		End process;
			
		

End implementation;
