---------------------------------------------------------------------------------------
--  Author: Driss Elkhalidy , an embedded systems engineering student                --
--          at National Institute of Posts and Telecommunications , Rabat , Morocco. --
--  Description : Implementation of decode stage for coReV32 in VHDL.                     --
---------------------------------------------------------------------------------------



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.rv_package.all;


entity rv_decode is 
port (
    clk , rst_n : std_logic;

    instr_data : in std_logic_vector(31 downto 0);
    instr_addr : in std_logic_vector(31 downto 0);--current instruction address
    pc_plus_4  : in std_logic_vector(31 downto 0);--next instruction address
    --Register file
   reg_f_rdata1 : out std_logic_vector(4 downto 0);--read address for port 1 
   reg_f_rdata2 : out std_logic_vector(4 downto 0);--read address for port 2
   
);
end entity;

architecture rv_decode is 

begin

end architecture;