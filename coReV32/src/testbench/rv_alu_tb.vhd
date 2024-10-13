--------------------------------------------------------------------------------
--  Author: Driss Elkhalidy , an embedded systems engineering student 
--          at National Institute of Posts and Telecommunications , Rabat , Morocco.
--  Description : rv_alu testbench
--  Depedency   : rv_alu.vhd 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity rv_alu_tb is 
end entity;

architecture rv_alu_tb_arch of rv_alu_tb is 
signal srcA_tb , srcB_tb : std_logic_vector(31 downto 0) :=(others =>'0');
signal alu_ctrl_tb : std_logic_vector(3 downto 0) :=(others => '0');
signal alu_res_tb  : std_logic_vector(31 downto 0) :=(others => '0');
signal aluEQ_tb : std_logic :='0';
component  rv_alu is  generic ( DATA_WIDTH : natural := 32);
port ( srcA , srcB : in std_logic_vector(DATA_WIDTH - 1 downto 0);--ALU input operands
       alu_ctrl : in std_logic_vector(3 downto 0); --Control bits
       alu_res : out std_logic_vector(DATA_WIDTH - 1 downto 0); -- ALU result
       aluEQ  : out std_logic); -- equal flag
end component;
begin
DUT : rv_alu port map ( srcA => srcA_tb , srcB => srcB_tb , alu_ctrl => alu_ctrl_tb , alu_res => alu_res_tb , aluEQ => aluEQ_tb);
STIMILUS : process
           begin
                wait for 10 ns;
                srcA_tb <= x"00000001";
                srcB_tb <= x"00000001";
                alu_ctrl_tb <= "0000"; --add
                wait for 10 ns;
                srcA_tb <= x"FFFFF9E8";
                srcB_tb <= x"00000001";
                alu_ctrl_tb <= "0000"; --add
                wait for 10 ns;
                srcA_tb <= x"00000001";
                srcB_tb <= x"00000001";
                alu_ctrl_tb <= "1000"; --sub
                wait for 10 ns;
                srcA_tb <= x"FFFFF9E8";
                srcB_tb <= x"000F0001";
                alu_ctrl_tb <= "1000"; --sub
           end process;
end architecture;