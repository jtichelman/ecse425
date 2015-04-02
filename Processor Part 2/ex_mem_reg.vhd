--Set of registers between EX and MEM stages

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity ex_mem_reg is
	PORT (	CLK : in std_logic;
	
			-- EX outputs
			ALU_output : in std_logic_vector(31 downto 0);
			B_operand : in std_logic_vector(31 downto 0);
			branch_cond : in std_logic;
			
			-- MEM inputs
			B : out std_logic_vector(31 downto 0);
			ALU_output_to_mem : out std_logic_vector(31 downto 0);
			cond_out : out std_logic;
			NPC_out : out integer;
			
			-- Messages
			NPC_in : in integer;
			opcode_in : in std_logic_vector(5 downto 0);
			opcode_out : out std_logic_vector(5 downto 0);
			instruction_in : in std_logic_vector(31 downto 0);
			instruction_out: out std_logic_vector(31 downto 0)
		);
end ex_mem_reg;

architecture behaviour of ex_mem_reg is
	Begin
		process0 : process(CLK)
		Begin
			--Pass signals through register
			if (CLK'EVENT and CLK='0') then
				ALU_output_to_mem <= ALU_output;
				B <= B_operand;
				cond_out <= branch_cond;
				instruction_out<=instruction_in;
				NPC_out <= NPC_in;
				opcode_out <=opcode_in;
			end if;
		end process;
end behaviour;