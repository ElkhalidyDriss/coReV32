library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rv_prog_mem_tb is 
end entity;

architecture rv_prog_mem_tb_arch of rv_prog_mem_tb is 
    signal clk_tb, we_tb, mem_en_tb: std_logic;
    signal addr_tb: std_logic_vector(31 downto 0);
    signal data_in_tb, data_out_tb: std_logic_vector(31 downto 0);
    constant T: time := 10 ns; -- Clock period
    constant MEM_SIZE: integer := 10; -- Number of memory locations
    constant ADDR_WIDTH: integer := 32; -- Address width for 4096 words

    component rv_prog_mem 
    port ( 
         clk: in std_logic;
         we: in std_logic; -- Write enable
         mem_en: in std_logic; -- Memory enable
         addr: in std_logic_vector(31 downto 0);
         data_in: in std_logic_vector(31 downto 0);
         data_out: out std_logic_vector(31 downto 0)
    );
    end component;
begin
    DUT: rv_prog_mem port map ( 
        clk => clk_tb, 
        we => we_tb, 
        mem_en => mem_en_tb, 
        addr => addr_tb, 
        data_in => data_in_tb, 
        data_out => data_out_tb 
    );

    CLOCK: process
    begin
        clk_tb <= '1'; 
        wait for T / 2;
        clk_tb <= '0'; 
        wait for T / 2;
    end process;

    STIMULUS: process
    begin
        mem_en_tb <= '1'; 
        we_tb <= '1'; 
        for i in 0 to (MEM_SIZE - 1) loop
            addr_tb <= std_logic_vector(to_unsigned(i, ADDR_WIDTH));
            data_in_tb <= std_logic_vector(to_unsigned(i * 10, 32)); 
            wait for T;
            report "Write data to address " & integer'image(i) & ": " & integer'image(to_integer(unsigned(data_out_tb)));
        end loop;

        we_tb <= '0'; 

        for i in 0 to (MEM_SIZE - 1) loop
            addr_tb <= std_logic_vector(to_unsigned(i, ADDR_WIDTH));
            wait for T; -- Wait for the clock edge
            report "Read data from address " & integer'image(i) & ": " & integer'image(to_integer(unsigned(data_out_tb)));
        end loop;

        wait;
    end process;

end architecture;

