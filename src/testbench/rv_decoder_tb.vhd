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
signal valid_o_tb              : std_logic :='0';
signal instr_data_tb           : std_logic_vector(31 downto 0) :=(others => '0');
signal illegal_instr_tb        : std_logic :='0';
signal reg_file_raddr1_tb      : std_logic_vector(4 downto 0) :=(others => '0');
signal reg_file_raddr2_tb      : std_logic_vector(4 downto 0) :=(others => '0');
signal reg_file_waddr_tb       : std_logic_vector(4 downto 0) :=(others => '0');  
signal reg_file_wdata_src_tb   : std_logic_vector(2 downto 0) :=(others => '0');
signal reg_file_we_tb          : std_logic :='0'; 
signal branch_t_tb             : std_logic_vector(2 downto 0); -- branch type (BEQ, BNE, BLT, BGE, BLTU, BGEU)
signal jump_t_tb               : std_logic :='0';--Jump type
signal branch_flag_o_tb        : std_logic :='0';
signal alu_operand_a_src_tb    : std_logic_vector(2 downto 0) :=(others => '0'); -- ALU operand A source
signal alu_operand_b_src_tb    : std_logic_vector(2 downto 0) :=(others => '0'); -- ALU operand B source
signal alu_op_tb               : std_logic_vector(3 downto 0) :=(others => '0'); -- ALU operation
signal alu_operand_a_val_tb    : std_logic_vector(31 downto 0) :=(others => '0'); -- ALU operand A value
signal alu_operand_b_val_tb    : std_logic_vector(31 downto 0) :=(others => '0'); -- ALU operand B value
signal data_mem_size_tb        : std_logic_vector(2 downto 0) :=(others => '0'); -- Word size to retrieve from memory (byte, short, int)
signal data_mem_we_tb          : std_logic :='0'; -- Data memory write enable
signal data_mem_en_tb          : std_logic :='0'; -- Data memory enable
signal csr_addr_tb             : std_logic_vector(11 downto 0) :=(others => '0');
signal csr_wdata_src_tb        : std_logic_vector(1 downto 0) :=(others => '0');
signal pc_next_src_tb          : std_logic_vector(2 downto 0) :=(others => '0');
signal imm_extended_tb         : std_logic_vector(31 downto 0) :=(others => '0'); -- Extended immediate value  

component  rv_decoder is 
      port (
            valid_o : out std_logic;
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
            branch_flag_o : out std_logic; --flag to indicate that a branch or jump has been occured 
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
   valid_o           => valid_o_tb,
   illegal_instr     => illegal_instr_tb,
   instr_data        => instr_data_tb,
   reg_file_raddr1   => reg_file_raddr1_tb,
   reg_file_raddr2   => reg_file_raddr2_tb,
   reg_file_waddr    => reg_file_waddr_tb,
   reg_file_wdata_src => reg_file_wdata_src_tb,
   reg_file_we       => reg_file_we_tb,
   branch_t          => branch_t_tb,
   jump_t            => jump_t_tb,
   branch_flag_o     => branch_flag_o_tb,
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
report "Test 1 : LUI" severity NOTE;
wait for 10 ns;

-- Test 2 : AUIPC
instr_data_tb <= x"00001317"; -- auipc x6, 0x1
report "Test 2 : AUIPC" severity NOTE;
wait for 10 ns;

-- Test 3 : JAL
instr_data_tb <= x"090003EF"; -- jal x7, 1029c <label1>
report "Test 3 : JAL" severity NOTE;
wait for 10 ns;

-- Test 4 : JALR
instr_data_tb <= x"00028067"; -- jalr x1, x5, 0
report "Test 4 : JALR" severity NOTE;
wait for 10 ns;

-- Test 5 : BEQ
instr_data_tb <= x"08200063"; -- beq x1, x2, <label>
report "Test 5 : BEQ" severity NOTE;
wait for 10 ns;

-- Test 6 : BNE
instr_data_tb <= x"08209463"; -- bne x1, x2, <label>
report "Test 6 : BNE" severity NOTE;
wait for 10 ns;

-- Test 7 : BLT
instr_data_tb <= x"0820C463"; -- blt x1, x2, <label>
report "Test 7 : BLT" severity NOTE;
wait for 10 ns;

-- Test 8 : BGE
instr_data_tb <= x"0820D463"; -- bge x1, x2, <label>
report "Test 8 : BGE" severity NOTE;
wait for 10 ns;

-- Test 9 : BLTU
instr_data_tb <= x"0820E463"; -- bltu x1, x2, <label>
report "Test 9 : BLTU" severity NOTE;
wait for 10 ns;

-- Test 10 : BGEU
instr_data_tb <= x"0820F463"; -- bgeu x1, x2, <label>
report "Test 10 : BGEU" severity NOTE;
wait for 10 ns;

-- Test 11 : LB
instr_data_tb <= x"00028403"; -- lb x8, 0(x5)
report "Test 11 : LB" severity NOTE;
wait for 10 ns;

-- Test 12 : LH
instr_data_tb <= x"00129483"; -- lh x9, 1(x5)
report "Test 12 : LH" severity NOTE;
wait for 10 ns;

-- Test 13 : LW
instr_data_tb <= x"0042A503"; -- lw x10, 4(x5)
report "Test 13 : LW" severity NOTE;
wait for 10 ns;

-- Test 14 : LBU
instr_data_tb <= x"0002C583"; -- lbu x11, 0(x5)
report "Test 14 : LBU" severity NOTE;
wait for 10 ns;

-- Test 15 : LHU
instr_data_tb <= x"0012D603"; -- lhu x12, 1(x5)
report "Test 15 : LHU" severity NOTE;
wait for 10 ns;

-- Test 16 : SB
instr_data_tb <= x"00828023"; -- sb x8, 0(x5)
report "Test 16 : SB" severity NOTE;
wait for 10 ns;

-- Test 17 : SH
instr_data_tb <= x"009290A3"; -- sh x9, 1(x5)
report "Test 17 : SH" severity NOTE;
wait for 10 ns;

-- Test 18 : SW
instr_data_tb <= x"00A2A223"; -- sw x10, 4(x5)
report "Test 18 : SW" severity NOTE;
wait for 10 ns;

-- Test 19 : ADDI
instr_data_tb <= x"00500293"; -- addi x5, x0, 5
report "Test 19 : ADDI" severity NOTE;
wait for 10 ns;

-- Test 20 : SLTI
instr_data_tb <= x"0012A313"; -- slti x6, x5, 1
report "Test 20 : SLTI" severity NOTE;
wait for 10 ns;

-- Test 21 : SLTIU
instr_data_tb <= x"0012B393"; -- sltiu x7, x5, 1
report "Test 21 : SLTIU" severity NOTE;
wait for 10 ns;

-- Test 22 : XORI
instr_data_tb <= x"0012C413"; -- xori x8, x5, 1
report "Test 22 : XORI" severity NOTE;
wait for 10 ns;

-- Test 23 : ORI
instr_data_tb <= x"0012E493"; -- ori x9, x5, 1
report "Test 23 : ORI" severity NOTE;
wait for 10 ns;

-- Test 24 : ANDI
instr_data_tb <= x"0012F513"; -- andi x10, x5, 1
report "Test 24 : ANDI" severity NOTE;
wait for 10 ns;

-- Test 25 : SLLI
instr_data_tb <= x"00129293"; -- slli x5, x5, 1
report "Test 25 : SLLI" severity NOTE;
wait for 10 ns;

-- Test 26 : SRLI
instr_data_tb <= x"00129493"; -- srli x9, x5, 1
report "Test 26 : SRLI" severity NOTE;
wait for 10 ns;

-- Test 27 : SRAI
instr_data_tb <= x"4012D293"; -- srai x5, x5, 1
report "Test 27 : SRAI" severity NOTE;
wait for 10 ns;

-- Test 28 : ADD
instr_data_tb <= x"00A282B3"; -- add x5, x5, x10
report "Test 28 : ADD" severity NOTE;
wait for 10 ns;

-- Test 29 : SUB
instr_data_tb <= x"40A282B3"; -- sub x5, x5, x10
report "Test 29 : SUB" severity NOTE;
wait for 10 ns;

-- Test 30 : SLL
instr_data_tb <= x"00A292B3"; -- sll x5, x5, x10
report "Test 30 : SLL" severity NOTE;
wait for 10 ns;

-- Test 31 : SLT
instr_data_tb <= x"00A2A2B3"; -- slt x5, x5, x10
report "Test 31 : SLT" severity NOTE;
wait for 10 ns;

-- Test 32 : SLTU
instr_data_tb <= x"00A2B2B3"; -- sltu x5, x5, x10
report "Test 32 : SLTU" severity NOTE;
wait for 10 ns;

-- Test 33 : XOR
instr_data_tb <= x"00A2C2B3"; -- xor x5, x5, x10
report "Test 33 : XOR" severity NOTE;
wait for 10 ns;

-- Test 34 : SRL
instr_data_tb <= x"00A2D2B3"; -- srl x5, x5, x10
report "Test 34 : SRL" severity NOTE;
wait for 10 ns;

-- Test 35 : SRA
instr_data_tb <= x"40A2D2B3"; -- sra x5, x5, x10
report "Test 35 : SRA" severity NOTE;
wait for 10 ns;

-- Test 36 : OR
instr_data_tb <= x"00A2E2B3"; -- or x5, x5, x10
report "Test 36 : OR" severity NOTE;
wait for 10 ns;

-- Test 37 : AND
instr_data_tb <= x"00A2F2B3"; -- and x5, x5, x10
report "Test 37 : AND" severity NOTE;
wait for 10 ns;

-- Test 38 : CSRRW
instr_data_tb <= x"00102073"; -- csrrw x1, x2, x0
report "Test 39 : CSRRW" severity NOTE;
wait for 10 ns;

-- Test 39 : CSRRS
instr_data_tb <= x"00103073"; -- csrrs x1, x2, x0
report "Test 40 : CSRRS" severity NOTE;
wait for 10 ns;

-- Test 40 : CSRRC
instr_data_tb <= x"00104073"; -- csrrc x1, x2, x0
report "Test 41 : CSRRC" severity NOTE;
wait for 10 ns;

-- Test 41 : CSRRWI
instr_data_tb <= x"00106073"; -- csrrwi x1, x0, 1
report "Test 42 : CSRRWI" severity NOTE;
wait for 10 ns;

-- Test 42 : CSRRSI
instr_data_tb <= x"00107073"; -- csrrsi x1, x0, 1
report "Test 43 : CSRRSI" severity NOTE;
wait for 10 ns;

-- Test 43 : CSRRCI
instr_data_tb <= x"00108073"; -- csrrci x1, x0, 1
report "Test 44 : CSRRCI" severity NOTE;
wait for 10 ns;

--Test 44 : Illegal instruction
instr_data_tb <= x"00000000";--illegal instruction
wait for 10 ns;
assert illegal_instr_tb = '1' report "ERROR : Illegal instruction was not detected" severity error;

wait;
end process;

end architecture;
		