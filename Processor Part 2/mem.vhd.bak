LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity mem is
	PORT (	CLK : in std_logic;
				B : in std_logic_vector(31 downto 0);
				ALU_Output : in std_logic_vector(31 downto 0);
				DATA_MEMORY : inout std_logic_vector(31 downto 0);
				ENABLE : in std_logic;
				COND : in std_logic;
				READ_READY, WRITE_DONE : in std_logic;
				NPC : in integer;
				INST : in integer;
				PC : out integer;
				READ_EN, WRITE_EN, WORD_BYTE_MEM : out std_logic;
				ADDRESS_MEM : out integer;
				LMD : out std_logic_vector(31 downto 0)
			);			
end mem;

architecture behaviour of mem is
	Begin
		process0 : process(CLK, ENABLE)
		begin
			if(CLK'EVENT and CLK = '1') then
				if(ENABLE = '1') then
					CASE INST is
						--ALU Instructions
						WHEN 0 to 20=>
							PC <= NPC;
							LMD <= ALU_Output;
							
						--Load Word	
						WHEN 21 =>
							READ_EN <= '1';
							WRITE_EN <= '0';
							WORD_BYTE_MEM <= '1';
							ADDRESS_MEM <= to_integer(unsigned(ALU_Output));
							if(READ_READY='1') then
								LMD <= DATA_MEMORY;
								READ_EN <= '0';
							end if;							

						--Load Byte	
						WHEN 22 =>
							READ_EN <= '1';
							WRITE_EN <= '0';
							WORD_BYTE_MEM <= '0';
							ADDRESS_MEM <= to_integer(unsigned(ALU_Output));
							if(READ_READY='1') then
								LMD <= DATA_MEMORY;
								READ_EN <= '0';
							end if;	
							
						--Store Word
						WHEN 23 =>
							READ_EN <= '0';
							WRITE_EN <= '1';
							WORD_BYTE_MEM <= '1';
							ADDRESS_MEM <= to_integer(unsigned(ALU_Output));
							DATA_MEMORY <= B;
							if(WRITE_DONE='1') then
								WRITE_EN <= '0';
							end if;	
						
						--Store Byte
						WHEN 24 =>
							READ_EN <= '0';
							WRITE_EN <= '1';
							WORD_BYTE_MEM <= '0';
							ADDRESS_MEM <= to_integer(unsigned(ALU_Output));
							DATA_MEMORY <= B;
							if(WRITE_DONE='1') then
								WRITE_EN <= '0';
							end if;	
						
						--Branch instruction
						WHEN others =>
							if(COND = '1') then
								PC <= to_integer(unsigned(ALU_Output));
							else
								PC <= NPC;
							end if;
					END CASE;
				END IF;
			END IF;
			
		end process;

end behaviour;