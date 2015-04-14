LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity controller is
	PORT (	clock : in std_logic;
	    IF_ready: in std_logic;
			IF_en, ID_en, EX_en, MEM_en, WB_en :  out std_logic;
			hazard : in std_logic;
			is_branch, branch_resolved : in std_logic;
			branch_done : out std_logic;
			stall_fetch : out std_logic
		);
end controller;

architecture behaviour of controller is
  
  signal sf : std_logic := '0'; 
  
  signal new_hazard : std_logic := '0';
  signal count : integer;
  
	Begin
		--ID_en <= IF_ready;
		--EX_en <= ID_ready;
		--MEM_en <= EX_ready;
		--WB_en <= MEM_ready;
		
	 IF_en <= '1';
	 ID_en <=IF_READY;
	 EX_en <='1';
	 MEM_en <='1';
	 WB_en <='1';



-- Stall fetch when decode detects a branch instruction, tells fetch to insert noops
-- until the branch is resolved after the execute stage
		stallFetch : process(clock)
		  Begin
		    if(clock'EVENT and clock ='1') then
		     if(sf='0' AND is_branch = '1') then
		        sf <= '1';
		        
		     elsif (sf = '1' AND branch_resolved ='1') then
		        sf <= '0';
		        
		     elsif( sf='1'AND branch_resolved='0') then
		        sf <= '1';
		     
		     end if;
		    end if;
		 end process;
		
		stall_fetch <= sf;
		
		
--  We attempted to implement structural hazard handling using this block
--  by "disabling" the pipeline and allowing the memory access instruction
--  to proceed on its own
		
--		PipelineControl :  process(clock)
--		  Begin
--		     if(clock'EVENT and clock='1') then
--		      if(hazard='0') then
--		        IF_en <= '1';
--		        ID_en <=IF_READY;
--	         	EX_en <='1';
--		        MEM_en <='1';
--		        WB_en <='1';
--		       else
--		         if(new_hazard='0') then
--		          new_hazard<='1';
--		          count<=1;
--		         elsif(count=1) then
--		          IF_en <= '0';
--		          ID_en <='1';
--	         	  EX_en <='1';
--		          MEM_en <='1';
--		          WB_en <='1';
--		          count <=2;
--		         elsif(count=2) then
--		         	IF_en <= '0';
--		          ID_en <='0';
--		          EX_en <='1';
--		          MEM_en <='1';
--		          WB_en <='1';
--		          count<=3;
--		         elsif(count=3) then
--		         	IF_en <= '0';
--		          ID_en <='0';
--		          EX_en <='0';
--		          MEM_en <='1';
--		          WB_en <='1';
--		          count<=4;
--		         elsif(count=4) then
--		         	IF_en <= '0';
--		          ID_en <='0';
--		          EX_en <='0';
--		          MEM_en <='0';
--		          WB_en <='1';
--		          count<=5;
--		         elsif(count=5) then
--   		         IF_en <= '1';
--		          ID_en <=IF_READY;
--	         	  EX_en <='1';
--		          MEM_en <='1';
--		          WB_en <='1';
--		          new_hazard <='0';
--		         else 
--		           count<= count + 1;
--		         end if;
--		      end if;
--		     end if;
--		    end process;
		
end behaviour;