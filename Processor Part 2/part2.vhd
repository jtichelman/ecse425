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
	Component fetch_stage is 
		Port (
			clock: in std_logic;
			
			--Memory ports
			address_mem: out integer;
			word_byte_mem : out std_logic;
			write_en : out std_logic;
			write_done : in std_logic;
			read_en : out std_logic;
			read_ready : in std_logic;
			data_mem : inout std_logic_vector((Num_Bytes_in_Word*Num_Bits_in_Byte)-1 downto 0);
			
			--Branch ports
			pc_in : in integer;
			instruction_in : in std_logic_vector(31 downto 0);
			branch_check : in std_logic;
			
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
			INST : in integer;
			PC : out integer;
			READ_EN, WRITE_EN, WORD_BYTE_MEM : out std_logic;
			ADDRESS_MEM : out integer;
			LMD : out std_logic_vector(31 downto 0)
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
		from_mem : in std_logic_vector (31 downto 0);
		from_alu : in std_logic_vector (31 downto 0);
		instruction: in std_logic_vector (31 downto 0);
		
		write_data : out std_logic_vector (31 downto 0);
		reg_address : out integer range 0 to 31;
		reg_enable : in std_logic
	);
	end component;
	--Signal Declarations
	--Connecting stages together
	
	Begin
	
End implementation;