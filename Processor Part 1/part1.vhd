--Computer Organization and Architecture Project, Part 1
--Names: Henry Lu, Saki Kajita, Francois Parent, Jeffrey Tichelman
--Description: Top level entity for part 1 of the project

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

Entity part1 is 
	Generic (
			File_Address_Read : string :="Init.dat";
			File_Address_Write : string :="MemCon.dat";
			Mem_Size : integer:=256;
			Num_Bits_in_Word: integer:=8;
			Read_Delay: integer:=0; 
			Write_Delay:integer:=0
	);
	Port (
		clock : in std_logic;
		initialize : in std_logic;
		dump : in std_logic
	);
End part1;

Architecture implementation of part1 is
	--Component Declarations
	Component processor is 
		Port(	
			clock : in std_logic;
			address_mem : out integer;
			write_en : out std_logic;
			write_done : in std_logic;
			read_en : out std_logic;
			read_ready : in std_logic;
			data_mem : inout std_logic_vector(Num_Bits_in_Word-1 downto 0)
		);
	End Component;
	
	Component Main_Memory is
		port (
			clk : in std_logic;
			address : in integer;
			we : in std_logic;
			wr_done:out std_logic; --indicates that the write operation has been done.
			re :in std_logic;
			rd_ready: out std_logic; --indicates that the read data is ready at the output.
			data : inout std_logic_vector(Num_Bits_in_Word-1 downto 0);        
			initialize: in std_logic;
			dump: in std_logic
		 );
	End Component;
	
	--Connecting Signals
	signal address_signal : integer;
	signal write_en_signal : std_logic;
	signal write_done_signal : std_logic;
	signal read_en_signal : std_logic;
	signal read_ready_signal : std_logic;
	signal data_signal : std_logic_vector(Num_Bits_in_Word-1 downto 0); 
	
	Begin
		processor_module : processor 
		port map (
			clock, address_signal, write_en_signal, write_done_signal, read_en_signal,
			read_ready_signal, data_signal
		);
		
		main_memory_module : Main_Memory
		Generic Map (
			File_Address_Read => "Init.dat",
			File_Address_Write => "MemCon.dat",
			Mem_Size => 256,
			Num_Bits_in_Word => 8,
			Read_Delay => 3,
			Write_Delay => 0
		);
		Port Map (
			clock, address_signal, write_en_signal, write_done_signal, read_en_signal,
			read_ready_signal, data_signal, initialize, dump
		);

End implementation;