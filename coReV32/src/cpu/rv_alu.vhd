---------------------------------------------------------------------------------------
--  Author: Driss Elkhalidy , an embedded systems engineering student                -- 
--          at National Institute of Posts and Telecommunications , Rabat , Morocco. --
--  Description : Implementation of the arithmetic and logic unit for risc-v in VHDL --
---------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity rv_alu is  generic ( DATA_WIDTH : natural := 32);
port ( valA , valB : in std_logic_vector(DATA_WIDTH - 1 downto 0);--ALU input operands
       alu_ctrl : in std_logic_vector(3 downto 0); --Control bits
       alu_res : out std_logic_vector(DATA_WIDTH - 1 downto 0); -- ALU result
       aluEQ : out std_logic); -- equal flag , active high when srcA = srcB
end entity;


architecture rv_alu_arch of rv_alu is 
begin
ALU:process(alu_ctrl , valA , valB)
begin
     case(alu_ctrl) is
          when "0000" => --add,addi
                         alu_res  <= std_logic_vector(signed(valA) + signed(valB));
          when "1000" => --sub 
                         alu_res  <= std_logic_vector(signed(valA) - signed(valB));
          when "0001" => --sll,slli
                         alu_res <= std_logic_vector(shift_left(unsigned(valA), to_integer(unsigned(valB(4 downto 0)))));
          when "0010" => --slt,slti
                         if (signed(valA) < signed(valB)) then 
                             alu_res <= x"00000001";
                         else 
                             alu_res <= (others => '0');
                         end if;
          when "0011" => --sltu,sltiu
                         if (unsigned(valA) < unsigned(valB)) then 
                             alu_res <= x"00000001";
                         else 
                             alu_res <= (others => '0');
                         end if;
          when "0100" => --xor,xori
                         alu_res <= valA xor valB;
          when "0101" => --srl,srli
                         alu_res <= std_logic_vector(shift_right(unsigned(valA), to_integer(unsigned(valB(4 downto 0)))));
          when "1101" => --sra,srai
                         alu_res <= std_logic_vector(shift_right(signed(valA) , to_integer(unsigned(valB(4 downto 0)))));
          when "0110" => --or,ori
                         alu_res <= valA or valB;
          when "0111" => --and,andi
                         alu_res <= valA and valB; 
          when others => alu_res <= (others => '0'); 
          end case ;
end process;
EQ_FLAG : process(valA , valB)
          begin
               if (valA = valB) then -- srcA = srcB
                  aluEQ <= '1';
               else 
                  aluEQ <= '0';
               end if;
           end process;
end architecture;