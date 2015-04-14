--Computer Org. and Arch. Project Part 2
--Tai Hung (Henry) Lu, Saki Kajita, Jeffrey Tichelman, Francois Parent
--Description: Top level entity description for Part 2. Connects everything together

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

Entity part3 is
	Generic (
		         File_Address_Read : string :="Init.dat";
		         File_Address_Write : string :="MemCon.dat";
		         Mem_Size_in_Word : integer:=1024;	
		         Num_Bytes_in_Word: integer:=4;
		         Num_Bits_in_Byte: integer := 8; 
		         Read_Delay: integer:=0; 
		         Write_Delay:integer:=0
	);
	
	Port (
		         clock : in std_logic;
		         initialize : in std_logic;
		         dump : in std_logic
	);
end part3;

Architecture implementation of part3 is
	--Component declarations
	--Fetch Stage
	Component fetch_stage is 
		Port (
			clock: in std_logic;
			fetch_en : in std_logic;
			
			--Memory ports
			address_mem: out integer;
			read_en : out std_logic;
			read_ready : in std_logic;
			data_mem : in std_logic_vector((Num_Bytes_in_Word*Num_Bits_in_Byte)-1 downto 0);
			
			--Branch ports
			pc_in : in integer;
			is_branch : in std_logic;
			hazard : out std_logic;
			
			--Output ports
			instruction_out : out std_logic_vector(31 downto 0);
			pc_out : out integer;
			fetch_ready : out std_logic
		);
	End component;
	
	--ID stage
	Component instruction_decode is
		port( 	instruction		:	in std_logic_vector(31 downto 0);
		wb_addr	:	in std_logic_vector(4 downto 0);
		wb_val	:	in std_logic_vector(31 downto 0);
		en, wb_en, clock : in std_logic;
		command	:	out std_logic_vector(5 downto 0);
		d_register, shift : out std_logic_vector (4 downto 0);
		Address	: out std_logic_vector(25 downto 0);
		s_register, t_register, immediate	:	out std_logic_vector(31 downto 0);
		npc_in : in integer;
		instruction_out: out std_logic_vector(31 downto 0);
		npc_out : out integer;
		is_branch : out std_logic);
	END component;
		
	--EX stage
	Component execute is
		port( 
		enable			: in std_logic;
		clock 			: in std_logic;
		op_code			: in std_logic_vector(5 downto 0);
		d_register		: in std_logic_vector(4 downto 0);
		shift 			: in std_logic_vector(4 downto 0);
		address			: in std_logic_vector(25 downto 0);
		s_register		: in std_logic_vector(31 downto 0);
		t_register		: in std_logic_vector(31 downto 0);
		immediate	   : in std_logic_vector(31 downto 0);
		instruction_in : in std_logic_vector(31 downto 0);
		npc_in 			: in integer;
		ALU_output  	: out std_logic_vector(31 downto 0);
		B_operand 		: out std_logic_vector(31 downto 0);
		branch_cond		: out std_logic;
		opcode_out : out std_logic_vector(5 downto 0);
		instruction_out	: out std_logic_vector(31 downto 0);
		npc_out 		: out integer
	  );
	  
	 end component; 
	
	--MEM stage
	Component mem is
		PORT (	CLK : in std_logic;
			B : in std_logic_vector(31 downto 0);
			ALU_Output : in std_logic_vector(31 downto 0);
			DATA_MEMORY : inout std_logic_vector(31 downto 0);
			ENABLE : in std_logic;
			COND : in std_logic;
			READ_READY, WRITE_DONE : in std_logic;
			NPC : in integer;
			INSTRUCTION : in std_logic_vector(5 downto 0);
			INSTRUCTION_IN : in std_logic_vector(31 downto 0);
			PC : out integer;
			READ_EN, WRITE_EN, WORD_BYTE_MEM : out std_logic;
			ADDRESS_MEM : out integer;
			LMD : out std_logic_vector(31 downto 0);
			ALU_PASS : out std_logic_vector(31 downto 0);
			INSTRUCTION_OUT : out std_logic_vector (31 downto 0);
			BRANCH_RESOLVED : out std_logic
		);
	end component;
	
	--WB stage
	Component writeback_stage is
		Generic (
		Mem_Size_in_Word : integer:=1024;	
		Num_Bytes_in_Word: integer:=4;
		Num_Bits_in_Byte: integer := 8; 
		Read_Delay: integer:=0; 
		Write_Delay:integer:=0
	);
		Port (
		clock : in std_logic;
		write_back_en : in std_logic;
		from_mem : in std_logic_vector (31 downto 0);
		from_alu : in std_logic_vector (31 downto 0);
		instruction: in std_logic_vector (31 downto 0);
		
		write_data : out std_logic_vector (31 downto 0);
		reg_address : out std_logic_vector (4 downto 0);
		reg_enable : out std_logic
	);
	end component;
	
	--Main memory component
	Component Main_memory is
		generic (
				File_Address_Read : string :="Init.dat";
				File_Address_Write : string :="MemCon.dat";
				Mem_Size_in_Word : integer:=1024;	
				Num_Bytes_in_Word: integer:=4;
				Num_Bits_in_Byte: integer := 8; 
				Read_Delay: integer:=0; 
				Write_Delay:integer:=0
			 );
		port (
				clk : in std_logic;
				address : in integer;
				Word_Byte: in std_logic; -- when '1' you are interacting with the memory in word otherwise in byte
				we : in std_logic;
				wr_done:out std_logic; --indicates that the write operation has been done.
				re :in std_logic;
				rd_ready: out std_logic; --indicates that the read data is ready at the output.
				data : inout std_logic_vector((Num_Bytes_in_Word*Num_Bits_in_Byte)-1 downto 0);        
				initialize: in std_logic;
				dump: in std_logic
			 );		
	End Component;
	
	--Memory controller component
	component mem_controller is
		Port(
			clock : in std_logic;
			
			--Ports from IF stage
			address_if : in integer;
			read_en_if : in std_logic;
			rd_ready_if : out std_logic;
			data_if : out std_logic_vector((Num_Bytes_in_Word*Num_Bits_in_Byte)-1 downto 0);  
			
			--Ports from MEM stage
			address_mem : in integer;
			wordbyte_mem : in std_logic;
			write_en_mem : in std_logic;
			read_en_mem : in std_logic;
			wr_done_mem : out std_logic;
			rd_ready_mem : out std_logic;
			data_mem : inout std_logic_vector((Num_Bytes_in_Word*Num_Bits_in_Byte)-1 downto 0); 
		
			--Ports to main memory
			address_out : out integer;
			word_byte_out : out std_logic;
			write_en_out : out std_logic;
			wr_done_in : in std_logic;
			read_en_out : out std_logic;
			rd_ready_in : in std_logic;
			data_inout : inout std_logic_vector((Num_Bytes_in_Word*Num_Bits_in_Byte)-1 downto 0)
		);
	end component;
	
	--Controller component
	Component controller is
	   PORT (	clock : in std_logic;
	    IF_ready: in std_logic;
			IF_en, ID_en, EX_en, MEM_en, WB_en :  out std_logic;
			hazard : in std_logic;
			is_branch, branch_resolved : in std_logic;
			stall_fetch : out std_logic
		);
	end component;
	
	--IF/ID registers
	Component if_id_reg is
	PORT (	CLK : in std_logic;
	
			-- IF outputs
			instruction_in : in std_logic_vector(31 downto 0);
			npc_in : in  integer;
			
			-- ID inputs
			instruction_out : out std_logic_vector(31 downto 0);
			
			-- Message passing
			npc_out : out integer
		);
	End component;
	
	--ID/EX registers
	Component id_ex_reg is
	PORT (	CLK : in std_logic;
	
			-- Outputs of ID
			command_in : in std_logic_vector(5 downto 0);
			d_reg_in : in std_logic_vector(4 downto 0);
			shift_in : in std_logic_vector(4 downto 0);
			address_in : in std_logic_vector(25 downto 0);
			s_reg_in: in std_logic_vector(31 downto 0);
			t_reg_in : in std_logic_vector(31 downto 0);
			imm_in : in std_logic_vector(31 downto 0);
			instruction_in : in std_logic_vector(31 downto 0);
			
			-- Inputs to EX
			op_code : out std_logic_vector(5 downto 0);
			d_reg_out : out std_logic_vector(4 downto 0);
			shift_out : out std_logic_vector(4 downto 0);
			address_out : out std_logic_vector(25 downto 0);
			s_reg_out : out std_logic_vector(31 downto 0);
			t_reg_out : out std_logic_vector(31 downto 0);
			imm_out  : out std_logic_vector(31 downto 0);
			instruction_out : out std_logic_vector(31 downto 0);
			
			-- Additional message passing
			npc_in : in integer;
			npc_out : out integer
		);
	End component;
	
	--EX/MEM registers
	Component ex_mem_reg is
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
	End component;
	
	--MEM/WB registers
	Component mem_wb_reg is
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
	End component;
	
	--Signal Declarations
	signal init_signal : std_logic;
	signal dump_signal: std_logic;
	
	--Fetch Signals
	signal fetch_enable : std_logic;
	signal pc_in : integer := 0;
	signal instruction_if : std_logic_vector(31 downto 0);
	signal npc_if: integer;
	signal address_if : integer;
	signal read_en_if : std_logic;
	signal read_ready_if : std_logic;
	signal data_if_signal : std_logic_vector((Num_Bytes_in_Word*Num_Bits_in_Byte)-1 downto 0); 
	signal data_if_temp : std_logic_vector((Num_Bytes_in_Word*Num_Bits_in_Byte)-1 downto 0); 
	 
	-- Decode signals
	signal wb_to_register_address : std_logic_vector(4 downto 0);
	signal wb_to_register_data : std_logic_vector(31 downto 0);
	signal wb_to_register_enable : std_logic;
	signal decode_enable : std_logic;
	signal op_code : std_logic_vector(5 downto 0);
	signal d_reg : std_logic_vector(4 downto 0);
	signal shift : std_logic_vector(4 downto 0);
	signal address : std_logic_vector(25 downto 0);
	signal s_reg, t_reg, imm : std_logic_vector(31 downto 0);
	
	-- Execute signals
	signal execute_enable : std_logic;
	signal branch_cond : std_logic;
	signal alu_out : std_logic_vector(31 downto 0);
	signal b_operand : std_logic_vector(31 downto 0);
	
	-- Memory signals
	signal mem_enable : std_logic;
	signal instruction : integer;
	signal npc_mem : integer;
	signal mem_output : std_logic_vector(31 downto 0);
	signal alu_pass_signal: std_logic_vector(31 downto 0);
	signal address_mem : integer;
	signal data_mem : std_logic_vector((Num_Bytes_in_Word*Num_Bits_in_Byte)-1 downto 0); 
	signal read_ready_mem : std_logic;
	signal wr_done_mem : std_logic;
	signal read_en_mem : std_logic;
	signal write_en_mem : std_logic;
	signal wordbyte_mem : std_logic;
	
	-- Writeback signals
	signal writeback_enable : std_logic;
	signal write_data : std_logic_vector(31 downto 0);
	signal reg_address : std_logic_vector (4 downto 0);
	
	--Memory controller signals
	signal address_out : integer;
	signal word_byte_out : std_logic;
	signal write_en_out : std_logic;
	signal wr_done_in : std_logic;
	signal read_en_out : std_logic;
	signal rd_ready_in : std_logic;
	signal data_inout : std_logic_vector((Num_Bytes_in_Word*Num_Bits_in_Byte)-1 downto 0);
	
	--IF/ID signals
	signal reg_instruction_IF_in: std_logic_vector (31 downto 0);
	signal reg_npc_in : integer;
	signal reg_instruction_ID: std_logic_vector (31 downto 0);
	signal reg_npc_out : integer;
	
	--ID/EX signals
	signal reg_command_in :  std_logic_vector(5 downto 0);
	signal reg_d_in :  std_logic_vector(4 downto 0);
	signal reg_shift_in :  std_logic_vector(4 downto 0);
	signal reg_address_in :  std_logic_vector(25 downto 0);
	signal reg_s_in:  std_logic_vector(31 downto 0);
	signal reg_t_in :  std_logic_vector(31 downto 0);
	signal reg_imm_in :  std_logic_vector(31 downto 0);
	signal reg_instruction_in1 :  std_logic_vector(31 downto 0);
	
	signal reg_op_code :  std_logic_vector(5 downto 0);
	signal reg_d_out :  std_logic_vector(4 downto 0);
	signal reg_shift_out :  std_logic_vector(4 downto 0);
	signal reg_address_out :  std_logic_vector(25 downto 0);
	signal reg_s_out :  std_logic_vector(31 downto 0);
	signal reg_t_out :  std_logic_vector(31 downto 0);
	signal reg_imm_out  :  std_logic_vector(31 downto 0);
	signal reg_instruction_out1 :  std_logic_vector(31 downto 0);
	signal reg_npc_in1 :  integer;
	signal reg_npc_out1 :  integer;
	
	--EX/MEM signals
	signal reg_ALU_output :  std_logic_vector(31 downto 0);
	signal reg_B_operand :  std_logic_vector(31 downto 0);
	signal reg_branch_cond :  std_logic;
	signal reg_B :  std_logic_vector(31 downto 0);
	signal reg_ALU_output_to_mem :  std_logic_vector(31 downto 0);
	signal reg_cond_out :  std_logic;
	signal reg_NPC_out2 :  integer;
	signal reg_NPC_in2 :  integer;
	signal reg_opcode_in :  std_logic_vector(5 downto 0);
	signal reg_opcode_out :  std_logic_vector(5 downto 0);
	signal reg_instruction_in2 :  std_logic_vector(31 downto 0);
	signal reg_instruction_out2:  std_logic_vector(31 downto 0);
	signal opcode : std_logic_vector(5 downto 0);

	--MEM/WB signals
	signal reg_LMD_in :  std_logic_vector(31 downto 0);
	signal reg_ALU_pass :  std_logic_vector(31 downto 0);
	signal reg_from_alu :  std_logic_vector(31 downto 0);
	signal reg_from_mem :  std_logic_vector(31 downto 0);
	signal reg_instruction_in3 :  std_logic_vector(31 downto 0);
	signal reg_instruction_out3 :  std_logic_vector(31 downto 0);
		
	--Temporary signals (for testing)
	signal temp1: std_logic_vector (31 downto 0);
	signal temp2 : integer := 0;
	
	--Ready Signals
	signal if_ready : std_logic;
	signal id_ready : std_logic;
	signal ex_ready : std_logic;
	signal mem_ready : std_logic;
	signal wb_ready : std_logic;
	
	--Control signals
	signal is_branch : std_logic;
	signal branch_resolved : std_logic;
	signal stall_fetch : std_logic;
	signal fetch_hazard : std_logic;
	
	Begin
		
		--Port maps for each of the components

		IF_stage: fetch_stage PORT MAP (
			       clock			=> clock,
			       fetch_en 	   => fetch_enable,
			       
			       --Memory ports
			       address_mem	=> address_if,
			       read_en 		=> read_en_if,
			       read_ready 	=> read_ready_if,
			       data_mem 	   => data_if_signal,
			       
			       --Branch ports
			       pc_in		 	=> temp2,
			       is_branch 	   => stall_fetch,
			       hazard        => fetch_hazard,
			       
			       --Output ports
			       instruction_out => reg_instruction_IF_in,
			       pc_out 			  => reg_npc_in,
			       fetch_ready 	  => if_ready
		);
		
		IF_ID_register: if_id_reg PORT MAP(
					 CLK 				  => clock,
			
					 -- from IF
					 instruction_in  => reg_instruction_IF_in,
					 npc_in 			  => reg_npc_in,
					 
					 -- to ID
					 instruction_out => reg_instruction_ID,
					 
					 -- Message passing
					 npc_out         => reg_npc_out
		);
	
		ID_stage: instruction_decode PORT MAP(
				  	 instruction		 => reg_instruction_ID,
				  	 wb_addr				 => wb_to_register_address,
				  	 wb_val				 => wb_to_register_data,
				  	 en					 => decode_enable,
					 wb_en				 => wb_to_register_enable,
					 clock  				 => clock,
				  	 command				 => reg_command_in,
				  	 d_register        => reg_d_in,
					 shift 				 => reg_shift_in,
				  	 Address				 => reg_address_in,
				  	 s_register			 => reg_s_in,
					 t_register 		 => reg_t_in,
					 immediate	  		 => reg_imm_in,
				  	 npc_in 				 => reg_npc_out,
				  	 instruction_out	 => reg_instruction_in1,
				  	 npc_out				 => reg_npc_in1,
				  	 is_branch			 => is_branch
					 );
										
--		ID_stage: instruction_decode port map (	instruction=>reg_instruction_ID, wb_addr=>wb_to_register_address, wb_val=>wb_to_register_data,
--												en=>decode_en, wb_en=>wb_en, clock=>clock, command=>reg_command_in, d_register=>reg_d_reg_in, 
--												shift=>reg_shift_in, Address=>reg_address_in, s_register=>reg_s_reg_in, t_register=>reg_t_reg_in, immediate=>reg_imm_in,
--												npc_in=>reg_npc_out, instruction_out=>reg_instruction_in1, npc_out=>reg_npc_in1, is_branch=>is_branch);
--												
		ID_EX_register: id_ex_reg PORT MAP(	
					 CLK 					=> clock,
	
					 -- Outputs of ID
					 command_in 		=> reg_command_in,
					 d_reg_in 			=> reg_d_in,
					 shift_in 			=> reg_shift_in,
					 address_in 		=> reg_address_in,
					 s_reg_in			=> reg_s_in,
					 t_reg_in 			=> reg_t_in,
					 imm_in 				=> reg_imm_in,
					 instruction_in 	=> reg_instruction_in1,
					 
					 -- Inputs to EX
					 op_code 			=> reg_op_code,
					 d_reg_out 			=> reg_d_out,
					 shift_out 			=> reg_shift_out,
					 address_out 		=> reg_address_out,
					 s_reg_out 			=> reg_s_out,
					 t_reg_out 			=> reg_t_out,
					 imm_out  			=> reg_imm_out,
					 instruction_out  => reg_instruction_out1,
					 
					 -- Additional message passing
					 npc_in 				=> reg_npc_in1, 
					 npc_out 			=> reg_npc_out1
		);
		
--		id_ex_register : id_ex_reg port map (	clock, reg_command_in, reg_d_reg_in, reg_shift_in, reg_address_in, reg_s_reg_in, reg_t_reg_in,
--												reg_imm_in, reg_instruction_in1, reg_op_code, reg_d_reg_out, reg_shift_out, reg_address_out, reg_s_reg_out,
--												reg_t_reg_out, reg_imm_out, reg_instruction_out1, reg_npc_in1, reg_npc_out1);
												
		EX_stage: execute PORT MAP( 
					 enable			   => execute_enable,
					 clock 			   => clock,
					 
					 -- EX inputs from ID
					 op_code			   => reg_op_code,
					 d_register		   => reg_d_out,
					 shift 			   => reg_shift_out,
					 address			   => reg_address_out,
					 s_register		   => reg_s_out,
					 t_register		   => reg_t_out,
					 immediate	      => reg_imm_out,
					 instruction_in   => reg_instruction_out1,
					 npc_in 			   => reg_npc_out1,
					 
					 -- EX outputs
					 ALU_output  	   => reg_ALU_output,
					 B_operand 		   => reg_B_operand,
					 branch_cond	   => reg_branch_cond,
					 opcode_out	      => reg_opcode_in,
					 instruction_out  => reg_instruction_in2,
					 npc_out 		   => reg_npc_in2 
	  );										
--		EX_stage: execute port map (	enable=>execute_en, clock=>clock, op_code=>reg_op_code,d_register=>reg_d_reg_out, shift=>reg_shift_out,
--										address=>reg_address_out, s_register=>reg_s_reg_out, t_register=>reg_t_reg_out, immediate=>reg_imm_out, ALU_output=>reg_alu_output,
--										B_operand=>reg_b_operand, branch_cond=>reg_branch_cond,instruction_in=>reg_instruction_out1, opcode_out=>reg_opcode_in , instruction_out=>reg_instruction_in2,
--										npc_in=>reg_npc_out1, npc_out=>reg_npc_in2);
		
		ex_mem_register: ex_mem_reg PORT MAP (	
					 CLK               => clock,
			 
					 -- EX outputs
					 ALU_output        => reg_ALU_output,
					 B_operand         => reg_B_operand,
					 branch_cond       => reg_branch_cond,
					 
					 -- MEM inputs
					 B                 => reg_B,
					 ALU_output_to_mem => reg_ALU_output_to_MEM,
					 cond_out          => reg_cond_out,
					 NPC_out           => reg_NPC_out2,
					 
					 -- Messages
					 NPC_in            => reg_NPC_in2,
					 opcode_in         => reg_opcode_in,
					 opcode_out        => reg_opcode_out,
					 instruction_in    => reg_instruction_in2,
					 instruction_out   => reg_instruction_out2
		);
		
--		ex_mem_register : ex_mem_reg port map (clock, reg_alu_output, reg_b_operand, reg_branch_cond, reg_b, reg_alu_output_to_mem,
--												reg_cond_out, reg_NPC_out2, reg_NPC_in2, reg_opcode_in, reg_opcode_out,
--												reg_instruction_in2, reg_instruction_out2);
		
		MEM_stage: mem PORT MAP(	
					 CLK 					=> clock,
					 B 					=> reg_b,
					 ALU_Output 		=> reg_ALU_output_to_MEM,
					 DATA_MEMORY 		=> data_MEM,
					 ENABLE 				=> MEM_enable,
					 COND					=> reg_cond_out,
					 READ_READY			=> read_ready_mem,
					 WRITE_DONE 		=> wr_done_mem,
					 NPC				 	=> reg_npc_out2,
					 INSTRUCTION 		=> reg_opcode_out,
					 INSTRUCTION_IN 	=> reg_instruction_out2,
					 PC 					=> temp2,
					 READ_EN				=> read_en_mem, 
					 WRITE_EN			=> write_en_mem,
					 WORD_BYTE_MEM 	=> wordbyte_mem,
					 ADDRESS_MEM 		=> address_mem,
					 LMD 					=> reg_LMD_in,
					 ALU_PASS 			=> reg_ALU_pass,
					 INSTRUCTION_OUT 	=> reg_instruction_in3,
					 BRANCH_RESOLVED 	=> branch_resolved
		);
		
--		MEM_stage : mem port map (clock, reg_b, reg_alu_output_to_mem, data_mem, mem_en, reg_cond_out, rd_ready_mem, wr_done_mem, reg_npc_out2, reg_opcode_out, reg_instruction_out2,
--									temp2, read_en_mem, write_en_mem, wordbyte_mem, address_mem, reg_lmd_in, reg_alu_pass, reg_instruction_in3, branch_resolved);
		
			
		MEM_WR_register: mem_wb_reg PORT MAP(
					 CLK 					=> clock,
	
					 -- MEM outputs
					 LMD_in 				=> reg_LMD_in,
					 ALU_pass 			=> reg_ALU_pass,
					 
					 -- WB inputs
					 from_alu 			=> reg_from_ALU,
					 from_mem 			=> reg_from_MEM,			
					 
					 -- Messages
					 instruction_in 	=> reg_instruction_in3,
					 instruction_out 	=> reg_instruction_out3
		);
		
--		mem_wb_register : mem_wb_reg port map (clock, reg_lmd_in, reg_alu_pass, reg_from_alu, reg_from_mem, reg_instruction_in3, reg_instruction_out3);		
		
			--WB stage
		WB_stage: writeback_stage PORT MAP (
					 clock 				=> clock,
					 write_back_en 	=> writeback_enable,
					 from_mem 			=> reg_from_MEM,
					 from_alu 			=> reg_from_ALU,
					 instruction		=> reg_instruction_out3,
					 
					 write_data 		=> wb_to_register_data,
					 reg_address 		=> wb_to_register_address,
					 reg_enable 		=> wb_to_register_enable
		);


--		WB_stage: writeback_stage port map (	reg_enable=>wb_en, clock=>clock, from_mem=>reg_from_mem, from_alu=>reg_from_alu, instruction=>reg_instruction_out3,
--												reg_address=>wb_to_register_address, write_data=>wb_to_register_data, write_back_en=>writeback_enable);
	
	--Main memory component
		Memory_module: main_memory PORT MAP (
					 clk 					=> clock,
					 address 			=> address_out,
					 Word_Byte			=> word_byte_out,
					 we 					=> write_en_out,
					 wr_done				=> wr_done_in,
					 re				 	=> read_en_out,
					 rd_ready			=> rd_ready_in,
					 data 				=> data_inout,
					 initialize			=> initialize,
					 dump					=> dump
		);		
	
--		memory_module : main_memory port map ( 	clock, address_out, word_byte_out, write_en_out, wr_done_in, read_en_out, rd_ready_in,
--												data_inout, initialize, dump); 
	
	--Memory controller component
	
		MEM_control: mem_controller PORT MAP(
					 clock 				=> clock,
					 
					 --Ports from IF stage
					 address_if 		=> address_if,
					 read_en_if 		=> read_en_if,
					 rd_ready_if 		=> read_ready_if,
					 data_if 			=> data_if_signal,
					 
					 --Ports from MEM stage
					 address_mem 		=> address_mem,
					 wordbyte_mem 		=> wordbyte_mem,
					 write_en_mem 		=> write_en_mem,
					 read_en_mem 		=> read_en_mem,
					 wr_done_mem 		=> wr_done_mem,
					 rd_ready_mem 		=> read_ready_mem,
					 data_mem 			=> data_mem,
				 
					 --Ports to main memory
					 address_out 		=> address_out,
					 word_byte_out 	=> word_byte_out,
					 write_en_out 		=> write_en_out,
					 wr_done_in 		=> wr_done_in,
					 read_en_out 		=> read_en_out,
					 rd_ready_in 		=> rd_ready_in,
					 data_inout 		=> data_inout
		);
	
--		mem_con : mem_controller port map (	clock, address_if, read_en_if, rd_ready_if, data_if_signal, address_mem, wordbyte_mem,
--											write_en_mem, read_en_mem, wr_done_mem, rd_ready_mem, data_mem, 
--											address_out, word_byte_out, write_en_out, wr_done_in, read_en_out,
--											rd_ready_in, data_inout);
	
	--Controller component
	   Control: controller PORT MAP (	
					 clock 			  => clock,
					 IF_ready		  => IF_ready,
					 IF_en			  => fetch_enable,
					 ID_en           => decode_enable,
					 EX_en 			  => execute_enable,
					 MEM_en			  => mem_enable,
					 WB_en 			  => writeback_enable,
					 hazard    => fetch_hazard,
					 is_branch		  => is_branch,
					 branch_resolved => branch_resolved,
					 stall_fetch     => stall_fetch
		);

--		con: controller port map ( clock => clock, IF_en =>fetch_enable, ID_en=>decode_en, EX_en=>execute_en,
--	                              MEM_en=>mem_en, WB_en=>writeback_enable, IF_ready => if_ready, is_branch => is_branch, 
--											branch_resolved => branch_resolved, stall_fetch => stall_fetch);
	
End implementation;