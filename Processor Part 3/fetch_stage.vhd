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
		
		--Ports to connect to memory controller
		address_mem: out integer;
		read_en : out std_logic;
		read_ready : in std_logic;
		data_mem : in std_logic_vector((Num_Bytes_in_Word*Num_Bits_in_Byte)-1 downto 0);
		
		--Branch ports
		pc_in : in integer;
		is_branch : in std_logic;
		
		--Output ports
		instruction_out : out std_logic_vector(31 downto 0);
		pc_out : out integer;
		fetch_ready: out std_logic
	);
End fetch_stage;

Architecture implementation of fetch_stage is

	Begin
		fetch_process : process(clock)
		variable program_counter : integer := 0; --Initialize pc to 0
		variable first : std_logic:='1';  -- 1 if it is the first instruction (so pc is initialized to 0)
		variable one_cycle_ready: std_logic  := '0';
		variable noop_counter: integer := 0;
		Begin
			if (clock = '1' and clock'event) then
			  
			if(is_branch='1' and noop_counter=0) then
			   instruction_out <= "00000000000000000000000000000000";
			   pc_out <= pc_in + 4;
			   fetch_ready <= '1';
			   noop_counter := 1;
			
			elsif (noop_counter < 5 AND noop_counter > 0) then
			  instruction_out <= "00000000000000000000000000000000";
			   pc_out <= pc_in + 4;
			   fetch_ready <= '1';
			   noop_counter := noop_counter + 1;
			
			else
			  noop_counter := 0;
			  fetch_ready <= '0';
				if fetch_en = '1' then
					if first = '1' then
						--program_counter := 0;	--First instruction at address 0
						
					else
						program_counter := pc_in; --Else use the value of PC_in
					end if;  
    
					read_en <= '1';
					address_mem <= program_counter;
					--Check for read_ready and wait in this state if not ready
					if (read_ready = '1') then
						read_en <= '0';
						
						--Write instruction to IF/ID register
						instruction_out <= data_mem;
						if (one_cycle_ready = '0') then
						  fetch_ready <= '1';	
						  one_cycle_ready := '1';
						  program_counter := program_counter + 4;
						else
						  one_cycle_ready := '0';
						  fetch_ready<='0';		
						end if;									
						pc_out <= program_counter; --increment next PC to next word
					end if;
				end if;
				if(pc_in > 0 and first='1') then
				  first := '0';	--PC no longer needs to be initialized to 0
				end if;
			end if;
			
			end if;
		end process;

End implementation;