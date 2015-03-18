library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY execute is

port( 
		enable			: in std_logic;
		clock 			: in std_logic;
		op_code			: in std_logic_vector(5 downto 0);
		d_register		: in std_logic_vector(4 downto 0);
		shift 			: in std_logic_vector(4 downto 0);
		address			: in std_logic_vector(25 downto 0);
		s_register		: in std_logic_vector(31 downto 0);
		t_register		: in std_logic_vector(31 downto 0);
		immediate	   : in std_logic_vector(31 downto 0);
		
		ALU_output  	: out std_logic_vector(31 downto 0);
		B_operand 		: out std_logic_vector(31 downto 0);
		branch_cond		: out std_logic
	  );
END execute;


Architecture behaviour of execute is

signal reg_HI			: std_logic_vector(31 downto 0);
signal reg_LO 			: std_logic_vector(31 downto 0);
signal error 			: std_logic;

begin


	Execution: process(clock)
	variable HI_LO			: std_logic_vector(63 downto 0);
	begin
	if(clock'EVENT and clock = '1') then
				if(ENABLE = '1') then
	
					case op_code is	--Check opcode
						--Arithmetic
						when "000000" => --add
							ALU_output <= std_logic_vector(signed(s_register) + signed(t_register));
						when "000001" => --sub
							ALU_output <= std_logic_vector(signed(s_register) - signed(t_register));
						when "000010" => --addi
							ALU_output <= std_logic_vector(signed(s_register) + signed(immediate));
						when "000011" => --mult
							HI_LO := std_logic_vector(signed(s_register) * signed(t_register));
							reg_HI <= HI_LO (63 downto 32);
							reg_LO <= HI_LO (31 downto 0);
							
						when "000100" => --div
							reg_LO <= std_logic_vector(signed(s_register) / signed(t_register));
							reg_HI <= std_logic_vector(signed(s_register) rem signed(t_register)); --mod or rem?
						when "000101" => --slt
							if signed(s_register) < signed(t_register) then
								ALU_output <= std_logic_vector(to_signed(1,32));
							else 
								ALU_output <= std_logic_vector(to_signed(0,32));
							end if;
						when "000110" => --slti
							if signed(s_register) < signed(immediate) then
								ALU_output <= std_logic_vector(to_signed(1,32));
							else
								ALU_output <= std_logic_vector(to_signed(0,32));
							end if;
							
						--Logical
						when "000111" => --and
							ALU_output <= s_register AND t_register;
						when "001000" => --or
							ALU_output <= s_register OR t_register;
						when "001001" => --nor
							ALU_output <= s_register NOR t_register;
						when "001010" => --xor
							ALU_output <= s_register XOR t_register;
						when "001011" => --andi
							ALU_output <= s_register AND immediate;
						when "001100" => --ori
							ALU_output <= s_register OR immediate;
						when "001101" => --xori
							ALU_output <= s_register XOR immediate;
						
						--Transfer
						when "001110" => --mfhi
							ALU_output <= reg_HI;
						when "001111" => --mflo
							ALU_output <= reg_LO;
						when "010000" => --lui
							ALU_output <= immediate;
						
						--Shift
						when "010001" => --sll
							ALU_output <= to_stdlogicvector(to_bitvector(t_register) sll to_integer(signed(shift)));
						when "010010" => --slr
							ALU_output <= to_stdlogicvector(to_bitvector(t_register) srl to_integer(signed(shift)));
						when "010011" => --sra
							ALU_output <= to_stdlogicvector(to_bitvector(t_register) sra to_integer(signed(shift)));
						
						--Memory
						when "010100" => --lw
							--Loads 4 bytes from memory into a 32-bit register
							ALU_output <= std_logic_vector(to_signed(to_integer(signed(s_register)) + to_integer(signed(immediate)),32));
						when "010101" => --lb
							ALU_output <= std_logic_vector(to_signed(to_integer(signed(s_register)) + to_integer(signed(immediate)),32));
						when "010110" => --sw
							--Store a 32-bit register into 4 memory blocks
							ALU_output <= std_logic_vector(to_signed(to_integer(signed(s_register)) + to_integer(signed(immediate)),32));
							B_operand <= t_register;
						when "010111" => --sb
							ALU_output <= std_logic_vector(to_signed(to_integer(signed(s_register)) + to_integer(signed(immediate)),32));
							B_operand <= t_register;
						
						--Control-Flow
						--Advance program counter or jump to immediate value?
						when "011000" => --beq
							if (signed(s_register) = signed(t_register)) then
								ALU_output <= immediate;
								branch_cond <= '1';
							else
								branch_cond <= '0';
							end if;
						when "011001" => --bne
							if signed(s_register) /= signed(t_register) then
								ALU_output <= immediate;
								branch_cond <= '1';
							else 
								branch_cond <= '0';
							end if;
						when "011010" => --j
							branch_cond <= '1';
							ALU_output <= "000000" & address;
						when "011011" => --jr
							branch_cond <= '1';
							ALU_output <= s_register;
						when "011100" => --jal
							branch_cond <= '1';
							ALU_output <= "000000" & address;
						when others =>
							error <= '1';
					end case;
	
		end if;
	end if;
	
	end process;
end behaviour;