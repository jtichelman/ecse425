--Computer Organization and Architecture Project, Part 1
--Names: Henry Lu, Saki Kajita, Francois Parent, Jeffrey Tichelman
--Description: MIPS processor entity description and behavior

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

Entity processor is
	Generic (
			Mem_Size : integer:=256;
			Num_Bits_in_Word: integer:=8;
			Read_Delay: integer:=0; 
			Write_Delay:integer:=0
	);
	Port(	clock : in std_logic;
			address_mem : out integer;
			write_en : out std_logic;
			write_done : in std_logic;
			read_en : out std_logic;
			read_ready : in std_logic;
			data_mem : inout std_logic_vector(Num_Bits_in_Word-1 downto 0)
	);
End processor;

Architecture implementation of processor is
	--Instantiate registers 0-31 as an array of registers
	type reg_block is ARRAY (0 to 31) of std_logic_vector(31 downto 0);
	signal reg : reg_block;
	
	--Signal declarations
	signal program_counter : integer range 0 to Mem_Size := 0; --Initialize pc to 0
	signal instruction : std_logic_vector (31 downto 0); --Stores the instruction after being read from mem
	signal reg_lo : std_logic_vector (31 downto 0); --$LO, stores lower bits of a 64-bit value
	signal reg_hi : std_logic_vector (31 downto 0); --$HI, stores upper bits of a 64-bit value
	
	--State declarations
	type cpu_state is (FETCH_STATE, EXECUTE_STATE);
	signal current_state : cpu_state := FETCH_STATE;
	signal next_state : cpu_state;
	
	Begin
		reg(0) <= std_logic_vector(to_unsigned(0, 32));	-- reg(0) holds the value 0
		
		cpu_process : process(clock)
		--Variable declarations
		variable data_counter: integer range 0 to 3 := 0;	--Keeps track of words read from memory
		variable reg_s: integer range 0 to 31; --For storing "rs" field as an int
		variable reg_t: integer range 0 to 31; --For storing "rt" field as an int
		variable reg_d: integer range 0 to 31; --For storing "rd" field as an int
		variable imm: integer range 0 to 65535; --For storing immediate field as an int
		variable addr: integer range 0 to 67108863; --For storing address field as an int
		variable hi_lo: std_logic_vector (63 downto 0); --Holds 64-bit values before splitting into $HI and $LO
		variable shift_by: integer range 0 to 31; --Holds the amount to shift by for shift operations
		
		Begin
			--For testing purposes, initialize registers with values
			IF(now < 1 ps)THEN
				For i in 0 to 31 LOOP
					reg(i) <= std_logic_vector(to_unsigned(i,32));
				END LOOP;
			end if;	
			
			if (clock = '0' and clock'event) then
			case current_state is 
			
				--Fetch instruction from memory
				when FETCH_STATE =>
					data_mem <= "ZZZZZZZZ"; -- Apparently needed for INOUT ports
					read_en <= '1';
					write_en<='0';
					address_mem <= program_counter;
					--Check for read_ready and wait in this state if not ready
					if (read_ready = '1') then
						read_en <= '0';
						--Load 8-bit words into 32-bit instruction register
						case data_counter is
							when 0 =>
								instruction(31 downto 24) <= data_mem;
							when 1 =>
								instruction(23 downto 16) <= data_mem;
							when 2 =>
								instruction(15 downto 8) <= data_mem;
							when 3 =>
								instruction(7 downto 0) <= data_mem;
						end case;
						program_counter <= program_counter + 1;	--increment PC
						if data_counter = 3 then	--All 32 bits have been loaded, proceed to execute state
							data_counter := 0;
							next_state <= EXECUTE_STATE;
						else
							data_counter := data_counter + 1;
							next_state <=FETCH_STATE;
						end if;
					else
						next_state <= FETCH_STATE;
					end if;
					
				--Execute instruction in instruction register
				when EXECUTE_STATE =>
					data_mem <= "ZZZZZZZZ";
					next_state <= FETCH_STATE;
					reg_s := to_integer(signed(instruction(25 downto 21)));
					reg_t := to_integer(signed(instruction(20 downto 16)));
					reg_d := to_integer(signed(instruction(15 downto 11)));
					imm := to_integer(signed(instruction(15 downto 0)));
					addr := to_integer(unsigned(instruction(25 downto 0)));
					shift_by := to_integer(signed(instruction(15 downto 11)));
					
					case instruction(31 downto 26) is	--Check opcode
						--Arithmetic
						when "000000" => --add
							reg(reg_d) <= std_logic_vector(signed(reg(reg_s)) + signed(reg(reg_t)));
						when "000001" => --sub
							reg(reg_d) <= std_logic_vector(signed(reg(reg_s)) - signed(reg(reg_t)));
						when "000010" => --addi
							reg(reg_t) <= std_logic_vector(signed(reg(reg_s)) + to_signed(imm,32));
						when "000011" => --mult
							hi_lo := std_logic_vector(signed(reg(reg_s)) * signed(reg(reg_t)));
							reg_hi <= hi_lo (63 downto 32);
							reg_lo <= hi_lo (31 downto 0);
						when "000100" => --div
							reg_lo <= std_logic_vector(signed(reg(reg_s)) / signed(reg(reg_t)));
							reg_hi <= std_logic_vector(signed(reg(reg_s)) rem signed(reg(reg_t))); --mod or rem?
						when "000101" => --slt
							if signed(reg(reg_s)) < signed(reg(reg_t)) then
								reg(reg_d) <= std_logic_vector(to_signed(1,32));
							else 
								reg(reg_d) <= std_logic_vector(to_signed(0,32));
							end if;
						when "000110" => --slti
							if signed(reg(reg_s)) < to_signed(imm, 32) then
								reg(reg_t) <= std_logic_vector(to_signed(1,32));
							else
								reg(reg_t) <= std_logic_vector(to_signed(0,32));
							end if;
							
						--Logical
						when "000111" => --and
							reg(reg_d) <= reg(reg_s) AND reg(reg_t);
						when "001000" => --or
							reg(reg_d) <= reg(reg_s) OR reg(reg_t);
						when "001001" => --nor
							reg(reg_d) <= reg(reg_s) NOR reg(reg_t);
						when "001010" => --xor
							reg(reg_d) <= reg(reg_s) XOR reg(reg_t);
						when "001011" => --andi
							reg(reg_t) <= reg(reg_s) AND std_logic_vector(to_signed(imm,32));
						when "001100" => --ori
							reg(reg_t) <= reg(reg_s) OR std_logic_vector(to_signed(imm,32));
						when "001101" => --xori
							reg(reg_t) <= reg(reg_s) XOR std_logic_vector(to_signed(imm,32));
						
						--Transfer
						when "001110" => --mfhi
							reg(reg_d) <= reg_hi;
						when "001111" => --mflo
							reg(reg_d) <= reg_lo;
						when "010000" => --lui
							reg(reg_t) <= std_logic_vector(to_signed(imm,32) sll 16);
						
						--Shift
						when "010001" => --sll
							reg(reg_s) <= to_stdlogicvector(to_bitvector(reg(reg_t)) sll shift_by);
						when "010010" => --slr
							reg(reg_s) <= to_stdlogicvector(to_bitvector(reg(reg_t)) srl shift_by);
						when "010011" => --sra
							reg(reg_s) <= to_stdlogicvector(to_bitvector(reg(reg_t)) sra shift_by);
						
						--Memory
						when "010100" => --lw
							--Loads 4 bytes from memory into a 32-bit register
							read_en <= '1';
							address_mem <= to_integer(signed(reg(reg_s))) + imm + data_counter;
							if (read_ready = '1') then
								case data_counter is
									when 0 =>
										reg(reg_t)(31 downto 24) <= data_mem;
									when 1 =>
										reg(reg_t)(23 downto 16) <= data_mem;
									when 2 =>
										reg(reg_t)(15 downto 8) <= data_mem;
									when 3 =>
										reg(reg_t)(7 downto 0) <= data_mem;
								end case;
								read_en <='0';
								if data_counter = 3 then	--If all four words have been loaded
									data_counter := 0;
									next_state <= FETCH_STATE;
								else 
									data_counter := data_counter + 1;
									next_state <= EXECUTE_STATE;
								end if;
							else 
								next_state <= EXECUTE_STATE;
							end if;
						when "010101" => --lb
							read_en <= '1';
							address_mem <= to_integer(signed(reg(reg_s))) + imm;
							if (read_ready = '1') then
								reg(reg_t) <= std_logic_vector(resize(signed(data_mem), 32));
								read_en <='0';
							else 
								next_state <= EXECUTE_STATE;
							end if;
						when "010110" => --sw
							--Store a 32-bit register into 4 memory blocks
							write_en <= '1';
							address_mem <= to_integer(signed(reg(reg_s))) + imm + data_counter;
							case data_counter is
								when 0 =>
									data_mem <= reg(reg_t)(31 downto 24);
								when 1 =>
									data_mem <= reg(reg_t)(23 downto 16);
								when 2 =>
									data_mem <= reg(reg_t)(15 downto 8);
								when 3 =>
									data_mem <= reg(reg_t)(7 downto 0);
							end case;
							if (write_done = '1') then
								write_en <='0';
								if data_counter = 3 then
									data_counter := 0;
									next_state <= FETCH_STATE;
								else
									data_counter := data_counter + 1;
									next_state <= EXECUTE_STATE;
								end if;
							else 
								next_state <= EXECUTE_STATE;
							end if;
								
						when "010111" => --sb
							write_en <= '1';
							address_mem <= to_integer(signed(reg(reg_s))) + imm;
							data_mem <= reg(reg_t)(7 downto 0);
							if (write_done = '1') then
								write_en <='0';
							else	
								next_state <= EXECUTE_STATE;
							end if;
						
						--Control-Flow
						--Advance program counter or jump to immediate value?
						when "011000" => --beq
							if signed(reg(reg_s)) = signed(reg(reg_t)) then
								program_counter <= imm;
							end if;
						when "011001" => --bne
							if signed(reg(reg_s)) /= signed(reg(reg_t)) then
								program_counter <= imm;
							end if;
						when "011010" => --j
							program_counter <= addr;
						when "011011" => --jr
							program_counter <= to_integer(signed(reg(reg_s)));
						when "011100" => --jal
							reg(31) <= std_logic_vector(to_signed(program_counter, 32));
							program_counter <= addr;
						when others =>
							next_state <= FETCH_STATE;
					end case;
			end case;	
			end if;	
		end process;
		
		clock_process : process(clock)
		Begin
			if (clock = '1' AND clock'event) then	--Change state at each rising clock edge
				current_state <= next_state;
			end if;
		end process;
	
	
End implementation;