LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity controller is
	PORT (	clock : in std_logic;
	    IF_ready, ID_ready, EX_ready, MEM_ready: in std_logic;
			IF_en, ID_en, EX_en, MEM_en, WB_en :  out std_logic
		);
end controller;

architecture behaviour of controller is
	Begin
		
		ID_en <= IF_ready;
		--EX_en <= ID_ready;
		--MEM_en <= EX_ready;
		--WB_en <= MEM_ready;
		
		IF_en <= 1;
		
		EX_en <=1;
		MEM_en <=1;
		WB_en <=1;
		
		
		
		
--		increment : process(clock)
--		variable count : integer := -1;
--		Begin
--			if(clock'EVENT and clock = '0') then
--			if (count = 24) then
--			  count := 0;
--			else 
--			  count := count + 1;
--		  end if;
--				CASE count is
--					WHEN 0=>
--						IF_en <='1';
--						wb_en <='0';
--						
--					
--					WHEN 8 =>
--						IF_en<='0';
--						ID_en <='1';
--						
--						
--					WHEN 9 =>
--						ID_en <= '0';
--						EX_en <= '1';
--						
--						
--					WHEN 10 =>
--						EX_en <= '0';
--						MEM_en <= '1';
--						
--			
--					WHEN 18 =>
--						MEM_en <= '0';
--						WB_en <= '1';
--						
--						
--				  WHEN others =>
--				
--				End case;
--			end if;
--		end process;
		
end behaviour;