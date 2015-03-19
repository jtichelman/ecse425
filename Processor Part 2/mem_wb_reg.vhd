LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity mem_wb_reg is
	PORT (	CLK : in std_logic;
	
			-- MEM outputs
			LMD_in : in std_logic_vector(31 downto 0);
			ALU_pass : in std_logic_vector(31 downto 0);
			
			-- WB inputs
			from_alu : out std_logic_vector(31 downto 0);
			from_mem : out std_logic_vector(31 downto 0);			
			
			-- Messages
			instruction_in : in std_logic_vector(31 downto 0);
			instruction_out : out std_logic_vector(31 downto 0)
		);
end mem_wb_reg;

architecture behaviour of mem_wb_reg is
	Begin
		process0 : process(CLK)
		Begin
			if (CLK'EVENT and CLK='0') then
				from_alu <= ALU_pass;
				from_mem <= LMD_in;
				instruction_out<=instruction_in;
			end if;
		end process;
end behaviour;