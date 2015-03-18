--Computer Org. and Arch. Project Part 2
--Tai Hung (Henry) Lu, Saki Kajita, Jeffrey Tichelman, Francois Parent
--Description: Instruction Fetch (IF) stage of multi-stage processor

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

Entity fetch_stage is
	Generic (
		Mem_Size_in_Word : integer:=1024;	
		Num_Bytes_in_Word: integer:=4;
		Num_Bits_in_Byte: integer := 8; 
		Read_Delay: integer:=0; 
		Write_Delay:integer:=0
	);
	
	Port (
		clock: in std_logic;
		fetch_en : in std_logic;
		
		--Memory ports
		address_mem: out integer;
--		word_byte_mem : out std_logic;
--		write_en : out std_logic;
--		write_done : in std_logic;
		read_en : out std_logic;
		read_ready : in std_logic;
		data_mem : in std_logic_vector((Num_Bytes_in_Word*Num_Bits_in_Byte)-1 downto 0);
		
		--Branch ports
		pc_in : in integer;
--		instruction_in : in std_logic_vector(31 downto 0);
--		branch_check : in std_logic;
		
		--Output ports
		instruction_out : out std_logic_vector(31 downto 0);
		pc_out : out integer
	);
End fetch_stage;

Architecture implementation of fetch_stage is
	--Signal declarations
	--variable program_counter : integer range 0 to Mem_Size_in_Word*Num_Bytes_in_Word := 0; --Initialize pc to 0

	Begin
		fetch_process : process(clock)
		variable program_counter : integer := 0; --Initialize pc to 0
		variable first : std_logic:='1';
		Begin
			if (clock = '1' and clock'event) then
			  
			  --data_mem<="11111111111111111111111111111111";
				if fetch_en = '1' then
				  if first = '1' then
			       program_counter := 0;
			     else
			       program_counter := pc_in;
			     end if;  
					read_en <= '1';
--					write_en<='0';
--					word_byte_mem <= '1';
					address_mem <= program_counter;
					--Check for read_ready and wait in this state if not ready
					if (read_ready = '1') then
						read_en <= '0';
						--Write instruction to IF/ID register
						instruction_out <= data_mem;
												
						--program_counter <= program_counter + 4;	--increment PC to next word
						
						pc_out <= program_counter +4; --increment next PC to next word
					end if;
				end if;
				if(IF_en = '0' and first='1') then
				  first := '0';
				end if;
			end if;
		end process;

End implementation;