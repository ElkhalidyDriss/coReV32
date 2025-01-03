---------------------------------------------------------------------------------------
--  Author: Driss Elkhalidy , an embedded systems engineering student                -- 
--          at National Institute of Posts and Telecommunications , Rabat , Morocco. --
--  Description : Implementation of the arithmetic and logic unit for risc-v in VHDL --
---------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.rv_package.all;


entity rv_alu is 
port ( valA , valB : in  std_logic_vector(31 downto 0);--ALU input operands
       alu_op      : in  std_logic_vector(3 downto 0); --alu operation
       alu_res     : out std_logic_vector(31 downto 0); -- ALU result
       aluEQ       : out std_logic); -- equal flag , active high when srcA = srcB
end entity;


architecture rv_alu_arch of rv_alu is 
begin
ALU:process(alu_op , valA , valB)
begin
     case(alu_op) is
          when ADD_OP => 
               alu_res  <= std_logic_vector(signed(valA) + signed(valB));
          when SUB_OP => 
               alu_res  <= std_logic_vector(signed(valA) - signed(valB));
          when SLL_OP => 
               alu_res <= std_logic_vector(shift_left(unsigned(valA), to_integer(unsigned(valB(4 downto 0)))));
          when SLT_OP => --slt,slti
                if (signed(valA) < signed(valB)) then 
                    alu_res <= x"00000001";
                else 
                    alu_res <= (others => '0');
                end if;
          when SLTU_OP => --sltu,sltiu
                if (unsigned(valA) < unsigned(valB)) then 
                    alu_res <= x"00000001";
                else 
                    alu_res <= (others => '0');
                end if;
          when XOR_OP => --xor,xori
               alu_res <= valA xor valB;
          when SRL_OP => --srl,srli
               alu_res <= std_logic_vector(shift_right(unsigned(valA), to_integer(unsigned(valB(4 downto 0)))));
          when SRA_OP => --sra,srai
               alu_res <= std_logic_vector(shift_right(signed(valA) , to_integer(unsigned(valB(4 downto 0)))));
          when OR_OP => --or,ori
               alu_res <= valA or valB;
          when AND_OP  => --and,andi
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