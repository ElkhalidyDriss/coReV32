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
signal reg_file_wdata_src_tb   : std_logic_vector(2 downto 0);
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
            instr_data    : in std_logic_vector(31 downto 0);
            illegal_instr : out std_logic;
            --Register file 
            reg_file_raddr1    : out std_logic_vector(4 downto 0);
            reg_file_raddr2    : out std_logic_vector(4 downto 0);
            reg_file_waddr     : out std_logic_vector(4 downto 0);  
            reg_file_wdata_src : out std_logic_vector(2 downto 0);
            reg_file_we        : out std_logic;
            --Branch/JUMP  
            branch_t : out std_logic_vector(2 downto 0);--branch type (BEQ , BNE , BLT , BGE , BLTU , BGEU)
            jump_t   : out std_logic;--jump type
                                     -- '0' JAL ; '1' JALR
            --ALU
            alu_operand_a_src     : out std_logic_vector(2 downto 0);--alu operand a source 
            alu_operand_b_src     : out std_logic_vector(2 downto 0);
            alu_op                : out std_logic_vector(3 downto 0);--alu operation
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
   reg_file_wdata_src => reg_file_wdata_src_tb,
   reg_file_we       => reg_file_we_tb,
   branch_t          => branch_t_tb,
   jump_t            => jump_t_tb,
   alu_operand_a_src => alu_operand_a_src_tb,
   alu_operand_b_src => alu_operand_b_src_tb,
   alu_op            => alu_op_tb,
   data_mem_size     => data_mem_size_tb,
   data_mem_we       => data_mem_we_tb,
   data_mem_en       => data_mem_en_tb,
   csr_addr          => csr_addr_tb,
   csr_wdata_src     => csr_wdata_src_tb,
   pc_next_src       => pc_next_src_tb,
   imm_extended      => imm_extended_tb
);
STIMULUS : process
begin
-- Test 1 : LUI
instr_data_tb <= x"123452B7"; -- lui x5, 0x12345

wait for 10 ns;

-- Test 2 : AUIPC
instr_data_tb <= x"00001317"; -- auipc x6, 0x1
wait for 10 ns;

-- Test 3 : JAL
instr_data_tb <= x"090003EF"; -- jal x7, 1029c <label1>
wait for 10 ns;

-- Test 4 : MV
instr_data_tb <= x"00028413"; -- mv x8, x5
wait for 10 ns;

-- Test 5 : JR
instr_data_tb <= x"00040067"; -- jr x8
wait for 10 ns;

-- Test 6 : BEQZ
instr_data_tb <= x"08000463"; -- beqz x0, 102a0 <label2>
wait for 10 ns;

-- Test 7 : BNE
instr_data_tb <= x"08209463"; -- bne x1, x2, 102a4 <label3>
wait for 10 ns;

-- Test 8 : BLT
instr_data_tb <= x"0820C463"; -- blt x1, x2, 102a8 <label4>
wait for 10 ns;

-- Test 9 : BGE
instr_data_tb <= x"0820D463"; -- bge x1, x2, 102ac <label5>
wait for 10 ns;

-- Test 10 : BLTU
instr_data_tb <= x"0820E463"; -- bltu x1, x2, 102b0 <label6>
wait for 10 ns;

-- Test 11 : BGEU
instr_data_tb <= x"0820F463"; -- bgeu x1, x2, 102b4 <label7>
wait for 10 ns;

-- Test 12 : LB
instr_data_tb <= x"00028403"; -- lb x8, 0(x5)
wait for 10 ns;

-- Test 13 : LH
instr_data_tb <= x"00129483"; -- lh x9, 1(x5)
wait for 10 ns;

-- Test 14 : LW
instr_data_tb <= x"0042A503"; -- lw x10, 4(x5)
wait for 10 ns;

-- Test 15 : LBU
instr_data_tb <= x"0002C583"; -- lbu x11, 0(x5)
wait for 10 ns;

-- Test 16 : LHU
instr_data_tb <= x"0012D603"; -- lhu x12, 1(x5)
wait for 10 ns;

-- Test 17 : SB
instr_data_tb <= x"00828023"; -- sb x8, 0(x5)
wait for 10 ns;

-- Test 18 : SH
instr_data_tb <= x"009290A3"; -- sh x9, 1(x5)
wait for 10 ns;

-- Test 19 : SW
instr_data_tb <= x"00A2A223"; -- sw x10, 4(x5)
wait for 10 ns;

-- Test 20 : LI
instr_data_tb <= x"00500093"; -- li x1, 5
wait for 10 ns;

-- Test 21 :
-- Test 21 : LI
instr_data_tb <= x"00500093"; -- li x1, 5
wait for 10 ns;

-- Test 22 : ADDI
instr_data_tb <= x"00500293"; -- addi x5, x0, 5
wait for 10 ns;

-- Test 23 : SLTI
instr_data_tb <= x"0012A313"; -- slti x6, x5, 1
wait for 10 ns;

-- Test 24 : SLTIU
instr_data_tb <= x"0012B393"; -- sltiu x7, x5, 1
wait for 10 ns;

-- Test 25 : XORI
instr_data_tb <= x"0012C413"; -- xori x8, x5, 1
wait for 10 ns;

-- Test 26 : ORI
instr_data_tb <= x"0012E493"; -- ori x9, x5, 1
wait for 10 ns;

-- Test 27 : ANDI
instr_data_tb <= x"0012F513"; -- andi x10, x5, 1
wait for 10 ns;

-- Test 28 : SLLI
instr_data_tb <= x"00129293"; -- slli x5, x5, 1
wait for 10 ns;

-- Test 29 : SRLI
instr_data_tb <= x"00129493"; -- srli x9, x5, 1
wait for 10 ns;

-- Test 30 : SRAI
instr_data_tb <= x"4012D293"; -- srai x5, x5, 1
wait for 10 ns;

-- Test 31 : ADD
instr_data_tb <= x"00A282B3"; -- add x5, x5, x10
wait for 10 ns;

-- Test 32 : SUB
instr_data_tb <= x"40A282B3"; -- sub x5, x5, x10
wait for 10 ns;

-- Test 33 : SLL
instr_data_tb <= x"00A292B3"; -- sll x5, x5, x10
wait for 10 ns;

-- Test 34 : SLT
instr_data_tb <= x"00A2A2B3"; -- slt x5, x5, x10
wait for 10 ns;

-- Test 35 : SLTU
instr_data_tb <= x"00A2B2B3"; -- sltu x5, x5, x10
wait for 10 ns;

-- Test 36 : XOR
instr_data_tb <= x"00A2C2B3"; -- xor x5, x5, x10
wait for 10 ns;

-- Test 37 : SRL
instr_data_tb <= x"00A2D2B3"; -- srl x5, x5, x10
wait for 10 ns;

-- Test 38 : SRA
instr_data_tb <= x"40A2D2B3"; -- sra x5, x5, x10
wait for 10 ns;

-- Test 39 : OR
instr_data_tb <= x"00A2E2B3"; -- or x5, x5, x10
wait for 10 ns;

-- Test 40 : AND
instr_data_tb <= x"00A2F2B3"; -- and x5, x5, x10
wait for 10 ns;

-- Test 41 : JALR
instr_data_tb <= x"00028067"; -- jalr x1, x5, 0
wait for 10 ns;

-- Test 42 : FENCE
instr_data_tb <= x"0000000F"; -- fence
wait for 10 ns;

-- Test 43 : ECALL
instr_data_tb <= x"00000073"; -- ecall
wait for 10 ns;

-- Test 44 : EBREAK
instr_data_tb <= x"00100073"; -- ebreak
wait for 10 ns;

-- Test 45 : CSRRW
instr_data_tb <= x"00000073"; -- csrrw x1, x2, x3 (pseudo instruction)
wait for 10 ns;

-- Test 46 : CSRRS
instr_data_tb <= x"00030073"; -- csrrs x1, x2, x3
wait for 10 ns;

-- Test 47 : CSRRC
instr_data_tb <= x"00070073"; -- csrrc x1, x2, x3
wait for 10 ns;

-- Test 48 : CSRRWI
instr_data_tb <= x"01050073"; -- csrrwi x1, x2, 1
wait for 10 ns;

-- Test 49 : CSRRSI
instr_data_tb <= x"01060073"; -- csrrsi x1, x2, 1
wait for 10 ns;

-- Test 50 : CSRRCI
instr_data_tb <= x"01070073"; -- csrrci x1, x2, 1
wait for 10 ns;

wait;
end process;

end architecture;
		