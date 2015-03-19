 LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity if_id_reg is
	PORT (	CLK : in std_logic;
	
			-- IF outputs
			instruction_in : in std_logic_vector(31 downto 0);
			npc_in : in  integer;
			
			-- ID inputs
			instruction_out : out std_logic_vector(31 downto 0);
			
			-- Message passing
			npc_out : out integer
		);
end if_id_reg;

architecture behaviour of if_id_reg is
	Begin
		process0 : process(CLK)
		Begin
			if (CLK'EVENT and CLK = '0') then
				instruction_out <= instruction_in;
				npc_out <= npc_in;
			end if;
		end process;	
end behaviour;