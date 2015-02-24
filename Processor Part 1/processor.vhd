--Computer Organization and Architecture Project, Part 1
--Names: Henry Lu, Saki Kajita, Francois Parent, Jeffrey Tichelman
--Description: MIPS processor entity description and behavior

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

Entity processor is
	Generic (
			Mem_Size_in_Word : integer:=1024;	
			Num_Bytes_in_Word: integer:=4;
			Num_Bits_in_Byte: integer := 8; 
			Read_Delay: integer:=0; 
			Write_Delay:integer:=0
	);
	Port(	clock : in std_logic;
			address_mem : out integer;
			word_byte_mem: out std_logic;
			write_en : out std_logic;
			write_done : in std_logic;
			read_en : out std_logic;
			read_ready : in std_logic;
			data_mem : inout std_logic_vector((Num_Bytes_in_Word*Num_Bits_in_Byte)-1 downto 0)
	);
End processor;

Architecture implementation of processor is
	--Instantiate registers 0-31 as an array of registers
	type reg_block is ARRAY (0 to 31) of std_logic_vector(31 downto 0);
	signal reg : reg_block;
	
	--Signal declarations
	signal program_counter : integer range 0 to Mem_Size_in_Word*Num_Bytes_in_Word := 0; --Initialize pc to 0
	--signal instruction : std_logic_vector (31 downto 0); --Stores the instruction after being read from mem
	signal reg_lo : std_logic_vector (31 downto 0); --$LO, stores lower bits of a 64-bit value
	signal reg_hi : std_logic_vector (31 downto 0); --$HI, stores upper bits of a 64-bit value
	
	--State declarations
	type cpu_state is (FETCH_STATE, EXECUTE_STATE);
	signal current_state : cpu_state := FETCH_STATE;
	signal next_state : cpu_state;
	
	Begin
		--reg(0) <= std_logic_vector(to_unsigned(0, 32));	-- reg(0) holds the value 0
		
		cpu_process : process(clock)
		--Variable declarations
		--variable data_counter: integer range 0 to 3 := 0;	--Keeps track of words read from memory
		variable opcode: std_logic_vector(5 downto 0); --For storing instruction opcode
		variable reg_s: integer range 0 to 31; --For storing "rs" field as an int
		variable reg_t: integer range 0 to 31; --For storing "rt" field as an int
		variable reg_d: integer range 0 to 31; --For storing "rd" field as an int
		variable imm: integer; --For storing immediate field as an int
		variable addr: integer range 0 to 67108863; --For storing address field as an int
		variable hi_lo: std_logic_vector (63 downto 0); --Holds 64-bit values before splitting into $HI and $LO
		variable shift_by: integer range 0 to 31; --Holds the amount to shift by for shift operations
		
		Begin
			--For testing purposes, initialize registers with values
--			IF(now < 1 ps)THEN
--				For i in 0 to 31 LOOP
--					reg(i) <= std_logic_vector(to_unsigned(i,32));
--				END LOOP;
--			end if;	
			
			reg(0) <= std_logic_vector(to_unsigned(0, 32));	-- reg(0) holds the value 0
			
			if (clock = '0' and clock'event) then
			case current_state is 
			
				--Fetch instruction from memory
				when FETCH_STATE =>
					data_mem <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"; -- Apparently needed for INOUT ports
					read_en <= '1';
					write_en<='0';
					word_byte_mem <= '1';
					address_mem <= program_counter;
					--Check for read_ready and wait in this state if not ready
					if (read_ready = '1') then
						read_en <= '0';
						--Store instruction for use in next cycle
						opcode := data_mem(31 downto 26);
						reg_s := to_integer(unsigned(data_mem(25 downto 21)));
						reg_t := to_integer(unsigned(data_mem(20 downto 16)));
						reg_d := to_integer(unsigned(data_mem(15 downto 11)));
						imm := to_integer(signed(data_mem(15 downto 0)));
						addr := to_integer(unsigned(data_mem(25 downto 0)));
						shift_by := to_integer(unsigned(data_mem(15 downto 11)));
												
						program_counter <= program_counter + 4;	--increment PC to next word
						next_state <= EXECUTE_STATE;
					else
						next_state <= FETCH_STATE;
					end if;
					
				--Execute instruction in instruction register
				when EXECUTE_STATE =>
					data_mem <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
					next_state <= FETCH_STATE;
										
					case opcode is	--Perform instruction depending on opcode
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
							--Loads 32-bit word from memory into a 32-bit register
							read_en <= '1';
							write_en<= '0';
							word_byte_mem<='1';
							address_mem <= to_integer(unsigned(reg(reg_s))) + imm;
							--address_mem <= (to_integer(unsigned(reg(reg_s))) + imm)/4;
							if (read_ready = '1') then
								reg(reg_t)<=data_mem;
								
								read_en <='0';
								next_state <= FETCH_STATE;
							else 
								next_state <= EXECUTE_STATE;
							end if;
						when "010101" => --lb
							--Load 1 byte from memory into least-significant bits of register and sign-extend
							read_en <= '1';
							write_en<='0';
							word_byte_mem<='0';
						  address_mem <= to_integer(unsigned(reg(reg_s))) + (imm);
					    --address_mem <= (to_integer(unsigned(reg(reg_s))) + imm);
							if (read_ready = '1') then
								reg(reg_t) <= std_logic_vector(resize(signed(data_mem(7 downto 0)), 32));
								read_en <='0';
							else 
								next_state <= EXECUTE_STATE;
							end if;
						when "010110" => --sw
							--Store a 32-bit register into memory
							write_en <= '1';
							read_en<='0';
							word_byte_mem<='1';
							--address_mem <= (to_integer(unsigned(reg(reg_s))) + imm)/4;
							address_mem <= to_integer(unsigned(reg(reg_s))) + imm;
								data_mem<=reg(reg_t);
							if (write_done = '1') then
								write_en <='0';
								next_state <= FETCH_STATE;
							else 
								next_state <= EXECUTE_STATE;
							end if;
								
						when "010111" => --sb
							--Store least-significant byte from register to memory
							write_en <= '1';
							read_en<='0';
							word_byte_mem<='0';
							address_mem <= (to_integer(unsigned(reg(reg_s))) + imm);
							--address_mem <= to_integer(unsigned(reg(reg_s))) + (imm*4);
							data_mem(7 downto 0) <= reg(reg_t)(7 downto 0);
							if (write_done = '1') then
								write_en <='0';
							else	
								next_state <= EXECUTE_STATE;
							end if;
						
						--Control-Flow
						--Advance program counter or jump to immediate value?
						when "011000" => --beq
							if signed(reg(reg_s)) = signed(reg(reg_t)) then
								program_counter <= program_counter - 4 + (imm*4);
							end if;
						when "011001" => --bne
							if signed(reg(reg_s)) /= signed(reg(reg_t)) then
								program_counter <= program_counter -4 + (to_integer(to_signed(imm, 16)*4));
							end if;
						when "011010" => --j
							program_counter <= program_counter -4 +(addr*4);
						when "011011" => --jr
							program_counter <= to_integer(unsigned(reg(reg_s)));
						when "011100" => --jal
							reg(31) <= std_logic_vector(to_unsigned(program_counter, 32));
							program_counter <= program_counter -4 + (addr*4);
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