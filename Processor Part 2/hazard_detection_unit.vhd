LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity hazard_detection_unit is
	PORT	(	new_destination : in std_logic_vector(31 downto 0);
				add_destination : in std_logic;
				remove_destination : in std_logic;
				dest_check1, dest_check2 : in std_logic_vector(31 downto 0);
				check : in std_logic;
				
				ok1, ok2 : out std_logic
			);
end hazard_detection_unit;

architecture behaviour of hazard_detection_unit is

	type current_destinations is ARRAY (0 to 2) of std_logic_vector(31 downto 0);
	signal dests : current_destinations;
	
	signal c1, c2 : std_logic;
	
	signal head_pointer : integer :=0;
	signal tail_pointer: integer :=0;
	
	Begin
		process0: process(check)
		Begin
			if(check'event and check='1') then
				c1<='0';
				c2<='0';
				for i in 0 to 5 loop
					if(dests(i)=dest_check1) then
						c1<='1';
					end if;
					if(dests(i)=dest_check2) then
						c2<='1';
					end if;
				end loop;
			end if;
		end process;
		
		addDestination : process(add_destination)
		Begin
			if(add_destination'event and add_destination='1') then
				if(tail_pointer=5) then
					dests(0) <= new_destination;
					tail_pointer<=0;
				else
					tail_pointer <= tail_pointer+1;
					dests(tail_pointer+1) <= new_destination;
				end if;
			end if;
		end process;

		removeDestination : process(remove_destination)
		Begin
			if(remove_destination'event and remove_destination='1') then
				if(head_pointer=5) then
					head_pointer<=0;
				else
					head_pointer<=head_pointer+1;
				end if;
			dests(head_pointer) <= "UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU";
			end if;
		end process;
				
				
	ok1 <=c1;
	ok2 <=c2;
end behaviour;