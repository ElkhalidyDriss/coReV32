

library ieee;
use ieee.std_logic_1164.all;

package rv_package is 
------------------------------------------------                                       
--                Fetch Unit                  --
------------------------------------------------                                  
--program counter update value options
constant PC_RST : std_logic_vector(2 downto 0) :="000";-- address of the instruction to be executed after reset
constant PC_INCREMENT : std_logic_vector(2 downto 0) :="001";
constant PC_BRANCH : std_logic_vector(2 downto 0) :="010";--address of the branch target
constant PC_JUMP : std_logic_vector(2 downto 0) :="011";--address of the jump target 
constant PC_MPEC_RESTORE : std_logic_vector(2 downto 0) :="100";--restor the value of saved pc in the mepc register
constant PC_EXC : std_logic_vector(2 downto 0) :="101";--address of the exception handler
--Exception cause 
--! values should be reassinged for solving alignment issues
constant MTIMER_INTERRUPT : std_logic_vector(1 downto 0) :="00";
constant EXT_INTERRUPT : std_logic_vector(1 downto 0) :="01";
constant ILLEGAL_INSTRUCTION : std_logic_vector(1 downto 0) :="10";
---alu
--alu operations
constant ALU_ADD  : std_logic_vector(3 downto 0) :="0000";
constant ALU_SUB  : std_logic_vector(3 downto 0) :="1000";
constant ALU_SLL  : std_logic_vector(3 downto 0) :="0001";
constant ALU_SLT  : std_logic_vector(3 downto 0) :="0010";--Set Less Than
constant ALU_SLTU : std_logic_vector(3 downto 0) :="0011";
constant ALU_XOR  : std_logic_vector(3 downto 0) :="0100";
constant ALU_SRL  : std_logic_vector(3 downto 0) :="0101";
constant ALU_SRA  : std_logic_vector(3 downto 0) :="1101";
constant ALU_OR   : std_logic_vector(3 downto 0) :="0110";
constant ALU_AND  : std_logic_vector(3 downto 0) :="0111";

constant ALU_EQ   : std_logic_vector(3 downto 0) :="1111";--for equality test
--ALU Operands sources 
constant ALU_OPERAND_RS1          : std_logic_vector(2 downto 0) :="000";--ALU operand source is reg file source 1
constant ALU_OPERAND_RS2          : std_logic_vector(2 downto 0) :="001";--ALU operand source is reg file source 2
constant ALU_OPERAND_PC           : std_logic_vector(2 downto 0) :="010";--ALU operand src is pc_curr + 4 
constant ALU_OPERAND_SRC_CSR      : std_logic_vector(2 downto 0) :="011";--alu operand A source is value of CSR
constant ALU_OPERAND_SRC_IMM      : std_logic_vector(2 downto 0) :="100";--alu operand  source is immediate value
constant ALU_OPERAND_RS1_BAR      : std_logic_vector(2 downto 0) :="101";--alu operand is the negative value of RS1


----register file 
--Write data source 
constant W_SRC_ALU_RES    : std_logic_vector(2 downto 0) :="000";--write data source comes from alu result
constant W_SRC_CSR        : std_logic_vector(2 downto 0) :="001";--write data source comes from a control and status register
constant W_SRC_PC_PLUS_4     : std_logic_vector(2 downto 0) :="010";--write data  is  pc_curr+4
constant W_SRC_DATA_MEM   : std_logic_vector(2 downto 0) :="011";--write data source comes from data memory output 
constant W_SRC_IMM        : std_logic_vector(2 downto 0) :="100";--write data source comes from extended imm_u value
--CSR unit 
--! if there is only read and write operantion change the bits length 
constant CSR_OP_READ  : std_logic_vector(1 downto 0):="00";
constant CSR_OP_WRITE : std_logic_vector(1 downto 0):="01";

--------------------------------------------------------
--                      OPCODE                        --
--------------------------------------------------------
constant LUI   : std_logic_vector(6 downto 0) :="0110111";--Load Upper Immediate 
constant AUIPC : std_logic_vector(6 downto 0) :="0010111";--Add Upper Immediate to PC
constant JAL   : std_logic_vector(6 downto 0) :="1101111" ;--Jump and Link
constant JALR  : std_logic_vector(6 downto 0) :="1100111";--Jump and link register

--Branch instructions
constant BRANCH : std_logic_vector(6 downto 0) :="1100011";
        constant BEQ  : std_logic_vector(2 downto 0) :="000";
        constant BNE  : std_logic_vector(2 downto 0) :="001";
        constant BLT  : std_logic_vector(2 downto 0) :="100";
        constant BGE  : std_logic_vector(2 downto 0) :="101";
        constant BLTU : std_logic_vector(2 downto 0) :="110";
        constant BGEU : std_logic_vector(2 downto 0) :="111";
--Load instructions
constant LD : std_logic_vector(6 downto 0) := "0000011";
         constant LB : std_logic_vector(2 downto 0) :="000";--Load byte
         constant LH : std_logic_vector(2 downto 0) :="001";--Load Half word (2 bytes)
         constant LW : std_logic_vector(2 downto 0) :="010";--Load Word
         constant LBU : std_logic_vector(2 downto 0) :="100";--load byte unsigned 
         constant LHU : std_logic_vector(2 downto 0) :="101";--load half word unsigned
--Store instructions 
constant STR : std_logic_vector(6 downto 0) :="0100011";
         constant SB : std_logic_vector(2 downto 0) := "000";--Store byte
         constant SH : std_logic_vector(2 downto 0) := "001";--Store half word
         constant SW : std_logic_vector(2 downto 0) := "010";--Store word
--Arithemtic operations instructions 
constant OP     : std_logic_vector(6 downto 0) :="0110011";--Register to Register arithmetic 
constant OP_IMM : std_logic_vector(6 downto 0) :="0010011";--Register to Immediates arithemtic
        constant ADD_OP  : std_logic_vector(3 downto 0) :="0000";
        constant SUB_OP  : std_logic_vector(3 downto 0) :="1000";
        constant SLL_OP  : std_logic_vector(3 downto 0) :="0001";--Logical left shift
        constant SLT_OP  : std_logic_vector(3 downto 0) :="0010";
        constant SLTU_OP : std_logic_vector(3 downto 0) :="0011";
        constant XOR_OP  : std_logic_vector(3 downto 0) :="0100";
        constant SRL_OP  : std_logic_vector(3 downto 0) :="0101";
        constant SRA_OP  : std_logic_vector(3 downto 0) :="1101";
        constant OR_OP   : std_logic_vector(3 downto 0) :="0110";
        constant AND_OP  : std_logic_vector(3 downto 0) :="0111";
--CSR instructions
constant CSR : std_logic_vector(6 downto 0) :="1110011";--Opcode for CSR instructions
         constant CSRRW  : std_logic_vector(2 downto 0) :="001";--CSR Read/Write
         constant CSRRS  : std_logic_vector(2 downto 0) :="010";--CSR Read and Set Bit
         constant CSRRC  : std_logic_vector(2 downto 0) :="011";--CSR Read and Clear bit
         constant CSRRWI : std_logic_vector(2 downto 0) :="101";--CSR Read and Write Immediate
         constant CSRRSI : std_logic_vector(2 downto 0) :="110";--CSR Read and Set Immediate
         constant CSRRCI : std_logic_vector(2 downto 0) :="111";--CSR Read and Clear Immediate

 --CSR write sources
 constant CSR_W_SRC_RS1     : std_logic_vector(1 downto 0) :="00";
 constant CSR_W_SRC_ALU_RES : std_logic_vector(1 downto 0) :="01"; 
 constant CSR_W_SRC_IMM     : std_logic_vector(1 downto 0) :="10";

         
--Extend Unit 
constant I_IMM : std_logic_vector(2 downto 0) :="000";     
constant S_IMM : std_logic_vector(2 downto 0) :="001";
constant B_IMM : std_logic_vector(2 downto 0) :="010";
constant U_IMM : std_logic_vector(2 downto 0) :="011";
constant J_IMM : std_logic_vector(2 downto 0) :="100";
constant Z_IMM  : std_logic_vector(2 downto 0) :="101";--zero extended immediate
constant Z_IMM_BAR : std_logic_vector(2 downto 0) :="110";
end package;