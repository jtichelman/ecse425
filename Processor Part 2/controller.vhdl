LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity controller is
	PORT (	clock : in std_logic;
			IF_en, ID_en, EX_en, MEM_en, WB_en, out std_logic
		);
end controller;

architecture behaviour of controller is
	signal count : integer;
	Begin
		count = 0;
		
		increment : process(clock)
		Begin
			if(clock'EVENT and clock = '0') then
				CASE count is
					WHEN 0=>
						IF_en <='1';
						count<='1';
					
					WHEN 1 =>
						IF_en<='0';
						ID_en <='1';
						count<='2';
						
					WHEN 2 =>
						ID_en <= '0';
						EX_en <= '1';
						count <= '3';
						
					WHEN 3 =>
						EX_en <= '0';
						MEM_en <= '1';
						count <= '4';
			
					WHEN 4 =>
						MEM_en <= '0';
						WB_en <= '1';
						count  <= '0';
		end process;
		
end behaviour;