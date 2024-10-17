library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity tb_rv_decode is

end entity;

architecture tb of tb_rv_decode is
    signal clk_tb               : std_logic := '0';
    signal rst_n_tb             : std_logic := '1'; -- active low reset
    signal pc_hold_tb           : std_logic;
    signal fetch_valid_o_tb     : std_logic := '1';
    signal pc_next_src_tb       : std_logic_vector(2 downto 0);
    signal instr_data_fd_tb     : std_logic_vector(31 downto 0);
    signal instr_addr_fd_tb     : std_logic_vector(31 downto 0);
    signal pc_plus_4_fd_tb      : std_logic_vector(31 downto 0);
    signal illegal_instr_o_tb    : std_logic;
    signal instr_addr_dx_tb     : std_logic_vector(31 downto 0);
    signal pc_plus_4_dx_tb      : std_logic_vector(31 downto 0);
    signal valid_pc_update_tb    : std_logic := '1';
    signal pc_plus_4_wb_tb      : std_logic_vector(31 downto 0);
    signal reg_f_rdata1_dx_tb   : std_logic_vector(31 downto 0);
    signal reg_f_rdata1_bar_dx_tb: std_logic_vector(31 downto 0);
    signal reg_f_rdata2_dx_tb   : std_logic_vector(31 downto 0);
    signal reg_f_waddr_dx_tb    : std_logic_vector(4 downto 0);
    signal reg_f_we_dx_tb       : std_logic;
    signal reg_f_we_wb_tb       : std_logic := '1';
    signal alu_operand_a_src_dx_tb : std_logic_vector(2 downto 0);
    signal alu_operand_b_src_dx_tb : std_logic_vector(2 downto 0);
    signal alu_op_dx_tb         : std_logic_vector(3 downto 0);
    signal alu_res_wb_tb        : std_logic_vector(31 downto 0);
    signal branch_t_dx_tb       : std_logic_vector(2 downto 0);
    signal jump_t_dx_tb         : std_logic;
    signal data_mem_size_dx_tb  : std_logic_vector(2 downto 0);
    signal data_mem_we_dx_tb    : std_logic;
    signal data_mem_en_dx_tb    : std_logic;
    signal data_mem_rdata_wb_tb : std_logic_vector(31 downto 0);
    signal csr_addr_dx_tb       : std_logic_vector(11 downto 0);
    signal csr_wdata_src_dx_tb  : std_logic_vector(1 downto 0);
    signal csr_rdata_wb_tb      : std_logic_vector(31 downto 0);
    signal imm_extended_dx_tb    : std_logic_vector(31 downto 0);
    signal imm_u_wb_tb          : std_logic_vector(31 downto 0);
    signal stall_tb             : std_logic := '0';
    signal decode_ready_tb      : std_logic;
    signal decode_valid_o_dx_tb : std_logic;
    signal execute_ready_tb      : std_logic := '1';
    component rv_decode
        port (
            clk                    : in std_logic;
            rst_n                  : in std_logic; -- active low reset
            -- Fetch Unit
            pc_hold                : out std_logic;
            fetch_valid_o          : in std_logic;
            pc_next_src            : out std_logic_vector(2 downto 0);
            instr_data_fd          : in std_logic_vector(31 downto 0); -- instruction data from fetch
            instr_addr_fd          : in std_logic_vector(31 downto 0); -- current instruction address
            pc_plus_4_fd           : in std_logic_vector(31 downto 0); -- next instruction address
            illegal_instr_o        : out std_logic;
            -- Execute Unit
            instr_addr_dx          : out std_logic_vector(31 downto 0); -- current instruction address to execute stage
            pc_plus_4_dx           : out std_logic_vector(31 downto 0); -- next instruction address
            valid_pc_update        : in std_logic; -- valid value of the PC update from execute stage
            -- 
            pc_plus_4_wb           : in std_logic_vector(31 downto 0); -- current PC + 4 from write back stage
            
            -- Register File
            reg_f_rdata1_dx        : out std_logic_vector(31 downto 0); -- read address for port 1 
            reg_f_rdata1_bar_dx    : out std_logic_vector(31 downto 0); -- not logic of reg_f_rdata1
            reg_f_rdata2_dx        : out std_logic_vector(31 downto 0); -- read address for port 2
            reg_f_waddr_dx         : out std_logic_vector(4 downto 0);  -- address of the destination register 
            reg_f_we_dx            : out std_logic;
            reg_f_we_wb            : in std_logic;
            -- ALU 
            alu_operand_a_src_dx   : out std_logic_vector(2 downto 0); -- ALU operand A source 
            alu_operand_b_src_dx   : out std_logic_vector(2 downto 0); -- ALU operand B source 
            alu_op_dx              : out std_logic_vector(3 downto 0); -- ALU operation
            alu_res_wb             : in std_logic_vector(31 downto 0); -- ALU result from write back stage 
            -- Branch/JUMP
            branch_t_dx            : out std_logic_vector(2 downto 0); -- branch type (BEQ , BNE , BLT , BGE , BLTU , BGEU)
            jump_t_dx              : out std_logic; -- jump type ('0' JAL, '1' JALR)
            -- Data Memory
            data_mem_size_dx       : out std_logic_vector(2 downto 0); -- word size to be retrieved from memory (byte, short, or int)
            data_mem_we_dx         : out std_logic; -- data memory write enable
            data_mem_en_dx         : out std_logic; -- data memory enable
            data_mem_rdata_wb      : in std_logic_vector(31 downto 0); -- data memory output from write back stage
            -- Control & Status Registers
            csr_addr_dx            : out std_logic_vector(11 downto 0);
            csr_wdata_src_dx       : out std_logic_vector(1 downto 0);
            csr_rdata_wb           : in std_logic_vector(31 downto 0); -- output data of selected control status register from write back stage
            -- Decoded Immediate Value 
            imm_extended_dx         : out std_logic_vector(31 downto 0); -- extended immediate value
            imm_u_wb                : in std_logic_vector(31 downto 0); -- imm_u type from write back stage 
            -- Pipeline
            stall                   : in std_logic;
            decode_ready            : out std_logic; -- ready to receive the next instruction
            decode_valid_o_dx      : out std_logic; -- decode is done 
            execute_ready           : in std_logic -- execute is ready for receiving the decoded instruction
        );
    end component;


    -- Clock Generation
    constant clk_period : time := 10 ns;

begin
    -- Instantiate the Device Under Test (DUT)
    uut: rv_decode
        port map (
            clk                    => clk_tb,
            rst_n                  => rst_n_tb,
            pc_hold                => pc_hold_tb,
            fetch_valid_o          => fetch_valid_o_tb,
            pc_next_src            => pc_next_src_tb,
            instr_data_fd          => instr_data_fd_tb,
            instr_addr_fd          => instr_addr_fd_tb,
            pc_plus_4_fd           => pc_plus_4_fd_tb,
            illegal_instr_o        => illegal_instr_o_tb,
            instr_addr_dx          => instr_addr_dx_tb,
            pc_plus_4_dx           => pc_plus_4_dx_tb,
            valid_pc_update        => valid_pc_update_tb,
            pc_plus_4_wb           => pc_plus_4_wb_tb,
            reg_f_rdata1_dx       => reg_f_rdata1_dx_tb,
            reg_f_rdata1_bar_dx    => reg_f_rdata1_bar_dx_tb,
            reg_f_rdata2_dx        => reg_f_rdata2_dx_tb,
            reg_f_waddr_dx         => reg_f_waddr_dx_tb,
            reg_f_we_dx            => reg_f_we_dx_tb,
            reg_f_we_wb            => reg_f_we_wb_tb,
            alu_operand_a_src_dx   => alu_operand_a_src_dx_tb,
            alu_operand_b_src_dx   => alu_operand_b_src_dx_tb,
            alu_op_dx              => alu_op_dx_tb,
            alu_res_wb             => alu_res_wb_tb,
            branch_t_dx            => branch_t_dx_tb,
            jump_t_dx              => jump_t_dx_tb,
            data_mem_size_dx       => data_mem_size_dx_tb,
            data_mem_we_dx         => data_mem_we_dx_tb,
            data_mem_en_dx         => data_mem_en_dx_tb,
            data_mem_rdata_wb      => data_mem_rdata_wb_tb,
            csr_addr_dx            => csr_addr_dx_tb,
            csr_wdata_src_dx       => csr_wdata_src_dx_tb,
            csr_rdata_wb           => csr_rdata_wb_tb,
            imm_extended_dx        => imm_extended_dx_tb,
            imm_u_wb               => imm_u_wb_tb,
            stall                   => stall_tb,
            decode_ready            => decode_ready_tb,
            decode_valid_o_dx      => decode_valid_o_dx_tb,
            execute_ready           => execute_ready_tb
        );

CLOCK: process
    begin
            clk_tb <= '1';
            wait for clk_period / 2;
            clk_tb <= '0';
            wait for clk_period / 2;
    end process;

    -- Stimulus Process
STIMILUS: process
    begin
        rst_n_tb <= '0';
        wait for 20 ns;
        rst_n_tb <= '1';
        
        -- Test 1: Load an instruction
        instr_data_fd_tb <= X"00000033";  -- Example instruction (ADD)
        instr_addr_fd_tb <= X"00000000";  -- Starting address
        pc_plus_4_fd_tb <=  X"00000004";   -- Next instruction address
        wait for clk_period;

        -- Test 2: Check the fetch output
        fetch_valid_o_tb <= '1';  -- Indicates that fetch is valid
        wait for clk_period;

        -- Verify outputs after decoding
        assert (instr_addr_dx_tb = instr_addr_fd_tb) report "Instruction address mismatch!" severity ERROR;
        assert (pc_plus_4_dx_tb = pc_plus_4_fd_tb) report "PC+4 mismatch!" severity ERROR;

        -- Test case 3: Test illegal instruction handling
        instr_data_fd_tb <= X"FFFFFFFF";  -- Example of an illegal instruction
        wait for clk_period;

        -- Check illegal instruction output
        assert (illegal_instr_o_tb = '1') report "Illegal instruction not detected!" severity ERROR;

        -- Test case 4: Simulate a valid PC update
        valid_pc_update_tb <= '1';
        pc_plus_4_wb_tb <= X"00000008";   -- Update the PC
        wait for clk_period;

        -- Additional assertions can be added to verify the behavior here

        -- End of simulation
        wait;
    end process;

end architecture;
