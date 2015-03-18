--Computer Org. and Arch. Project Part 2
--Tai Hung (Henry) Lu, Saki Kajita, Jeffrey Tichelman, Francois Parent
--Description: Top level entity description for Part 2

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

Entity part2 is
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
end part2;

Architecture implementation of part2 is
	--Component declarations
	--Fetch Stage
	Component fetch_stage is 
		Port (
			clock: in std_logic;
			fetch_en : in std_logic;
			--Memory ports
			address_mem: out integer;
--			word_byte_mem : out std_logic;
--			write_en : out std_logic;
--			write_done : in std_logic;
			read_en : out std_logic;
			read_ready : in std_logic;
			data_mem : in std_logic_vector((Num_Bytes_in_Word*Num_Bits_in_Byte)-1 downto 0);
			
			--Branch ports
			pc_in : in integer;
--			instruction_in : in std_logic_vector(31 downto 0);
--			branch_check : in std_logic;
			
			--Output ports
			instruction_out : out std_logic_vector(31 downto 0);
			pc_out : out integer
		);
	End component;
	
	--ID stage
	Component instruction_decode is
		port( 	
			instruction		:	in std_logic_vector(31 downto 0);
			wb_addr	:	in std_logic_vector(4 downto 0);
			wb_val	:	in std_logic_vector(31 downto 0);
			en, wb_en, clock : in std_logic;
			command	:	out std_logic_vector(5 downto 0);
			d_register, shift : out std_logic_vector (4 downto 0);
			Address	: out std_logic_vector(25 downto 0);
			s_register, t_register, immediate	:	out std_logic_vector(31 downto 0)
		);
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
			
			ALU_output  	: out std_logic_vector(31 downto 0);
			B_operand 		: out std_logic_vector(31 downto 0);
			branch_cond		: out std_logic
	  );
	  
	 end component; 
	
	--MEM stage
	Component mem is
		PORT (	
			CLK : in std_logic;
			B : in std_logic_vector(31 downto 0);
			ALU_Output : in std_logic_vector(31 downto 0);
			DATA_MEMORY : inout std_logic_vector(31 downto 0);
			ENABLE : in std_logic;
			COND : in std_logic;
			READ_READY, WRITE_DONE : in std_logic;
			NPC : in integer;
			INSTRUCTION : in std_logic_vector(5 downto 0);
			PC : out integer;
			READ_EN, WRITE_EN, WORD_BYTE_MEM : out std_logic;
			ADDRESS_MEM : out integer;
			LMD : out std_logic_vector(31 downto 0);
			ALU_PASS : out std_logic_vector(31 downto 0)
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
	
	Component controller is
	   PORT (	clock : in std_logic;
			IF_en, ID_en, EX_en, MEM_en, WB_en :  out std_logic
		);
	end component;
	
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
	signal rd_ready_if : std_logic;
	signal data_if_signal : std_logic_vector((Num_Bytes_in_Word*Num_Bits_in_Byte)-1 downto 0); 
	signal data_if_temp : std_logic_vector((Num_Bytes_in_Word*Num_Bits_in_Byte)-1 downto 0); 
	 
	-- Decode signals
	signal wb_address : std_logic_vector(4 downto 0);
	signal wb_data : std_logic_vector(31 downto 0);
	signal wb_en : std_logic;
	signal decode_en : std_logic;
	signal op_code : std_logic_vector(5 downto 0);
	signal d_reg, shift : std_logic_vector(4 downto 0);
	signal address : std_logic_vector(25 downto 0);
	signal s_reg, t_reg, imm : std_logic_vector(31 downto 0);
	
	-- Execute signals
	signal execute_en, branch_cond : std_logic;
	signal alu_out, b_operand : std_logic_vector(31 downto 0);
	
	-- Memory signals
	signal mem_en : std_logic;
	signal instruction : integer;
	signal npc_mem : integer;
	signal mem_output : std_logic_vector(31 downto 0);
	signal alu_pass_signal: std_logic_vector(31 downto 0);
	signal address_mem : integer;
	signal data_mem : std_logic_vector((Num_Bytes_in_Word*Num_Bits_in_Byte)-1 downto 0); 
	signal rd_ready_mem : std_logic;
	signal wr_done_mem : std_logic;
	signal read_en_mem : std_logic;
	signal write_en_mem : std_logic;
	signal wordbyte_mem : std_logic;
	
	-- Writeback signals
	signal write_back_enable : std_logic;
	signal write_data : std_logic_vector(31 downto 0);
	signal reg_address : std_logic_vector (4 downto 0);
	
	--Memory controler signals
	signal address_out : integer;
	signal word_byte_out : std_logic;
	signal write_en_out : std_logic;
	signal wr_done_in : std_logic;
	signal read_en_out : std_logic;
	signal rd_ready_in : std_logic;
	signal data_inout : std_logic_vector((Num_Bytes_in_Word*Num_Bits_in_Byte)-1 downto 0);
	
	Begin
		IF_stage: fetch_stage port map (clock, fetch_enable, address_if, read_en_if, rd_ready_if, data_if_signal,
										pc_in, instruction_if, npc_if);
										
		ID_stage: instruction_decode port map (	instruction=>instruction_if, wb_addr=>wb_address, wb_val=>wb_data,
												en=>decode_en, wb_en=>wb_en, clock=>clock, command=>op_code, d_register=>d_reg, 
												shift=>shift, Address=>address, s_register=>s_reg, t_register=>t_reg, immediate=>imm);
												
		EX_stage: execute port map (	enable=>execute_en, clock=>clock, op_code=>op_code,d_register=>d_reg, shift=>shift,
										address=>address, s_register=>s_reg, t_register=>t_reg, immediate=>imm, ALU_output=>alu_out,
										B_operand=>b_operand, branch_cond=>branch_cond);
										
		MEM_stage: mem port map (	enable=>mem_en, CLK=>clock, B=>b_operand, ALU_Output=>alu_out, DATA_MEMORY=>data_mem, READ_READY=>rd_ready_mem, 
									WRITE_DONE=>wr_done_mem, COND=>branch_cond, NPC=>npc_if, INSTRUCTION=>op_code,
									PC=>pc_in, LMD=>mem_output, READ_EN=>read_en_mem, WRITE_EN=>write_en_mem, WORD_BYTE_MEM=>wordbyte_mem, ADDRESS_MEM=>address_mem,
									ALU_PASS=>alu_pass_signal);
									
		WB_stage: writeback_stage port map (	reg_enable=>wb_en, clock=>clock, from_mem=>mem_output, from_alu=>alu_pass_signal, instruction=>instruction_if,
												reg_address=>wb_address, write_data=>wb_data, write_back_en=>write_back_enable);
												
		memory_module : main_memory port map ( 	clock, address_out, word_byte_out, write_en_out, wr_done_in, read_en_out, rd_ready_in,
												data_inout, initialize, dump); 
												
		mem_con : mem_controller port map (	clock, address_if, read_en_if, rd_ready_if, data_if_signal, address_mem, wordbyte_mem,
											write_en_mem, read_en_mem, wr_done_mem, rd_ready_mem, data_mem, 
											address_out, word_byte_out, write_en_out, wr_done_in, read_en_out,
											rd_ready_in, data_inout);
	  con: controller port map ( clock => clock, IF_en =>fetch_enable, ID_en=>decode_en, EX_en=>execute_en,
	                             MEM_en=>mem_en, WB_en=>write_back_enable);
	
End implementation;