
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rv_csr_unit is 

port (
      clk , rst_n : std_logic;
      --Read/Write interfaces 
      csr_addr  : in std_logic_vector(11 downto 0);--Control and Status Register Address
      csr_op    : in std_logic_vector(1 downto 0);--CSR operation ; 
                                                    --00 : read 
                                                   -- 01 : write 
                                                   -- 10 : set bits 
                                                   -- 11 : clear bits
      csr_rdata   : out std_logic_vector(31 downto 0);--CSR output read data 
);

end entity;

architecture rv_csr_unit_arch of rv_csr_unit is
------------------------------------------------
--     RISC-V machine-level CSR addresses     --
------------------------------------------------
--Machine Information Registers
constant MVENDORID_ADDR : std_logic_vector(11 downto 0) :=x"F11";--Vendor ID
constant MARCHID_ADDR : std_logic_vector(11 downto 0) :=x"F12";--Architecture ID
constant MIMPID_ADDR : std_logic_vector(11 downto 0) :=x"F13";--Implementation ID
constant MHARTID_ADDR : std_logic_vector(11 downto 0) :=x"F14";--Hardware thread ID
--Machine Trap Setup
constant MSTATUS_ADDR   : std_logic_vector(11 downto 0) := x"300";  -- Machine status register
constant MISA_ADDR      : std_logic_vector(11 downto 0) := x"301";  -- ISA and extensions
constant MEDELEG_ADDR   : std_logic_vector(11 downto 0) := x"302";  -- Machine exception delegation register
constant MIDELEG_ADDR   : std_logic_vector(11 downto 0) := x"303";  -- Machine interrupt delegation register
constant MIE_ADDR       : std_logic_vector(11 downto 0) := x"304";  -- Machine interrupt-enable register
constant MTVEC_ADDR     : std_logic_vector(11 downto 0) := x"305";  -- Machine trap-handler base address
constant MCOUNTEREN_ADDR: std_logic_vector(11 downto 0) := x"306";  -- Machine counter enable
--Machine Trap Handling
constant MSCRATCH_ADDR : std_logic_vector(11 downto 0) := x"340";  -- Scratch register for machine trap handlers
constant MEPC_ADDR     : std_logic_vector(11 downto 0) := x"341";  -- Machine exception program counter
constant MCAUSE_ADDR   : std_logic_vector(11 downto 0) := x"342";  -- Machine trap cause
constant MTVAL_ADDR    : std_logic_vector(11 downto 0) := x"343";  -- Machine bad address or instruction
constant MIP_ADDR      : std_logic_vector(11 downto 0) := x"344";  -- Machine interrupt pending
------------------------------------------------
--     RISC-V machine-level CSR Registers     --
------------------------------------------------
constant MISA : std_logic_vector(31 downto 0) :=x"40000080";--RV32I
constant MVENDORID : std_logic_vector(31 downto 0) (others => '0');
constant MARCHID : std_logic_vector(31 downto 0);

signal mstatus : std_logic_vector(31 downto 0) := (others => '0');--Machine Status Register
signal mtvec : std_logic_vector(31 downto 0) :=(others => '0'); --Machine Trap-Vector Base-Address Register
signal mip : std_logic_vector(31 downto 0):=(others => '0');--Machine Interrupt Pending Register
signal mie : std_logic_vector(31 downto 0):=(others => '0');--Machine Interrupt Enable Register
signal mtime : std_logic_vector(63 downto 0);--Machine time register (Memory mapped control register)
signal mtimecmp : std_logic_vector(63 downto 0);-- Machine time compare register (memory-mapped control register).


begin
read_logic : process(csr_addr)
             begin
                  case(csr_addr) is 
                       when MISA_ADDR => csr_rdata <= MISA;
                       when MVENDORID_ADDR => csr_rdata <= MVENDORID;	
                       
             end process;




end architecture;
