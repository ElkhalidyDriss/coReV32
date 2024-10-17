--------------------------------------------------------------------------------------
--  Author: Driss Elkhalidy , an embedded systems engineering student               --
--          at National Institute of Posts and Telecommunications , Rabat , Morocco.--
--  Description : Implementation of register file of risc-v in VHDL                 --
--------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity rv_reg_file is 
port ( clk  : in std_logic;
       --Read port
       raddr1 : in std_logic_vector(4 downto 0);--read address for port 1 
       raddr2 : in std_logic_vector(4 downto 0);--read address for port 2
       rdata1 : out std_logic_vector(31 downto 0);--data output of port 1
       rdata2 : out std_logic_vector(31 downto 0);--data output of port 2
       --write port 
       waddr    : in std_logic_vector(4 downto 0); --address of the register we want to write into
       wdata    : in std_logic_vector(31 downto 0); --the data should be written into the reg specified by waddr
       we       : in std_logic--write enable 
      );
end entity;

architecture rv_reg_file_arch of rv_reg_file is 
type regs_array is array (0 to 31) of std_logic_vector(31 downto 0);
signal regs : regs_array :=(others => (others => '0')) ;--registers x0 , x1 ... x31
constant ZERO : std_logic_vector(4 downto 0) :=(others => '0');

begin 
process (clk)
begin 
     if rising_edge(clk) then 
        if (we = '1' and waddr /= ZERO) then --Ensuring that the x0 reg remains zero 
            regs(to_integer(unsigned(waddr))) <= wdata;
         end if;
      end if;
end process;
rdata1 <= regs(to_integer(unsigned(raddr1)));
rdata2 <= regs(to_integer(unsigned(raddr2)));
end architecture;