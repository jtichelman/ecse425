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
End part1;

Architecture implementation of part1 is
	--Component Declarations
	Component processor is 
		Port(	
			clock : in std_logic;
			address_mem : out integer;
			word_byte_mem: out std_logic;
			write_en : out std_logic;
			write_done : in std_logic;
			read_en : out std_logic;
			read_ready : in std_logic;
			data_mem : inout std_logic_vector((Num_Bytes_in_Word*Num_Bits_in_Byte)-1 downto 0)
		);
	End Component;
	
	Component Main_Memory is
		port (
			clk : in std_logic;
			address : in integer;
			Word_Byte: in std_logic; -- when '1' you are interacting with the memory in word otherwise in byte
			we : in std_logic;
			wr_done:out std_logic; --indicates that the write operation has been done.
			re :in std_logic;
			rd_ready: out std_logic; --indicates that the read data is ready at the output.
			data : inout std_logic_vector((Num_Bytes_in_Word*Num_Bits_in_Byte)-1 downto 0);        
			initialize: in std_logic;
			dump: in std_logic
		 );
	End Component;
	
	--Connecting Signals
	signal address_signal : integer;
	signal word_byte_signal : std_logic;
	signal write_en_signal : std_logic;
	signal write_done_signal : std_logic;
	signal read_en_signal : std_logic;
	signal read_ready_signal : std_logic;
	signal data_signal : std_logic_vector((Num_Bytes_in_Word*Num_Bits_in_Byte)-1 downto 0); 
	
	Begin
		processor_module : processor 
		port map (
			clock=>clock, address_mem=>address_signal, word_byte_mem=>word_byte_signal,
			write_en=>write_en_signal, write_done=>write_done_signal,
			read_en=>read_en_signal, read_ready=>read_ready_signal, data_mem=>data_signal
		);
		
		main_memory_module : Main_Memory
		Port Map (
			clk=>clock, address=>address_signal, Word_Byte=>word_byte_signal,
			we=>write_en_signal, wr_done=>write_done_signal,
			re=>read_en_signal, rd_ready=>read_ready_signal, data=>data_signal,
			initialize=>initialize, dump=>dump
		);

End implementation;