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
    rst_n       : in std_logic;--active low reset
    
    csr_addr    : in std_logic_vector(11 downto 0);--control & status register address
    csr_wdata_i : in std_logic_vector(31 downto 0);--csr write data in 
    csr_rdata_o : out std_logic_vector(31 downto 0);--csr read data output 
);
end entity;

architecture rv_csr_unit_arch of rv_csr_unit is

begin
    
end architecture;
