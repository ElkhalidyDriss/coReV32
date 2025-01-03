library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity tb_rv_decode is
end entity;

architecture tb of tb_rv_decode is
constant CLK_PERIOD : time := 10 ns;
signal clk_tb                     : std_logic;
signal rst_n_tb                   : std_logic; -- active low reset
-- Fetch Unit
signal fetch_valid_o_tb           : std_logic := '1';
signal instr_data_fd_tb           : std_logic_vector(31 downto 0) :=(others => '0');
signal instr_addr_fd_tb           : std_logic_vector(31 downto 0) :=(others => '0');
signal pc_plus_4_fd_tb            : std_logic_vector(31 downto 0) :=(others => '0');
-- Execute Unit
signal instr_addr_dx_tb           : std_logic_vector(31 downto 0);
signal pc_plus_4_dx_tb            : std_logic_vector(31 downto 0);
signal pc_next_src_dx_tb          : std_logic_vector(2 downto 0);
-- Write Back Unit
signal reg_f_we_wb_tb             : std_logic := '1';
signal pc_plus_4_wb_tb            : std_logic_vector(31 downto 0) :=(others => '0');
signal imm_u_wb_tb                : std_logic_vector(31 downto 0) :=(others => '0');
signal alu_res_wb_tb              : std_logic_vector(31 downto 0) :=(others => '0');
signal data_mem_rdata_wb_tb       : std_logic_vector(31 downto 0) :=(others => '0');
signal csr_rdata_wb_tb            : std_logic_vector(31 downto 0) :=(others => '0');
-- Register File
signal reg_f_rdata1_dx_tb         : std_logic_vector(31 downto 0);
signal reg_f_rdata1_bar_dx_tb     : std_logic_vector(31 downto 0);
signal reg_f_rdata2_dx_tb         : std_logic_vector(31 downto 0);
signal reg_f_waddr_dx_tb          : std_logic_vector(4  downto 0):=(others => '0');
signal reg_f_we_dx_tb             : std_logic;
-- ALU
signal alu_operand_a_src_dx_tb    : std_logic_vector(2 downto 0);
signal alu_operand_b_src_dx_tb    : std_logic_vector(2 downto 0);
signal alu_op_dx_tb               : std_logic_vector(3 downto 0);
-- Branch/Jump
signal branch_t_dx_tb             : std_logic_vector(2 downto 0);
 signal jump_t_dx_tb               : std_logic;
-- Data Memory
signal data_mem_size_dx_tb        : std_logic_vector(2 downto 0);
signal data_mem_we_dx_tb          : std_logic;
signal data_mem_en_dx_tb          : std_logic;
-- Control & Status Registers
signal csr_addr_dx_tb             : std_logic_vector(11 downto 0);
signal csr_wdata_src_dx_tb        : std_logic_vector(1 downto 0);
-- Immediate Value
signal imm_extended_dx_tb         : std_logic_vector(31 downto 0);
-- Pipeline and Hazard Unit
signal stall_tb                   : std_logic :='0';
signal decode_ready_tb            : std_logic;
signal decode_valid_o_dx_tb       : std_logic;
signal execute_ready_tb           : std_logic:='0';
signal hazard_branch_o_tb         : std_logic;
signal hazard_illegal_instr_o_tb  : std_logic;
signal hazard_rf_rs1_id_tb        : std_logic_vector(4 downto 0);
signal hazard_rf_rs2_id_tb        : std_logic_vector(4 downto 0);

component rv_decode is 
    port (
           clk   : in std_logic;
           rst_n : in std_logic;--active low reset
           --fetch unit
           --pc_hold       : out std_logic; 
           fetch_valid_o : in std_logic;--fetch has valid output 
           instr_data_fd : in std_logic_vector(31 downto 0);--instruction data comming from fetch to decode stage
           instr_addr_fd : in std_logic_vector(31 downto 0);--current instruction address comming from fetch to decode
           pc_plus_4_fd  : in std_logic_vector(31 downto 0);--next instruction address
           --Execute unit
           instr_addr_dx    : out std_logic_vector(31 downto 0);--current instruction address comming from decode to execute stage
           pc_plus_4_dx     : out std_logic_vector(31 downto 0);--next instruction address
           pc_next_src_dx   : out std_logic_vector(2 downto 0);--decode-execute pc next source select signal
           --Write back unit 
           reg_f_we_wb       : in  std_logic;
           pc_plus_4_wb      : in  std_logic_vector(31 downto 0);--current program counter + 4 from write back stage
           imm_u_wb          : in  std_logic_vector(31 downto 0);--imm_u type from write back stage 
           alu_res_wb        : in  std_logic_vector(31 downto 0);--alu result from write back stage 
           data_mem_rdata_wb : in  std_logic_vector(31 downto 0);--data memory output from write back stage
           csr_rdata_wb      : in   std_logic_vector(31 downto 0);--output data of selected control status register from write back stage
           --Register file
           reg_f_rdata1_dx     : out std_logic_vector(31 downto 0);--read address for port 1 for decode-execute stage  
           reg_f_rdata1_bar_dx : out std_logic_vector(31 downto 0);--not logic of reg_f_rdata1
           reg_f_rdata2_dx     : out std_logic_vector(31 downto 0);--read address for port 2
           reg_f_waddr_dx      : out std_logic_vector(4 downto 0);--address of the destination register 
           reg_f_we_dx         : out std_logic;
        
           --ALU 
           alu_operand_a_src_dx : out std_logic_vector(2 downto 0);--alu operand a source 
           alu_operand_b_src_dx : out std_logic_vector(2 downto 0);--alu operand b source 
           alu_op_dx            : out std_logic_vector(3 downto 0);--alu operation
           --Branch/JUMP
           branch_t_dx : out std_logic_vector(2 downto 0);--branch type (BEQ , BNE , BLT , BGE , BLTU , BGEU)
           jump_t_dx   : out std_logic;--jump type
                                     -- '0' : JAL 
                                     -- '1' : JALR
           --Data Memory
           data_mem_size_dx  : out std_logic_vector(2 downto 0); -- word size to be retrieved from memory (byte , short or int)
           data_mem_we_dx    : out std_logic;--data memory write enable
           data_mem_en_dx    : out std_logic;--data memory enable
           --Control & Status registers
           csr_addr_dx      : out  std_logic_vector(11 downto 0);
           csr_wdata_src_dx : out  std_logic_vector(1 downto 0);
           --Decoded immediate value 
           imm_extended_dx : out std_logic_vector(31 downto 0);--extended immediate value
           --pipeline and hazards unit 
           stall                  : in std_logic;
           decode_ready           : out std_logic;--ready to receive the next instruction
           decode_valid_o_dx      : out std_logic;--decode is done 
           execute_ready          : in std_logic;--execute is ready for receiving the decoded instruction
           hazard_branch_o        : out std_logic;--flag idicates to hazard unit that a branch or a jump  occured 
           hazard_illegal_instr_o : out std_logic;--flag indicates to hazard unit that there is an illegal instruction
           hazard_rf_rs1_id       : out std_logic_vector(4 downto 0);--register source 1 address from instruction decode stage to hazard unit 
           hazard_rf_rs2_id       : out std_logic_vector(4 downto 0)  
        );
end component;

begin
DUT : rv_decode
    port map (
    clk                   => clk_tb,
    rst_n                 => rst_n_tb,
    -- Fetch Unit
    fetch_valid_o         => fetch_valid_o_tb,
    instr_data_fd         => instr_data_fd_tb,
    instr_addr_fd         => instr_addr_fd_tb,
    pc_plus_4_fd          => pc_plus_4_fd_tb,
    -- Execute Unit
    instr_addr_dx         => instr_addr_dx_tb,
    pc_plus_4_dx          => pc_plus_4_dx_tb,
    pc_next_src_dx        => pc_next_src_dx_tb,
    -- Write Back Unit
    reg_f_we_wb           => reg_f_we_wb_tb,
    pc_plus_4_wb          => pc_plus_4_wb_tb,
    imm_u_wb              => imm_u_wb_tb,
    alu_res_wb            => alu_res_wb_tb,
    data_mem_rdata_wb     => data_mem_rdata_wb_tb,
    csr_rdata_wb          => csr_rdata_wb_tb,
    -- Register File
    reg_f_rdata1_dx       => reg_f_rdata1_dx_tb,
    reg_f_rdata1_bar_dx   => reg_f_rdata1_bar_dx_tb,
    reg_f_rdata2_dx       => reg_f_rdata2_dx_tb,
    reg_f_waddr_dx        => reg_f_waddr_dx_tb,
    reg_f_we_dx           => reg_f_we_dx_tb,
    -- ALU
    alu_operand_a_src_dx  => alu_operand_a_src_dx_tb,
    alu_operand_b_src_dx  => alu_operand_b_src_dx_tb,
    alu_op_dx             => alu_op_dx_tb,
    -- Branch/Jump
    branch_t_dx           => branch_t_dx_tb,
    jump_t_dx             => jump_t_dx_tb,
    -- Data Memory
    data_mem_size_dx      => data_mem_size_dx_tb,
    data_mem_we_dx        => data_mem_we_dx_tb,
    data_mem_en_dx        => data_mem_en_dx_tb,
    -- Control & Status Registers
    csr_addr_dx           => csr_addr_dx_tb,
    csr_wdata_src_dx      => csr_wdata_src_dx_tb,
    -- Immediate Value
    imm_extended_dx       => imm_extended_dx_tb,
    -- Pipeline and Hazard Unit
    stall                 => stall_tb,
    decode_ready          => decode_ready_tb,
    decode_valid_o_dx     => decode_valid_o_dx_tb,
    execute_ready         => execute_ready_tb,
    hazard_branch_o       => hazard_branch_o_tb,
    hazard_illegal_instr_o => hazard_illegal_instr_o_tb,
    hazard_rf_rs1_id      => hazard_rf_rs1_id_tb,
    hazard_rf_rs2_id      => hazard_rf_rs2_id_tb
    );
CLOCK: process
    begin
            clk_tb <= '1';
            wait for CLK_PERIOD / 2;
            clk_tb <= '0';
            wait for CLK_PERIOD / 2;
    end process;
STIMILUS: process
begin
    rst_n_tb <= '0';
    wait for 10 ns;
    rst_n_tb <= '1';
    wait for 10 ns;
    --TEST 1 :  Loading instruction data and program counter from Fetch unit
    report "TEST 1 :  Loading instruction data and program counter from Fetch unit";
    stall_tb <= '0';
    execute_ready_tb <= '1';--execute is ready for receiving decoded instruction
    fetch_valid_o_tb <= '1';--fetch has valid outptut
    instr_data_fd_tb <= x"123452B7"; --lui x5, 0x12345
    instr_addr_fd_tb <= x"00000001"; --Example address
    pc_plus_4_fd_tb  <= x"00000004"; --Next address
    wait until decode_valid_o_dx_tb = '1';
    report "TEST 1 : decode has valid output now";
    assert instr_addr_dx_tb = x"00000001" 
           report "TEST 1 Failed : Incorrect current instruction address" 
           severity error;
    assert pc_plus_4_dx_tb  = x"00000004" 
           report "TEST 1 Failed : Incorrect next instruction Address"
           severity error;
    fetch_valid_o_tb <= '0';--fetch has no valid output
    wait for CLK_PERIOD;
    --TEST 2 : Halting decode stage 
    report "--TEST 2 : Halting decode stage ";
    stall_tb <= '1';
    wait for CLK_PERIOD;
    stall_tb <= '0';
    assert decode_ready_tb = '0'
           report "TEST 2 Failed : When stalled decode stage shouldn't be ready for receiving new instruction"
           severity error;
    assert decode_valid_o_dx_tb = '0'
           report "TEST 2 Failed : When stalled decode stage shouldn't present an output "
           severity error;
    --TEST 3 : Illegal instruction
    report "TEST 3 : Illegal instruction";
    fetch_valid_o_tb <= '1';
    instr_data_fd_tb <=(31 downto 7 => '0')&"1001101"; 
    wait for CLK_PERIOD;
    assert  hazard_illegal_instr_o_tb = '1' 
    report "TEST 3 Failed : The illegal instruction is not detected"
    severity error; 
    wait;
end process;
end architecture;
