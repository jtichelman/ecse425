--This component controls each of the five stages by setting their enable signals one after the other

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity controller is
	PORT (	clock : in std_logic;
			IF_en, ID_en, EX_en, MEM_en, WB_en :  out std_logic
		);
end controller;

architecture behaviour of controller is
	Begin
		
		increment : process(clock)
		variable count : integer := -1;
		Begin
			if(clock'EVENT and clock = '0') then
			if (count = 24) then
			  count := 0;
			else 
			  count := count + 1;
		  end if;
				CASE count is
					WHEN 0=>	--Enable IF stage, then wait 8 clock cycles (to make sure instruction is fetched)
						IF_en <='1';
						wb_en <='0';
						
					
					WHEN 8 =>	--Enable ID stage
						IF_en<='0';
						ID_en <='1';
						
						
					WHEN 9 =>	--Enable EX stage
						ID_en <= '0';
						EX_en <= '1';
						
						
					WHEN 10 =>	--Enable MEM stage, then wait 8 cycles to make sure load operations complete
						EX_en <= '0';
						MEM_en <= '1';
						
			
					WHEN 18 =>	--Enable WB stage, then wait 6 cycles to make sure store operations complete before returning to IF
						MEM_en <= '0';
						WB_en <= '1';
						
						
				  WHEN others =>
				
				End case;
			end if;
		end process;
		
end behaviour;