
---------------------------------------------------------------------------------------
--  Author: Driss Elkhalidy , an embedded systems engineering student                -- 
--          at National Institute of Posts and Telecommunications , Rabat , Morocco. --
--  Description : Implementation of the control unit of the coReV32.                 --
--  Dependencies : 
---------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.rv_package.all;

entity rv_ctrl_unit is
port (
       clk , rst_n : in std_logic;
       --Instruction fields
       funct3 : in std_logic_vector(2 downto 0);--Selects the operation to be performed by ALU
       funct7 : in std_logic; --Selects the operation to be performed bu the alu 
                             --! funct7 is a field of bits but we only need a specific bit to decide on the operation
       imm    : in std_logic_vector(20 downto 0);--Immediates have variable length from 12 to 21 bits
                                                   -- length depends on instruction type
       opcode : in std_logic_vector(6 downto 0);
       csr_addr : out std_logic_vector(11 downto 0);--Control & status register address 
       --Program counter control bits
       pc_adder_src : out std_logic_vector(1 downto 0);
       pc_next_src : out std_logic_vector(1 downto 0);
       --Program memory control bits
       prg_mem_en : out std_logic;
       prg_mem_we : out std_logic;
       --Data memory control bits
       data_mem_word_z : out std_logic_vector(1 downto 0); -- word size to be retrieved from memory (byte , short or int)
       data_mem_we : out std_logic;--data memory write enable
       --ALU control bits & flag
       aluEQ , aluGT , aluLT: in std_logic;-- the Equal  , Greater Than  and Less Than ALU flags
       valA_src : out std_logic;
       valB_src : out std_logic;
       --Extend unit control
       ext_src : out std_logic(1 downto 0);--source of the extend immediate value
       --Register file control bits
       reg_file_we : out std_logic;--write enable 
       reg_file_wdata_src : out std_logic_vector(1 downto 0);--the source of the data to be written in the address 
                                                             --specified by the waddr (write address)
       --Control & Status Reg control bits
         
); 
end entity;


architecture rv_ctrl_unit_arch of rv_ctrl_unit is 


begin
alu_control : process(funct3 , funct7 , opcode)
              begin
                   case(opcode) is
                   when ""
                        
                    
              end process;



end architecture;
