---------------------------------------------------------------------------------------
--  Author: Driss Elkhalidy , an embedded systems engineering student                --
--          at National Institute of Posts and Telecommunications , Rabat , Morocco. --
--  Description : Implementation of Fetch unit for  coReV32 in VHDL.                 --
---------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.rv_package.all;
entity rv_fetch is generic ( BOOT_ADDR : std_logic_vector(31 downto 0) :=x"00000000");--provides the address of the instruction to be executed after reset
port (
	   clk , rst_n : in std_logic;--clock and active low reset
        --Control signals
        pc_next_src : in std_logic_vector(2 downto 0);
        pc_hold     : in std_logic;--flag indicates hold the current value of the program counter
        --program counter update sources
        branch_target : in std_logic_vector(31 downto 0); --branch target address
        jump_target   : in std_logic_vector(31 downto 0); --jump target address
        csr_mepc      : in std_logic_vector(31 downto 0); --Machine Exception Program Counter
        --Exception/Interrupt handler address
        mtvec : in std_logic_vector(31 downto 0);--Machine trap-vector base-address register
        exc_cause : in std_logic_vector(1 downto 0);
        --pipeline control
        stall : in std_logic;--high when hazards are detected
        instr_req : in std_logic;--decode stage is requesting  next instruction
        --Program memory 
        prog_mem_raddr : out std_logic_vector(31 downto 0);--program memory read address
        prog_mem_data_in : in std_logic_vector(31 downto 0);--program_memory(prog_mem_raddr)
        prog_mem_valid_o  : in std_logic ; --valid output from the program memory 
        prog_mem_req     : out std_logic;--request instruction from the memory
        --Fetch-Decode interface
        instr_data  : out std_logic_vector(31 downto 0);
        instr_addr : out std_logic_vector(31 downto 0);
        pc_plus_4 : out std_logic_vector(31 downto 0);
        instr_ready : out std_logic  --valid output from the fetch stage
);
end entity;

architecture rv_fetch_arch of rv_fetch is
signal pc_curr , pc_next : std_logic_vector(31 downto 0);--program counter signals
signal pc_plus_4_int : std_logic_vector(31 downto 0);--pc_curr+4 internal signal

signal exc_handler : std_logic_vector(31 downto 0);--branch to the exception handler
signal instr_ready_int : std_logic;--internal instruction ready signal
begin
exc_handler <= std_logic_vector(unsigned(mtvec) + unsigned(exc_cause));--base + exception_cause
pc_plus_4_int <= std_logic_vector(unsigned(pc_curr) + 4);
prog_mem_raddr <= pc_curr;
PC : process(clk)
     begin
          if rising_edge(clk) then
             if rst_n = '0' then
                pc_curr <= BOOT_ADDR(31 downto 2)&"00";--MAking sure instruction address is aligned 
                prog_mem_req <= '1';
             else
                 if (prog_mem_valid_o = '1' and stall = '0' and instr_req = '1' and pc_hold='0' ) then --fetch the next instruction
                     pc_curr <= pc_next;
                     prog_mem_req <= '1';
                 else 
                     prog_mem_req <= '0';
                 end if;
              end if;
          end if;
     end process;

PC_NEXT_LOGIC : process(pc_next_src)
                begin
                     case(pc_next_src) is
                          when (PC_RST)  => 
                               pc_next <= BOOT_ADDR(31 downto 2)&"00";--Making sure the address is aligned
                          when (PC_INCREMENT) =>
                               pc_next <= pc_plus_4_int;--next instruction
                          when (PC_BRANCH) => 
                              pc_next <= branch_target;--branch target addres
                          when (PC_JUMP) => 
                               pc_next <= jump_target;--jump target address
                          when (PC_EXC) =>
                               pc_next <= exc_handler;--branch to exception handler
                          when (PC_MPEC_RESTORE) =>
                               pc_next <= csr_mepc;--Restore pc after finishing exception handling 
                          when others => 
                               pc_next <= pc_curr; 
                          end case;  
                end process;

instr_ready_int <= prog_mem_valid_o and not(stall) and not(pc_hold) and instr_req and valid_branch_i = '1' when branch = '1' 
                   else prog_mem_valid_o and not(stall) and not(pc_hold) and instr_req;
instr_ready <= instr_ready_int;
process(instr_ready_int)
               begin
                    if(instr_ready_int = '1') then
                         instr_data  <=  prog_mem_data_in;
                         instr_addr  <=  pc_curr;
                         pc_plus_4 <= pc_plus_4_int;
                    end if;
              end process;
end architecture;   