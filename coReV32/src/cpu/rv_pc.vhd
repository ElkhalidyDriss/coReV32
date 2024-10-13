library ieee;
use ieee.std_logic_1164.all;

entity rv_pc is generic (RST_ADDR : std_logic_vector(31 downto 0) := x"00000000");--the address of the first
                                                                                  --instruction to be executed after reset.
port ( clk , rst_n: in std_logic;--active low reset
       pc_next : in std_logic_vector(31 downto 0);
       pc_curr : out std_logic_vector(31 downto 0));
end entity;

architecture rv_pc_arch of rv_pc is 
begin
process(clk)
begin
     if (rising_edge(clk)) then
         if (rst_n = '0') then
             pc_curr <= rst_addr;
         else 
             pc_curr <= pc_next;
         end if;
     end if;
end process;
end architecture;