---------------------------------------------------------------------------------------
--  Author: Driss Elkhalidy , an embedded systems engineering student                -- 
--          at National Institute of Posts and Telecommunications , Rabat , Morocco. --
--  Description : Implementation of the extend unit of immediate values in VHDL 
--                Takes immediate value and sign-extend it to 32 bits
---------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity rv_extend is 
port (
      imm_type : in std_logic_vector(1 downto 0);--the type of the immediate value 
                                              --00 : I-immediate or S-immediate
                                              --01 : B-immediate 
                                              --10 : U-immediate 
                                              --11 : J-immediate
      imm_val  : in std_logic_vector(20 downto 0);--immediate value 
      imm_val_ext  : out std_logic_vector(31 downto 0));--the extended value of the immediate
end entity;

architecture rv_extend_arch of rv_extend is 


begin
     process(imm_type , imm_val)
     begin 
 	  case(imm_type) is 
          when "00"  => --Immediate encoding for I-type or S-type 
                       imm_val_ext <= (31 downto 12 => imm_val(11))&imm_val(11 downto 0);
          when "01" => --Immediate encoding for B-type
                        imm_val_ext <= (31 downto 12 => imm_val(12))&imm_val(11 downto 1)&'0';
          when "10"  => --Immediate encoding for U-type 
                        imm_val_ext <= (imm_val(19 downto 0))&(11 downto 0 =>'0');
          when "11" => --Immediate encoding for J-type
                        imm_val_ext <= (31 downto 20 => imm_val(20))&imm_val(19 downto 1)&'0';
          when others => null;
          end case;
     end process;
end architecture;