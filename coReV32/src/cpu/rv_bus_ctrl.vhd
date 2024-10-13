
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



entity rv_bus_ctrl is 
port (
       addr_bus : in std_logic_vector(31 downto 0);
       prog_mem_sel : out  std_logic;
       data_mem_sel : out std_logic);    
end entity;
----------------------Memory Map----------------------
--                                                  --
-- program memory 0x0000_0000 -> 0x0000_0FFF (4KB)  --
--                                                  --
-- data memory    0x0000_1000 -> 0x0000_17FF (2KB)  --
--                                                  --
------------------------------------------------------
architecture rv_bus_ctrl_arch of rv_bus_ctrl is

begin
process(addr_bus)
begin
     --Default
       prog_mem_sel <= '0';
       data_mem_sel <='0';
     case(to_integer(unsigned(addr_bus))) is 
     when 0 to 4095 => 
           prog_mem_sel <= '1';
           data_mem_sel <= '0';
     when 4096 to 6143 => 
           prog_mem_sel <= '0';
           data_mem_sel <= '1';
     when others => null;
     end case;
end process;

end architecture;
