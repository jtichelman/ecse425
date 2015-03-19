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
		npc_in	: 	in integer;
		instruction_out : out std_logic_vector(31 downto 0);
		npc_out : out integer);
END instruction_decode;


architecture behav of instruction_decode is
	--Instantiate registers 0-31 as an array of registers
	type reg_block is ARRAY (0 to 31) of std_logic_vector(31 downto 0);
	signal reg : reg_block;



begin
	npc_out<=npc_in;
	instruction_out<=instruction;
	Decode: process(clock)
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
	begin
		if (clock = '1' and clock'event) then
			if (en = '1') then
				opcode := instruction(31 downto 26);
				reg_s := to_integer(unsigned(instruction(25 downto 21)));
				reg_t := to_integer(unsigned(instruction(20 downto 16)));
				reg_d := to_integer(unsigned(instruction(15 downto 11)));
				imm := to_integer(signed(instruction(15 downto 0)));
				addr := to_integer(unsigned(instruction(25 downto 0)));
				shift_by := to_integer(unsigned(instruction(15 downto 11)));
			
				s_register <= std_logic_vector(signed(reg(reg_s)));
				t_register <= std_logic_vector(signed(reg(reg_t)));
				immediate <= std_logic_vector(to_signed(imm,32));
				command <= opcode;
				d_register <= std_logic_vector(to_unsigned(reg_d, 5));
				address <= std_logic_vector(to_unsigned(addr, 26));
				shift <= std_logic_vector(to_unsigned(shift_by, 5));
			end if;
			if(wb_en = '1') then
				write_to := to_integer(unsigned(wb_addr));
				reg(write_to) <= wb_val;
			end if;
		end if;

  reg(0) <= "00000000000000000000000000000000";
	end process;
end behav;