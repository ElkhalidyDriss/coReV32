---------------------------------------------------------------------------------------
--  Author: Driss Elkhalidy , an embedded systems engineering student                -- 
--          at National Institute of Posts and Telecommunications , Rabat , Morocco. --
--  Description : Implementation of CSR unit for  risc-v in VHDL                     --
---------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.rv_package.all;


entity rv_csr_unit is
port (
    clk         : in std_logic;
    --mtimer_clk  : in std_logic;
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
    on_exc_we : in std_logic;--on exception/interrupt write enable

);
end entity;

architecture rv_csr_unit_arch of rv_csr_unit is
signal csr_rdata : std_logic_vector(31 downto 0);
--------------------------------------------------------------
--         Machine Level Control & Status Registers         --
--------------------------------------------------------------
--Machine timer register 
--signal mtime : std_logic_vector(31 downto 0);
--signal mtimecmp : std_logic_vector(31 downto 0);

signal mstatus : std_logic_vector(31 downto 0);--machine status register 
signal mscratch : std_logic_vector(31 downto 0);-- Machine Scratch Register

signal mepc : std_logic_vector(31 downto 0);--Machine Exception Program Counter

signal mtvec  : std_logic_vector(31 downto 0);--Machine Trap-Vector Base-Address Register (mtvec)
signal mcause : std_logic_vector(31 downto 0);--Machine Cause Register - indicates which interrupt occured
 
signal mip : std_logic_vector(31 downto 0);--Machine interrupt-pending register
signal mie : std_logic_vector(31 downto 0);--Machine interrupt-enable  register 

begin
--Read before write 
process(clk)
begin
    if rising_edge(clk) then 
       if rst_n = '0' then
          csr_rdata   <= (others => '0');
          mstatus     <= (others <= '0');
          mscratch    <= (others <= '0');
          mepc        <= (others <= '0');
          mtvec       <= (others <= '0');
          mcause      <= (others <= '0');
          mip         <= (others <= '0');
          mie         <= (others <= '0');
       else
          case (csr_addr) is 
            when MISA_ADDR => 
                csr_rdata <= (31 => '1',--Machine XLEN 
                              8  => '1',--I extension
                              others => '0');
            when MVENDORID_ADDR =>
                csr_rdata <= (others => '0');
            when MARCHID_ADDR =>
                csr_rdata <= (31 downto 1 => '0')&'1';
            when MIMPID_ADDR =>
                csr_rdata <= (31 downto 1 => '0')&'1';
            when MIE_ADDR  =>
                csr_rdata <= mie;
            when MTVEC_ADDR =>
                csr_rdata <= mtvec;
            when MSCRATCH_ADDR => 
                csr_rdata <= mscratch;
            when MEPC_ADDR =>
                csr_rdata <= mepc;
            when MCAUSE_ADDR =>
                csr_rdata <= mcause;
            when MIP_ADDR =>
                csr_rdata <= mip;
            when others =>
                csr_rdata <= (others => '0');
          end case;
          if on_exc_we = '1' then 
            mstatus <= mstatus_i;
            mepc    <= mepc_i;
            mtvec   <= mtvec_i;
            mcause  <= mcause_i;
          elsif csr_we = '1' then 
             case (csr_addr) is 
                 when MSTATUS_ADDR => 
                      mstatus <= csr_wdata_i;
                 when MSCRATCH_ADDR =>
                      mscratch <= csr_wdata_i;
                 when MEPC_ADDR =>
                      mepc <= csr_wdata_i;
                 when MTVEC_ADDR =>
                      mtvec <= csr_wdata_i;
                 when MCAUSE_ADDR =>
                      mcause <= csr_wdata_i;
                 when MIP_ADDR =>
                      mip <= csr_wdata_i;
                 when MIE_ADDR => 
                      mie <= csr_wdata_i;
                 when others => 
                      null;
                 end case;
           end if;
        end if;
    end if;
end process;
csr_rdata_o <= csr_rdata;
--Interrupts controller 
mstatus_o <= mstatus;
mepc_o    <= mepc_o;
mtvec_o   <= mtvec_o;
mcause_o  <= mcause_o;

end architecture;
