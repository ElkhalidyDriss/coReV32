---------------------------------------------------------------------------------------
--  Author: Driss Elkhalidy , an embedded systems engineering student @INPT          --
--  Description : rv_decoder testbench                                               -- 
---------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.rv_package.all;


entity rv_decoder_tb is 
end entity;

architecture rv_decoder_tb_arch of rv_decoder_tb is

signal instr_data_tb           : std_logic_vector(31 downto 0);
signal reg_file_raddr1_tb      : std_logic_vector(4 downto 0);
signal reg_file_raddr2_tb      : std_logic_vector(4 downto 0);
signal reg_file_waddr_tb       : std_logic_vector(4 downto 0);  
signal reg_file_wdata_tb       : std_logic_vector(31 downto 0);
signal reg_file_wdata_src_tb   : std_logic_vector(2 downto 0);
signal reg_file_r1_en_tb       : std_logic;
signal reg_file_r2_en_tb       : std_logic;
signal reg_file_we_tb          : std_logic; 
signal branch_t_tb             : std_logic_vector(2 downto 0); -- branch type (BEQ, BNE, BLT, BGE, BLTU, BGEU)
signal jump_t_tb               : std_logic;--Jump type
signal alu_operand_a_src_tb    : std_logic_vector(2 downto 0); -- ALU operand A source
signal alu_operand_b_src_tb    : std_logic_vector(2 downto 0); -- ALU operand B source
signal alu_op_tb               : std_logic_vector(3 downto 0); -- ALU operation
signal alu_operand_a_val_tb    : std_logic_vector(31 downto 0); -- ALU operand A value
signal alu_operand_b_val_tb    : std_logic_vector(31 downto 0); -- ALU operand B value
signal data_mem_size_tb        : std_logic_vector(2 downto 0); -- Word size to retrieve from memory (byte, short, int)
signal data_mem_we_tb          : std_logic; -- Data memory write enable
signal data_mem_en_tb          : std_logic; -- Data memory enable
signal csr_addr_tb             : std_logic_vector(11 downto 0);
signal csr_wdata_src_tb        : std_logic_vector(1 downto 0);
signal pc_next_src_tb          : std_logic_vector(2 downto 0);
signal imm_extended_tb         : std_logic_vector(31 downto 0); -- Extended immediate value  

component rv_decoder 
        port (
              --instruction
              instr_data   : in std_logic_vector(31 downto 0);
              --Register file 
              reg_file_raddr1    : out std_logic_vector(4 downto 0);
              reg_file_raddr2    : out std_logic_vector(4 downto 0);
              reg_file_waddr     : out std_logic_vector(4 downto 0);  
              reg_file_wdata     : out std_logic_vector(31 downto 0);
              reg_file_wdata_src : out std_logic_vector(2 downto 0);
              reg_file_r1_en     : out std_logic;
              reg_file_r2_en     : out std_logic;
              reg_file_we        : out std_logic;
              --Branch/JUMP  
              branch_t : out std_logic_vector(2 downto 0);--branch type (BEQ , BNE , BLT , BGE , BLTU , BGEU)
              jump_t   : out std_logic;--jump type
                                       -- '0' JAL ; '1' JALR
              --ALU
              alu_operand_a_src     : out std_logic_vector(2 downto 0);--alu operand a source 
              alu_operand_b_src     : out std_logic_vector(2 downto 0);
              alu_op                : out std_logic_vector(3 downto 0);--alu operation
              alu_operand_a_val     : out std_logic_vector(31 downto 0);--alu operand a value
              alu_operand_b_val     : out std_logic_vector(31 downto 0);--alu operand b value
              --Data Memory
              data_mem_size : out std_logic_vector(2 downto 0); -- word size to be retrieved from memory (byte , short or int)
              data_mem_we        : out std_logic;--data memory write enable
              data_mem_en        : out std_logic;--data memory enable
              --Control & Status registers
              csr_addr : out  std_logic_vector(11 downto 0);
              csr_wdata_src : out std_logic_vector(1 downto 0);
              --fetch unit
              pc_next_src : out std_logic_vector(2 downto 0);
              --Decoded immediate 
              imm_extended : out std_logic_vector(31 downto 0)--extended immediate value    
        );
end component;
        
begin
DUT : rv_decoder
port map (
   instr_data        => instr_data_tb,
   reg_file_raddr1   => reg_file_raddr1_tb,
   reg_file_raddr2   => reg_file_raddr2_tb,
   reg_file_waddr    => reg_file_waddr_tb,
   reg_file_wdata    => reg_file_wdata_tb,
   reg_file_wdata_src => reg_file_wdata_src_tb,
   reg_file_r1_en    => reg_file_r1_en_tb,
   reg_file_r2_en    => reg_file_r2_en_tb,
   reg_file_we       => reg_file_we_tb,
   branch_t          => branch_t_tb,
   jump_t            => jump_t_tb,
   alu_operand_a_src => alu_operand_a_src_tb,
   alu_operand_b_src => alu_operand_b_src_tb,
   alu_op            => alu_op_tb,
   alu_operand_a_val => alu_operand_a_val_tb,
   alu_operand_b_val => alu_operand_b_val_tb,
   data_mem_size     => data_mem_size_tb,
   data_mem_we       => data_mem_we_tb,
   data_mem_en       => data_mem_en_tb,
   csr_addr          => csr_addr_tb,
   csr_wdata_src     => csr_wdata_src_tb,
   pc_next_src       => pc_next_src_tb,
   imm_extended      => imm_extended_tb
);
STIMILUS : process
begin
-- Test 1 : LUI
instr_data_tb <= x"123452B7"; -- lui t0, 0x12345
wait for 10 ns;

-- Test 2 : AUIPC
instr_data_tb <= x"00001317"; -- auipc t1, 0x1
wait for 10 ns;

-- Test 3 : JAL
instr_data_tb <= x"090003EF"; -- jal t2, 1029c <label1>
wait for 10 ns;

-- Test 4 : MV
instr_data_tb <= x"00028413"; -- mv s0, t0
wait for 10 ns;

-- Test 5 : JR
instr_data_tb <= x"00040067"; -- jr s0
wait for 10 ns;

-- Test 6 : BEQZ
instr_data_tb <= x"08000463"; -- beqz zero, 102a0 <label2>
wait for 10 ns;

-- Test 7 : BNE
instr_data_tb <= x"08209463"; -- bne ra, sp, 102a4 <label3>
wait for 10 ns;

-- Test 8 : BLT
instr_data_tb <= x"0820C463"; -- blt ra, sp, 102a8 <label4>
wait for 10 ns;

-- Test 9 : BGE
instr_data_tb <= x"0820D463"; -- bge ra, sp, 102ac <label5>
wait for 10 ns;

-- Test 10 : BLTU
instr_data_tb <= x"0820E463"; -- bltu ra, sp, 102b0 <label6>
wait for 10 ns;

-- Test 11 : BGEU
instr_data_tb <= x"0820F463"; -- bgeu ra, sp, 102b4 <label7>
wait for 10 ns;

-- Test 12 : LB
instr_data_tb <= x"00028403"; -- lb s0, 0(t0)
wait for 10 ns;

-- Test 13 : LH
instr_data_tb <= x"00129483"; -- lh s1, 1(t0)
wait for 10 ns;

-- Test 14 : LW
instr_data_tb <= x"0042A503"; -- lw a0, 4(t0)
wait for 10 ns;

-- Test 15 : LBU
instr_data_tb <= x"0002C583"; -- lbu a1, 0(t0)
wait for 10 ns;

-- Test 16 : LHU
instr_data_tb <= x"0012D603"; -- lhu a2, 1(t0)
wait for 10 ns;

-- Test 17 : SB
instr_data_tb <= x"00828023"; -- sb s0, 0(t0)
wait for 10 ns;

-- Test 18 : SH
instr_data_tb <= x"009290A3"; -- sh s1, 1(t0)
wait for 10 ns;

-- Test 19 : SW
instr_data_tb <= x"00A2A223"; -- sw a0, 4(t0)
wait for 10 ns;

-- Test 20 : LI
instr_data_tb <= x"00500093"; -- li ra, 5
wait for 10 ns;

-- Test 21 : SLTI
instr_data_tb <= x"00A0A113"; -- slti sp, ra, 10
wait for 10 ns;

-- Test 22 : SLTIU
instr_data_tb <= x"00A0B193"; -- sltiu gp, ra, 10
wait for 10 ns;

-- Test 23 : XORI
instr_data_tb <= x"0030C213"; -- xori tp, ra, 3
wait for 10 ns;

-- Test 24 : ORI
instr_data_tb <= x"0020E293"; -- ori t0, ra, 2
wait for 10 ns;

-- Test 25 : ANDI
instr_data_tb <= x"0010F313"; -- andi t1, ra, 1
wait for 10 ns;

-- Test 26 : SLLI
instr_data_tb <= x"00109393"; -- slli t2, ra, 0x1
wait for 10 ns;

-- Test 27 : SRLI
instr_data_tb <= x"0010D413"; -- srli s0, ra, 0x1
wait for 10 ns;

-- Test 28 : SRAI
instr_data_tb <= x"4010D493"; -- srai s1, ra, 0x1
wait for 10 ns;

-- Test 29 : ADD
instr_data_tb <= x"00208533"; -- add a0, ra, sp
wait for 10 ns;

-- Test 30 : SUB
instr_data_tb <= x"401105B3"; -- sub a1, sp, ra
wait for 10 ns;

-- Test 31 : SLL
instr_data_tb <= x"00209633"; -- sll a2, ra, sp
wait for 10 ns;

-- Test 32 : SLT
instr_data_tb <= x"0020A6B3"; -- slt a3, ra, sp
wait for 10 ns;

-- Test 33 : SLTU
instr_data_tb <= x"0020B733"; -- sltu a4, ra, sp
wait for 10 ns;

-- Test 34 : XOR
instr_data_tb <= x"0020C7B3"; -- xor a5, ra, sp
wait for 10 ns;

-- Test 35 : SRL
instr_data_tb <= x"0020D833"; -- srl a6, ra, sp
wait for 10 ns;

-- Test 36 : SRA
instr_data_tb <= x"4020D8B3"; -- sra a7, ra, sp
wait for 10 ns;

-- Test 37 : OR
instr_data_tb <= x"0020E933"; -- or s2, ra, sp
wait for 10 ns;

-- Test 38 : AND
instr_data_tb <= x"0020F9B3"; -- and s3, ra, sp
wait;

end process;
end architecture;