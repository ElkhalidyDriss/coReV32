---------------------------------------------------------------------------------------
--  Author: Driss Elkhalidy , an embedded systems engineering student                --
--          at National Institute of Posts and Telecommunications , Rabat , Morocco. --
--  Description : Testbench of Fetch unit for  coReV32 in VHDL.                 --
---------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.rv_package.all;

entity rv_fetch_tb is 
end entity;


architecture rv_fetch_tb_arch of rv_fetch_tb is 
    constant CLK_PERIOD : time := 10 ns;
    signal clk                : std_logic := '0';
    signal rst_n             : std_logic := '0';
    signal pc_next_src       : std_logic_vector(2 downto 0);
    signal pc_hold           : std_logic := '0';
    signal branch_target      : std_logic_vector(31 downto 0) := x"00000004";
    signal jump_target        : std_logic_vector(31 downto 0) := x"00000008";
    signal csr_mepc          : std_logic_vector(31 downto 0) := x"0000000C";
    signal mtvec             : std_logic_vector(31 downto 0) := x"00000010";
    signal exc_cause         : std_logic_vector(1 downto 0) := "10";
    signal stall             : std_logic := '0';
    signal decode_ready      : std_logic := '1';
    signal prog_mem_raddr    : std_logic_vector(31 downto 0);
    signal prog_mem_data_in  : std_logic_vector(31 downto 0):=x"FFED_FEAA";  
    signal prog_mem_valid_o   : std_logic := '0';
    signal prog_mem_req      : std_logic;
    signal instr_data        : std_logic_vector(31 downto 0);
    signal instr_addr        : std_logic_vector(31 downto 0);
    signal instr_ready       : std_logic;

    component rv_fetch
    generic (
        BOOT_ADDR : std_logic_vector(31 downto 0) := (others =>'0')
    );
    port (
        clk           : in std_logic;
        rst_n         : in std_logic;
        pc_next_src   : in std_logic_vector(2 downto 0);
        pc_hold       : in std_logic;
        branch_target  : in std_logic_vector(31 downto 0);
        jump_target    : in std_logic_vector(31 downto 0);
        csr_mepc      : in std_logic_vector(31 downto 0);
        mtvec         : in std_logic_vector(31 downto 0);
        exc_cause     : in std_logic_vector(1 downto 0);
        stall         : in std_logic;
        decode_ready  : in std_logic;
        prog_mem_raddr : out std_logic_vector(31 downto 0);
        prog_mem_data_in : in std_logic_vector(31 downto 0);
        prog_mem_valid_o : in std_logic;
        prog_mem_req  : out std_logic;
        instr_data    : out std_logic_vector(31 downto 0);
        instr_addr    : out std_logic_vector(31 downto 0);
        instr_ready   : out std_logic
    );
    end component;

begin
    DUT: rv_fetch
    port map (
        clk            => clk,
        rst_n          => rst_n,
        pc_next_src    => pc_next_src,
        pc_hold        => pc_hold,
        branch_target   => branch_target,
        jump_target     => jump_target,
        csr_mepc       => csr_mepc,
        mtvec          => mtvec,
        exc_cause      => exc_cause,
        stall          => stall,
        decode_ready   => decode_ready,
        prog_mem_raddr => prog_mem_raddr,
        prog_mem_data_in => prog_mem_data_in,
        prog_mem_valid_o => prog_mem_valid_o,
        prog_mem_req   => prog_mem_req,
        instr_data     => instr_data,
        instr_addr     => instr_addr,
        instr_ready    => instr_ready
    );

CLOCK: process
       begin
            clk <= '0'; wait for CLK_PERIOD / 2;
            clk <= '1'; wait for CLK_PERIOD / 2;
       end process;
STIMILUS: process
          begin
          rst_n <= '0';
          wait for CLK_PERIOD * 2;
          rst_n <= '1';
          -- Test 1: Normal instruction fetch
          pc_next_src <= PC_INCREMENT;
          prog_mem_valid_o <= '1';  -- Valid data from memory
          wait for CLK_PERIOD * 2;
          -- Test 2: Stall the pipeline
          stall <= '1';
          wait for CLK_PERIOD * 4; 
          stall <= '0';
           
          -- Test 3: Branch test
          pc_next_src <= PC_BRANCH;  
          prog_mem_valid_o <= '1';  -- Valid data from memory
          wait for CLK_PERIOD * 2;
          assert instr_ready = '1' report "Instruction should be ready after branch." severity error;

          -- Test 4: Jump test
          pc_next_src <= PC_JUMP; 
          prog_mem_valid_o <= '1';  -- Valid data from memory
          wait for CLK_PERIOD * 2;
          assert instr_ready = '1' report "Instruction should be ready after jump." severity error;

          -- Test 5: Exception handling
          pc_next_src <= PC_EXC;  
            wait for CLK_PERIOD * 2;
          assert instr_ready = '1' report "Instruction should be ready after exception." severity error;
          wait;  
    end process;

end architecture;
