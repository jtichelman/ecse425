LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity id_ex_reg is
	PORT (	CLK : in std_logic;
	
			-- Outputs of ID
			command_in : in std_logic_vector(5 downto 0);
			d_reg_in : in std_logic_vector(4 downto 0);
			shift_in : in std_logic_vector(4 downto 0);
			address_in : in std_logic_vector(25 downto 0);
			s_reg_in: in std_logic_vector(31 downto 0);
			t_reg_in : in std_logic_vector(31 downto 0);
			imm_in : in std_logic_vector(31 downto 0);
			
			-- Inputs to EX
			op_code : out std_logic_vector(5 downto 0);
			d_reg_out : out std_logic_vector(4 downto 0);
			shift_out : out std_logic_vector(4 downto 0);
			address_out : out std_logic_vector(25 downto 0);
			s_reg_out : out std_logic_vector(31 downto 0);
			t_reg_out : out std_logic_vector(31 downto 0);
			imm_out : : out std_logic_vector(31 downto 0);
			
			-- Additional message passing
			npc_in : in integer;
			npc_out : out integer
		);
end id_ex_reg;

architecture behaviour of id_ex_reg is
	Begin
		process0 : process(CLK)
		Begin
			if(CLK'EVENT and CLK='0') then
				op_code <= command_in;
				d_reg_out <= d_reg_in;
				shift_out <= shift_in;
				address_out <= address_in;
				s_reg_out <= s_reg_in;
				t_reg_out <= t_reg_in;
				imm_out <= imm_in;
				
				npc_out <= npc_in;
			end if;
		end process;
end behaviour;
			