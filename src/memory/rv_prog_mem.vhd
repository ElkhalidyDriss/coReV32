
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



entity rv_prog_mem is 
port ( 
         clk : in std_logic;
         we          : in std_logic;--write enable
         mem_en          : in std_logic;--memory enable
         addr : in std_logic_vector(31 downto 0);
         data_in : in std_logic_vector(31 downto 0);
         data_out : out std_logic_vector(31 downto 0));
end entity;

architecture rv_prog_mem_arch of rv_prog_mem is 
type memory_t is array (0 to 4095) of std_logic_vector(31 downto 0);--
signal prog_mem : memory_t ;

begin
process (clk)
begin
        if (rising_edge(clk)) then
            if (mem_en = '1') then
                if (we = '1') then
                    prog_mem(to_integer(unsigned(addr))) <= data_in;
                else 
                    data_out <= prog_mem(to_integer(unsigned(addr)));
                end if;
             end if;
         end if;
end process;
end architecture;
        
