---------------------------------------------------------------------------------------
--  Author: Driss Elkhalidy , an embedded systems engineering student                -- 
--          at National Institute of Posts and Telecommunications , Rabat , Morocco. --
--  Description : rv_extend testbench                				     --
--  Depedency   : rv_extend.vhd          					     --
---------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity rv_extend_tb is 
end entity;

architecture rv_extend_tb_arch of rv_extend_tb is 
signal imm_type_tb :  std_logic_vector(1 downto 0);
signal imm_val_tb  : std_logic_vector(20 downto 0);
signal imm_val_ext_tb  : std_logic_vector(31 downto 0);
component rv_extend
port(
      imm_type : in std_logic_vector(1 downto 0);--the type of the immediate value 
                                              --00 : I-immediate or S-immediate
                                              --01 : B-immediate 
                                              --10 : U-immediate 
                                              --11 : J-immediate
      imm_val  : in std_logic_vector(20 downto 0);--immediate value 
      imm_val_ext  : out std_logic_vector(31 downto 0));--the extended value of the immediate
end component;
begin
DUT : rv_extend port map ( imm_type => imm_type_tb , imm_val => imm_val_tb , imm_val_ext => imm_val_ext_tb);
STIMILUS : process
           begin



           end process;
end architecture;
