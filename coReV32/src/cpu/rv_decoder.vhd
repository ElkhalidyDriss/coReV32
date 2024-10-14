---------------------------------------------------------------------------------------
--  Author: Driss Elkhalidy , an embedded systems engineering student                --
--          at National Institute of Posts and Telecommunications , Rabat , Morocco. --
--  Description : Implementation of decoder for coReV32 in VHDL.                     --
---------------------------------------------------------------------------------------



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.rv_package.all;


entity rv_decoder is 
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
end entity;


architecture rv_decode_arch of rv_decoder is 
--Immediates 
signal imm_i : std_logic_vector(31 downto 0);--I-type immediate value
signal imm_s : std_logic_vector(31 downto 0);--S-type immediate 
signal imm_b : std_logic_vector(31 downto 0);--B-type immediate
signal imm_u : std_logic_vector(31 downto 0);--U-type immediate value
signal imm_j : std_logic_vector(31 downto 0);--J-type immediate value
signal uimm  : std_logic_vector(31 downto 0);--Unsigned immediate for CSR instructions
signal imm_mux_sel : std_logic_vector(2 downto 0);
signal uimm_bar : std_logic_vector(31 downto 0);
--
signal opcode : std_logic_vector(6 downto 0);
signal funct3 : std_logic_vector(2 downto 0);
signal funct7 : std_logic;
begin
--Registers  address decodeing
reg_file_raddr1 <= instr_data(19 downto 15);
reg_file_raddr2 <= instr_data(24 downto 20);
reg_file_waddr  <= instr_data(11 downto 7);
--funct field
funct3 <= instr_data(14 downto 12);
funct7 <= instr_data(30);--funct7 is 7 bits wide , but we are interessed only on the 6th bit
--Immediates decoding
imm_i <= (31 downto 11 => instr_data(31))&instr_data(30 downto 25)&instr_data(24 downto 21)&instr_data(20);
imm_s <= (31 downto 11 => instr_data(31))&instr_data(30 downto 25)&instr_data(11 downto 8)&instr_data(7);
imm_b <= (31 downto 12 =>  instr_data(31))&instr_data(7)&instr_data(30 downto 25)&instr_data(11 downto 8)&'0';
imm_u <= instr_data(31 downto 12)&(11 downto 0 => '0');
imm_j <= (31 downto 20 => instr_data(31))&instr_data(19 downto 12)&instr_data(20)&instr_data(30 downto 25)&instr_data(24 downto 21)&'0';
uimm  <= (31 downto 5 => '0')&instr_data(19 downto 15);--zero extended immediate value for CSR 
uimm_bar  <= not(uimm);
process(imm_mux_sel)
begin
      case(imm_mux_sel) is
            when I_IMM => --I-type immediate
                 imm_extended <= imm_i;
            when S_IMM => --S-type immediate
                 imm_extended <= imm_s;
            when B_IMM => --B-type immediate
                 imm_extended <= imm_b;
            when U_IMM => --U-type immediate
                 imm_extended <= imm_u;
            when J_IMM => --J-type immediate
                 imm_extended <= imm_j;
            when Z_IMM => --unsigned immediate for CSR operations
                 imm_extended <= uimm;
            when Z_IMM_BAR => --not value of uimm
                 imm_extended <= uimm_bar;
            when others => imm_extended <= (others => '0');
      end case;
end process;
--CSR unit 
csr_addr <= instr_data(31 downto 20);
--Instruction decoding 
opcode <= instr_data(6 downto 0);
process(opcode)
begin
      case (opcode) is
            when LUI =>--Load upper immediate
                  reg_file_wdata_src <= W_SRC_IMM;
                  reg_file_we <= '1';--register file write enable
                  pc_next_src <= PC_INCREMENT;
                  imm_mux_sel <= U_IMM;
            when AUIPC =>--Add upper immediate to PC
                  reg_file_wdata_src <= W_SRC_IMM;
                  reg_file_we <= '1';
                  alu_operand_a_src <= ALU_OPERAND_PC;
                  alu_operand_b_src <= ALU_OPERAND_SRC_IMM;
                  alu_op <= ALU_ADD;
                  imm_mux_sel <= U_IMM;
                  pc_next_src <= PC_INCREMENT;
            when JAL =>--jump and link
                  reg_file_wdata_src <= W_SRC_PC_PLUS_4;--write next instruction address to dest reg
                  reg_file_we <= '1';
                  alu_operand_a_src <= ALU_OPERAND_PC;
                  alu_operand_b_src <= ALU_OPERAND_SRC_IMM;
                  alu_op <= ALU_ADD;
                  imm_mux_sel <= J_IMM;
                  pc_next_src <= PC_JUMP;
                  jump_t <= '0';--jump type is JAL
            when JALR =>--jump and link register
                  reg_file_wdata_src <= W_SRC_PC_PLUS_4;--CURRENT PC + 4
                  reg_file_we <= '1';
                  alu_operand_a_src <= ALU_OPERAND_RS1;
                  alu_operand_b_src <= ALU_OPERAND_SRC_IMM;
                  alu_op <= ALU_ADD;
                  imm_mux_sel <= I_IMM;
                  pc_next_src <= PC_JUMP;
                  jump_t <= '1';--jump type is JALR
            when BRANCH =>
                  alu_operand_a_src <= ALU_OPERAND_RS1;
                  alu_operand_b_src <= ALU_OPERAND_RS2;
                  imm_mux_sel <= B_IMM;
                  case (funct3) is 
                  --! The ALU has equality test output so no need to ask for equality and non equality test
                  --! test for greater than can be achieved by testing for less than and negating the output
                        when BGE  =>
                             alu_op <= ALU_SLT;
                        when BLT =>
                             alu_op <= ALU_SLT;
                        when BLTU =>
                             alu_op <= ALU_SLTU;
                        when BGEU =>
                              alu_op <= ALU_SLTU;
                        when others => alu_op <= ALU_SLT;
                  end case;
                  branch_t  <= funct3;--Branch type
                  alu_op <= ALU_SLT;
                  pc_next_src <= PC_BRANCH;
            when  LD =>--Load instructions
                  data_mem_en <= '1';--data memory enable
                  data_mem_we <= '0';
                  data_mem_size  <= funct3;
                  reg_file_wdata_src <= W_SRC_DATA_MEM;
                  reg_file_we <= '1';
                  alu_operand_a_src <= ALU_OPERAND_RS1;
                  alu_operand_b_src <= ALU_OPERAND_SRC_IMM;
                  alu_op <= ALU_ADD;
                  imm_mux_sel <= I_IMM;
                  pc_next_src <= PC_INCREMENT;
            When  STR => --Store instructions
                  data_mem_en <= '1';--data memory enable
                  data_mem_we <= '1';--data memory write enable 
                  data_mem_size  <= funct3;
                  reg_file_we <= '0';
                  alu_operand_a_src <= ALU_OPERAND_RS1;
                  alu_operand_b_src <= ALU_OPERAND_SRC_IMM;
                  imm_mux_sel <= S_IMM;
                  alu_op <= ALU_ADD;
            when  OP => --Register to Register Arithmetic
                  reg_file_wdata_src <= W_SRC_ALU_RES;
                  reg_file_we <= '1';
                  alu_operand_a_src <= ALU_OPERAND_RS1;
                  alu_operand_b_src <= ALU_OPERAND_RS2;
                  alu_op <= funct7 & funct3;
                  pc_next_src <= PC_INCREMENT;
            when OP_IMM => --Register to Immediate Arithmetic
                  reg_file_wdata_src <= W_SRC_ALU_RES;
                  reg_file_we <= '1';
                  alu_operand_a_src <= ALU_OPERAND_RS1;
                  alu_operand_b_src <= ALU_OPERAND_SRC_IMM;
                  alu_op <= funct7 & funct3;
                  imm_mux_sel <= I_IMM;
                  pc_next_src <= PC_INCREMENT;
            when  CSR =>--Control & Status register instructions
                  reg_file_wdata_src <= W_SRC_CSR;
                  reg_file_we <= '1';
                  case funct3 is
                        when CSRRW => --CSR Read/Write
                             csr_wdata_src <= CSR_W_SRC_RS1;
                        when CSRRS => --CSR Read and Set bit
                             csr_wdata_src <= CSR_W_SRC_ALU_RES;
                             alu_operand_a_src <= ALU_OPERAND_RS1;
                             alu_operand_b_src <= ALU_OPERAND_SRC_CSR;
                             alu_op <= ALU_OR;
                        when CSRRC => --CSR Read and Clear bit
                             csr_wdata_src <= CSR_W_SRC_ALU_RES;
                             alu_operand_a_src <= ALU_OPERAND_RS1_BAR;
                             alu_operand_b_src <= ALU_OPERAND_SRC_CSR;
                             alu_op <= ALU_AND;
                        when CSRRWI =>--CSR Read and Write Immediate 
                             csr_wdata_src <= CSR_W_SRC_IMM;
                             imm_mux_sel <= Z_IMM;
                        when CSRRSI => --CSR Read and Set Immediate
                             csr_wdata_src <= CSR_W_SRC_ALU_RES;
                             alu_operand_a_src <= ALU_OPERAND_SRC_CSR;
                             alu_operand_b_src <= ALU_OPERAND_SRC_IMM;
                             alu_op <= ALU_OR;
                             imm_mux_sel <= Z_IMM;
                        when CSRRCI => --Read and Clear Immediate
                             csr_wdata_src <= CSR_W_SRC_ALU_RES;
                             alu_operand_a_src <= ALU_OPERAND_SRC_CSR;
                             alu_operand_b_src <= ALU_OPERAND_SRC_IMM;
                             alu_op <= ALU_AND;
                             imm_mux_sel <= Z_IMM_BAR;
                        when others => illegal_instr <= '1';
                  end case;
                  pc_next_src <= PC_INCREMENT;
            when others => illegal_instr <= '1';
      end case;
end process;
end architecture;
