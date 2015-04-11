--ID stage of the five-stage processor

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY instruction_decode is

port( 	instruction		:	in std_logic_vector(31 downto 0);
		wb_addr	:	in std_logic_vector(4 downto 0);
		wb_val	:	in std_logic_vector(31 downto 0);
		en, wb_en, clock : in std_logic;
		command	:	out std_logic_vector(5 downto 0);
		d_register, shift : out std_logic_vector (4 downto 0);
		Address	: out std_logic_vector(25 downto 0);
		s_register, t_register, immediate	:	out std_logic_vector(31 downto 0);
		npc_in : in integer;
		instruction_out: out std_logic_vector(31 downto 0);
		npc_out : out integer;
		is_branch : out std_logic := '0');
END instruction_decode;

architecture behav of instruction_decode is
	--Instantiate registers 0-31 as an array of registers
	type reg_block is ARRAY (0 to 31) of std_logic_vector(31 downto 0);
	signal reg : reg_block;
	
	-- This array will hold the destination register numbers currently in the pipeline
	type current_destinations is ARRAY (0 to 2) of integer;
	signal dests : current_destinations;
  
  -- These signals keep track of entry and exit points of current_destinations
	signal head_pointer : integer :=0;
	signal tail_pointer : integer :=2;
	


begin


	Decode: process(clock, wb_en)
	--Variable declarations
	--variable data_counter: integer range 0 to 3 := 0;
	--Keeps track of words read from memory
	variable opcode: std_logic_vector(5 downto 0); --For storing instruction opcode
	variable reg_s: integer range 0 to 31; --For storing "rs" field as an int
	variable reg_t: integer range 0 to 31; --For storing "rt" field as an int
	variable reg_d: integer range 0 to 31; --For storing "rd" field as an int
	variable imm: integer; --For storing immediate field as an int
	variable addr: integer range 0 to 67108863; --For storing address field as an int
	variable hi_lo: std_logic_vector (63 downto 0); --Holds 64-bit values before splitting into $HI and $LO
	variable shift_by: integer range 0 to 31; --Holds the amount to shift by for shift operations
	variable write_to: integer range 0 to 31;
	
	-- If the instruction store in a register file, destination register # calculated here
	variable destination : integer;
	
	-- Operand register numbers are stored here to check against current destinations
	variable operand1 : integer;
	variable operand2 : integer;
	
	-- Flag for data hazards
	variable flag : integer;
	
	begin
		if (clock = '1' and clock'event) then
			if (en = '1') then
				reg_s := to_integer(unsigned(instruction(25 downto 21)));
				reg_t := to_integer(unsigned(instruction(20 downto 16)));
				reg_d := to_integer(unsigned(instruction(15 downto 11)));
				imm := to_integer(signed(instruction(15 downto 0)));
				addr := to_integer(unsigned(instruction(25 downto 0)));
				shift_by := to_integer(unsigned(instruction(15 downto 11)));
				
				opcode := instruction(31 downto 26);
				
				operand1 := reg_s;
				operand2 := reg_t;
				
				-- If the instruction is a branch send a branch flag to IF
				if(opcode="011000" or opcode="011001" or opcode="011010" or opcode="011011"
				      or opcode="011100") then
				    is_branch<='1';
				else
				  is_branch<='0';
				end if;
				
				-- If the instruction needs to store its result in the register file,
				-- save the number of the destination register in dests, unless the destination is $0
				if(reg_d = 0) then
				  
				elsif( opcode="000000" or opcode="000001" or opcode="000111" or opcode="001000"
					or opcode="001001" or opcode="001010" or opcode="001110" or opcode="001111") then
						destination := to_integer(unsigned(instruction(15 downto 11)));
						if(tail_pointer=2) then
							tail_pointer<=0;
							dests(0)<=destination;
						else
							tail_pointer<=tail_pointer+1;
							dests(tail_pointer+1)<=destination;
						end if;
				elsif(opcode="000010" or opcode="000110" or opcode="001011" or opcode="001100"
					or opcode="001101" or opcode="010000" or opcode="010100" or opcode="010101") then
						destination:= to_integer(unsigned(instruction(20 downto 16)));		
						if(tail_pointer=2) then
							tail_pointer<=0;
							dests(0)<=destination;
						else
							tail_pointer<=tail_pointer+1;
							dests(tail_pointer+1)<=destination;
						end if;
				end if;
				
				-- If one of the current instructions operands is the destination  for an
				-- instruction already in the pipeline, set the data hazard flag
				flag:=0;
				for i in 0 to 2 loop
					if(dests(i)=operand1 OR dests(i) = operand2) then
						flag:=1;
					end if;
				end loop;
	
				
				-- If the data hazard flag is set, send a no op and fetch the same instruction again
				if(flag=1) then
					s_register<="00000000000000000000000000000000";
					t_register<="00000000000000000000000000000000";
					immediate<="00000000000000000000000000000000";
					command<="000000";
					d_register<="00000";
					address<="00000000000000000000000000";
					shift<="00000";
					instruction_out<="00000000000000000000000000000000";
					npc_out<=npc_in-4;
				
				-- Else release the instruction
				else
					s_register <= std_logic_vector(signed(reg(reg_s)));
					t_register <= std_logic_vector(signed(reg(reg_t)));
					immediate <= std_logic_vector(to_signed(imm,32));
					command <= opcode;
					d_register <= std_logic_vector(to_unsigned(reg_d, 5));
					address <= std_logic_vector(to_unsigned(addr, 26));
					shift <= std_logic_vector(to_unsigned(shift_by, 5));
					instruction_out<=instruction;
					npc_out<=npc_in;
				end if;
			end if;
			
			-- If wb_en is set, then write wb_val back to the register file
			if(wb_en = '1') then
				write_to := to_integer(unsigned(wb_addr));
				reg(write_to) <= wb_val;	
				
				-- Remove this destination from the current destinations
    			 if(dests(head_pointer)= write_to) then
				   dests(head_pointer) <= -1;
				   if(head_pointer=2) then
				     head_pointer<=0;
				   else
				      head_pointer<=head_pointer+1;
				   end if;
				 end if;
			end if;
			
		end if;
		reg(0) <= "00000000000000000000000000000000";
	end process;
end behav;