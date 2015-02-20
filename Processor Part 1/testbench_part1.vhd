--Computer Organization and Architecture Project, Part 1
--Names: Henry Lu, Saki Kajita, Francois Parent, Jeffrey Tichelman
--Description: Testbench for part 1 of project

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

Entity testbench_part1 is
End testbench_part1;

Architecture implementation of testbench_part1 is
	--Constants
	Constant Num_Bits_in_Word: integer := 8; 
	Constant Memory_Size:integer := 256;
	constant clock_period : time := 1 ns;
	
	--Component Declarations
	Component part1 is
		Port (
			clock : in std_logic;
			initialize : in std_logic;
			dump : in std_logic
		);
	End Component;
	
	--Signal declarations
	signal clock : std_logic := '0';
	signal initialize : std_logic := '0';
	signal dump : std_logic := '0';
	
	Begin
		dut : part1
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
		
		test_process : process
		Begin
			initialize <='1';
			wait for 100 ns;	--Wait until all instructions have been executed
			dump<='1';
			
			wait;
		End process;
			
		

End implementation;