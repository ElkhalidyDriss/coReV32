---------------------------------------------------------------------------------------
--  Author: Driss Elkhalidy , an embedded systems engineering student                --
--          at National Institute of Posts and Telecommunications , Rabat , Morocco. --
--  Description : Implementation of execute stage for coReV32 in VHDL.                --
---------------------------------------------------------------------------------------



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.rv_package.all;

entity rv_execute is
port(
    clk : in std_logic;
    rst_n : in std_logic;

    decode_valid_o_d_ex : in std_logic;
    exec_valid_o_ex_w   : out std_logic;
    exec_ready          : out std_logic;--execute ready for decoded instruction from decode stage
    --program counter
    instr_addr_d_ex : in std_logic_vector(31 downto 0);--current instruction that is being executed 
    pc_plus_4_d_ex  : in std_logic_vector(31 downto 0);--next instruction address
    pc_next_src_d_ex  : in std_logic_vector(2 downto 0);--decode-execute pc next source select signal
    --Write back unit
    instr_addr_ex_w   : out std_logic_vector(31 downto 0);
    pc_plus_4_ex_w    : out std_logic_vector(31 downto 0);
    pc_next_src_ex_w  : out std_logic_vector(2 downto 0);
    alu_res_wb        : out std_logic_vector(31 downto 0);--alu result forwarded to the write back
    csr_rdata_wb      : out std_logic_vector(31 downto 0);--read data output of the csr unit to write back stage
    --ALU
    alu_operand_a_src_d_ex : in std_logic_vector(2 downto 0);
    alu_operand_b_src_d_ex : in std_logic_vector(2 downto 0);
    alu_op_d_ex            : in std_logic_vector(3 downto 0);--alu operation

    --reg file
    reg_file_rdata1_d_ex     : in std_logic_vector(31 downto 0);
    reg_file_rdata2_d_ex     : in std_logic_vector(31 downto 0);
    reg_file_rdata1_bar_d_ex : in std_logic_vector(31 downto 0);    
    --Extended immediate value
    extended_imm_d_ex : in std_logic_vector(31 downto 0);
    --CSR unit
    csr_wdata_src_d_ex  : in std_logic_vector(1 downto 0);
    csr_addr_d_ex       : in std_logic_vector(11 downto 0);--address of the  CS register 
    --Jump/Branch unit 
    jump_t_d_ex          : in std_logic;--jump type
                                   -- '0' JAL 
                                   -- '1' JALR
    branch_t_d_ex        : in std_logic_vector(2 downto 0);
    branch_target_o      : out std_logic_vector(31 downto 0);
    jump_target_o        : out std_logic_vector(31 downto 0)
);
end entity;

architecture rv_execute_arch of rv_execute is
signal csr_rdata_o : std_logic_vector(31 downto 0);
signal csr_wdata   : std_logic_vector(31 downto 0);
--alu
signal alu_operand_a_val : std_logic_vector(31 downto 0);
signal alu_operand_b_val : std_logic_vector(31 downto 0);
signal alu_res : std_logic_vector(31 downto 0);
signal aluEQ   : std_logic;
--Branch
signal branch_target_int : std_logic_vector(31 downto 0);--internal signal
--Component
component rv_alu 
port (     valA , valB : in  std_logic_vector(31 downto 0);--ALU input operands
           alu_op      : in  std_logic_vector(3 downto 0); --alu operation
           alu_res     : out std_logic_vector(31 downto 0); -- ALU result
           aluEQ       : out std_logic); -- equal flag , active high when srcA = srcB
end component;
begin
-----------------------------------------------
--                  ALU                      --
-----------------------------------------------
ALU : rv_alu port map (
    valA    => alu_operand_a_val,
    valB    => alu_operand_b_val,
    alu_op  => alu_op_d_ex,
    alu_res => alu_res,
    aluEQ   => aluEQ, 
);
OPERAND_A_MUX : process(alu_operand_a_src_d_ex)
begin
    case (alu_operand_a_src_d_ex) is 
        when ALU_OPERAND_RS1 => --select the first read port of reg file
            alu_operand_a_val <= reg_file_rdata1_d_ex;
        when ALU_OPERAND_RS1_BAR =>
            alu_operand_a_val <= reg_file_rdata1_bar_d_ex;
        when ALU_OPERAND_PC => --select current value of the program counter
            alu_operand_a_val <= instr_addr_d_ex;
        when ALU_OPERAND_SRC_CSR =>
            alu_operand_a_val <= csr_rdata_o;
        when others => null;
    end case;
end process;
OPERAND_B_MUX : process(alu_operand_b_src_d_ex)
begin
    case (alu_operand_b_src_d_ex) is 
        when ALU_OPERAND_RS2 => --select the second read port of reg file
            alu_operand_b_val <= reg_file_rdata2_d_ex;
        when ALU_OPERAND_SRC_IMM => --select extended immediate value
            alu_operand_b_val <= extended_imm_d_ex;
        when ALU_OPERAND_SRC_CSR =>
            alu_operand_b_val <= csr_rdata_o;
        when others => null;
    end case;
end process;
-----------------------------------------------
--               CSR Unit                 --
-----------------------------------------------
CSR_MUX : process(csr_wdata_src_d_ex)
begin
    case(csr_wdata_src_d_ex) is 
        when CSR_W_SRC_RS1 =>
            csr_wdata <= reg_file_rdata1_i;
        when CSR_W_SRC_ALU_RES =>
            csr_wdata <= alu_res;
        when CSR_W_SRC_IMM =>
            csr_wdata <= extended_imm_d_ex;
        when others => null;
    end case;
end process;

-----------------------------------------------
--               BRANCH/JUMP                 --
-----------------------------------------------
jump_target_o <= (alu_res(31 downto 1) & '0') when jump_t_d_ex = '1' else alu_res;

branch_target_int <= std_logic_vector(signed(instr_addr_d_ex) + signed(extended_imm_d_ex));
BRANCH_LOGIC : process(branch_t_d_ex)
begin
    case branch_t_d_ex is 
        when BEQ => --branch if rs1 = rs2 equal
             if aluEQ = '1' then 
                branch_target_o <= branch_target_int;
             else --branch to the next instruction
                branch_target_o <= pc_plus_4_d_ex;
             end if;
        when BNE => --branch if rs1 /= rs2
             if aluEQ = '0' then 
                branch_target_o <= branch_target_int;
             else --branch to the next instruction
                branch_target_o <= pc_plus_4_d_ex;
         end if;
        when BLT => --branch if rs1 < rs2
             --ALU is already received the SLT opcode at decode stage so if rs1 < rs2 then alu_res <= x"00000001";
             if alu_res(0) = '1' then 
                branch_target_o <= branch_target_int;
             else 
                branch_target_o <= pc_plus_4_d_ex;
             end if;
        when BGE => --branch greater than
             --ALU is already received the SLT opcode at decode stage so if rs1 < rs2 then alu_res <= x"00000001";
             if alu_res(0) = '0' then 
                branch_target_o <= branch_target_int;
             else 
                branch_target_o <= pc_plus_4_d_ex;
             end if;
        when BLTU => --Branch less than unsigned 
             --ALU is already received the SLTU opcode at decode stage so if rs1 < rs2 then alu_res <= x"00000001";
             if alu_res(0) = '1' then 
                branch_target_o <= branch_target_int;
             else 
                branch_target_o <= pc_plus_4_d_ex;
             end if;
        when BGEU => --Branch greater than unsigned
             if alu_res(0) = '0' then 
                branch_target_o <= branch_target_int;
             else 
                branch_target_o <= pc_plus_4_d_ex;
             end if;
        when others => null;  
    end case;
end process;
end architecture;
