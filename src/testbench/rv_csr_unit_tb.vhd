


entity rv_csr_unit_tb is
end entity;


architecture rv_csr_unit_tb_arch of rv_csr_unit_tb is
 
component rv_csr_unit 
port (
    clk         : in std_logic;
    --  mtimer_clk  : in std_logic;
    rst_n       : in std_logic;--active low reset
    csr_we      : in std_logic; --csr write enable
    csr_addr    : in std_logic_vector(11 downto 0);--control & status register address
    csr_wdata_i : in std_logic_vector(31 downto 0);--csr write data in 
    csr_rdata_o : out std_logic_vector(31 downto 0)--csr read data output
    --Interrupts controller 
    -- mti_o     : out std_logic;--machine time interrupt
    --immediately prividing outputs of  interrupt registers
    mstatus_o : out std_logic_vector(31 downto 0);
    mepc_o    : out std_logic_vector(31 downto 0);
    mtvec_o   : out std_logic_vector(31 downto 0);
    mcause_o  : out std_logic_vector(31 downto 0);
    
    mstatus_i : in std_logic_vector(31 downto 0);
    mepc_i    : in std_logic_vector(31 downto 0);
    mtvec_i   : in std_logic_vector(31 downto 0);
    mcause_i  : in std_logic_vector(31 downto 0);    
    on_exc_we : in std_logic--on exception/interrupt write enable
        );
end component;
begin

end architecture;

