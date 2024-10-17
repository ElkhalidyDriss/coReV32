---------------------------------------------------------------------------------------
--  Author: Driss Elkhalidy , an embedded systems engineering student                --
--          at National Institute of Posts and Telecommunications , Rabat , Morocco. --
--  Description : Implementation of decode stage for coReV32 in VHDL.                --
---------------------------------------------------------------------------------------



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.rv_package.all;


entity rv_decode is 
port (
   clk   : in std_logic;
   rst_n : in std_logic;--active low reset
   --fetch unit
   pc_hold       : out std_logic;
   fetch_valid_o : in std_logic;
   pc_next_src   : out std_logic_vector(2 downto 0);
   instr_data_fd : in std_logic_vector(31 downto 0);--instruction data comming from fetch to decode stage
   instr_addr_fd : in std_logic_vector(31 downto 0);--current instruction address comming from fetch to decode
   pc_plus_4_fd  : in std_logic_vector(31 downto 0);--next instruction address
   illegal_instr_o : out std_logic;
   --Execute unit
   instr_addr_dx : out std_logic_vector(31 downto 0);--current instruction address comming from decode to execute stage
   pc_plus_4_dx  : out std_logic_vector(31 downto 0);--next instruction address
   valid_pc_update : in std_logic;--valid value of the pc update comming from the execute stage
   --
   pc_plus_4_wb   : in std_logic_vector(31 downto 0);--current program counter + 4 from write back stage
   
   --Register file
   reg_f_rdata1_dx     : out std_logic_vector(31 downto 0);--read address for port 1 
   reg_f_rdata1_bar_dx : out std_logic_vector(31 downto 0);--not logic of reg_f_rdata1
   reg_f_rdata2_dx     : out std_logic_vector(31 downto 0);--read address for port 2
   reg_f_waddr_dx      : out std_logic_vector(4 downto 0);--address of the destination register 
   reg_f_we_dx         : out std_logic;
   reg_f_we_wb         : in std_logic;
   --ALU 
   alu_operand_a_val_dx : out std_logic_vector(31 downto 0);
   alu_operand_a_val_dx : out std_logic_vector(31 downto 0);

   alu_operand_a_src_dx : out std_logic_vector(2 downto 0);--alu operand a source 
   alu_operand_b_src_dx : out std_logic_vector(2 downto 0);--alu operand b source 
   alu_op_dx            : out std_logic_vector(3 downto 0);--alu operation
   alu_res_wb           : in  std_logic_vector(31 downto 0);--alu result from write back stage 
   --Branch/JUMP
   branch_t_dx : out std_logic_vector(2 downto 0);--branch type (BEQ , BNE , BLT , BGE , BLTU , BGEU)
   jump_t_dx   : out std_logic;--jump type
                             -- '0' JAL 
                             -- '1' JALR
   --Data Memory
   data_mem_size_dx  : out std_logic_vector(2 downto 0); -- word size to be retrieved from memory (byte , short or int)
   data_mem_we_dx    : out std_logic;--data memory write enable
   data_mem_en_dx    : out std_logic;--data memory enable
   data_mem_rdata_wb : in std_logic_vector(31 downto 0);--data memory output from write back stage
   --Control & Status registers
   csr_addr_dx      : out  std_logic_vector(11 downto 0);
   csr_wdata_src_dx : out  std_logic_vector(1 downto 0);
   csr_rdata_wb     : in   std_logic_vector(31 downto 0);--output data of selected control status register from write back stage
   --Decoded immediate value 
   imm_extended_dx : out std_logic_vector(31 downto 0);--extended immediate value
   imm_u_wb        : in  std_logic_vector(31 downto 0);--imm_u type from write back stage 
   --pipeline
   stall          : in std_logic;
   decode_ready   : out std_logic;--ready to receive the next instruction
   decode_valid_o_dx : out std_logic;--decode is done 
   execute_ready  : in std_logic--execute is ready for receiving the decoded instruction
);
end entity;

architecture rv_decode_arch of rv_decode is 
signal decode_valid_o : std_logic;
signal instr_data : std_logic_vector(31 downto 0);
signal reg_file_raddr1    : std_logic_vector(4 downto 0);
signal reg_file_raddr2    : std_logic_vector(4 downto 0);
signal reg_file_waddr     : std_logic_vector(4 downto 0);
signal reg_file_rdata1    : std_logic_vector(31 downto 0);
signal reg_file_rdata2    : std_logic_vector(31 downto 0);
signal reg_f_rdata1_bar: std_logic_vector(31 downto 0);--not(reg_file_rdata1)
signal reg_file_wdata     : std_logic_vector(31 downto 0);
signal reg_file_wdata_src : std_logic_vector(2 downto 0);
signal reg_file_we        : std_logic;
signal branch_t           : std_logic_vector(2 downto 0);
signal jump_t             : std_logic;
signal illegal_instr      : std_logic;
signal alu_operand_a_src  : std_logic_vector(2 downto 0);
signal alu_operand_b_src  : std_logic_vector(2 downto 0);
signal alu_op             : std_logic_vector(3 downto 0);
signal data_mem_size      : std_logic_vector(2 downto 0); -- word size to be retrieved from memory (byte , short or int)
signal data_mem_we        : std_logic;--data memory write enable
signal data_mem_en        : std_logic;--data memory enable
signal csr_addr           : std_logic_vector(11 downto 0);
signal csr_wdata_src      : std_logic_vector(1 downto 0); 
signal pc_next_src_int        : std_logic_vector(2 downto 0);--pc next source internal signal
signal imm_extended       : std_logic_vector(31 downto 0);--extended immediate value 
--Component declaration
component rv_reg_file
    port ( clk  : in std_logic;
           --Read port
           raddr1 : in std_logic_vector(4 downto 0);--read address for port 1 
           raddr2 : in std_logic_vector(4 downto 0);--read address for port 2
           rdata1 : out std_logic_vector(31 downto 0);--data output of port 1
           rdata2 : out std_logic_vector(31 downto 0);--data output of port 2
           --write port 
           waddr    : in std_logic_vector(4 downto 0); --address of the register we want to write into
           wdata    : in std_logic_vector(31 downto 0); --the data should be written into the reg specified by waddr
           we       : in std_logic--write enable 
          );
end component;

component rv_decoder  
    port (
          valid_o : out std_logic;
          --instruction
          instr_data    : in std_logic_vector(31 downto 0);
          illegal_instr : out std_logic;
          --Register file 
          reg_file_raddr1    : out std_logic_vector(4 downto 0);
          reg_file_raddr2    : out std_logic_vector(4 downto 0);
          reg_file_waddr     : out std_logic_vector(4 downto 0);  
          reg_file_wdata_src : out std_logic_vector(2 downto 0);
          reg_file_we        : out std_logic;
          --Branch/JUMP  
          branch_t : out std_logic_vector(2 downto 0);--branch type (BEQ , BNE , BLT , BGE , BLTU , BGEU)
          jump_t   : out std_logic;--jump type
                                   -- '0' JAL ; '1' JALR
          --ALU
          alu_operand_a_src     : out std_logic_vector(2 downto 0);--alu operand a source 
          alu_operand_b_src     : out std_logic_vector(2 downto 0);
          alu_op                : out std_logic_vector(3 downto 0);--alu operation
          --Data Memory
          data_mem_size : out std_logic_vector(2 downto 0); -- word size to be retrieved from memory (byte , short or int)
          data_mem_we        : out std_logic;--data memory write enable
          data_mem_en        : out std_logic;--data memory enable
          --Control & Status registers
          csr_addr : out  std_logic_vector(11 downto 0);
          csr_wdata_src : out std_logic_vector(1 downto 0);
          --fetch unit
          pc_next_src : out std_logic_vector(2 downto 0);
          --Decoded immediate 
          imm_extended : out std_logic_vector(31 downto 0)--extended immediate value    
    );
end component;
begin
decoder : rv_decoder port map (
    valid_o           => decode_valid_o,
    instr_data        => instr_data,
    illegal_instr     => illegal_instr,
    alu_operand_a_src => alu_operand_a_src,
    alu_operand_b_src => alu_operand_b_src,
    alu_op            => alu_op,
    reg_file_raddr1 => reg_file_raddr1,
    reg_file_raddr2 => reg_file_raddr2,
    reg_file_waddr  => reg_file_waddr,
    reg_file_wdata_src => reg_file_wdata_src,
    reg_file_we => reg_file_we,
    branch_t => branch_t,
    jump_t => jump_t,
    data_mem_size     => data_mem_size,
    data_mem_we       => data_mem_we,
    data_mem_en       => data_mem_en,
    csr_addr          => csr_addr,
    csr_wdata_src     => csr_wdata_src,
    pc_next_src       => pc_next_src_int,
    imm_extended      => imm_extended
);
--Deciding wether holding the program counter or not 
process(pc_next_src_int , valid_pc_update)
begin
    if ((pc_next_src_int = (PC_INCREMENT or PC_RST) or valid_pc_update = '1')  and stall = '0')    then --no need to hold the pc
        pc_hold <= '0';
    else --
        pc_hold <= '1';
    end if;
end process;
reg_file : rv_reg_file port map (
    clk => clk,
    raddr1  => reg_file_raddr1,
    raddr2 => reg_file_raddr2,
    rdata1 => reg_file_rdata1,
    rdata2 => reg_file_rdata2,
    waddr  => reg_file_waddr,
    wdata  => reg_file_wdata,
    we     => reg_f_we_wb
);
--regfile wdata source MUX
process(reg_file_wdata_src)
begin
    case(reg_file_wdata_src) is
        when W_SRC_ALU_RES => --write alu result data to destination register
            reg_file_wdata <= alu_res_wb;
        when W_SRC_CSR => --write selected csr data to destination register
            reg_file_wdata <= csr_rdata_wb;
        when W_SRC_PC_PLUS_4 => 
            reg_file_wdata <= pc_plus_4_wb;
        when W_SRC_DATA_MEM => --write output of  data memory data to destination register
            reg_file_wdata <= data_mem_rdata_wb;
        when W_SRC_IMM => --write output of immediate to destination register 
        reg_file_wdata <= imm_u_wb;
        when others => null;
     end case;
end process;
reg_f_rdata1_bar <= not reg_file_rdata2;
---------------------------------------------------------------------------
--                    DECODE-EXECUTE STAGE PIPELINE                      --
--------------------------------------------------------------------------- 
process(clk)
begin
    if rising_edge(clk) then
       if (rst_n = '0') then    
          instr_data <= (others => '0');
          instr_addr_dx        <= (others => '0');
          pc_plus_4_dx         <= (others => '0');
          reg_f_rdata1_bar_dx  <= (others => '0');
          branch_t_dx          <= (others => '0');
          jump_t_dx            <= '0';
          imm_extended_dx      <= (others => '0');
          reg_f_we_dx          <= '0';
          alu_operand_a_src_dx <= (others => '0');
          alu_operand_b_src_dx <= (others => '0');
          alu_op_dx            <= (others => '0');
          csr_wdata_src_dx     <= (others => '0');
          csr_addr_dx          <= (others => '0');
          pc_next_src       <= PC_RST;
          decode_valid_o_dx    <= '0';
       else
           if (fetch_valid_o = '1') then
                 instr_data <= instr_data_fd;
                 decode_valid_o <= '0';
           elsif (stall = '1') then 
                 decode_ready      <= '0';--decode stage is not ready for receiving new instruction
                 decode_valid_o_dx <= '0';--decode stage has no valid output
           elsif (execute_ready = '1' and illegal_instr = '0' and decode_valid_o = '1') then--execute stage is ready to receive decoded instruction
                 instr_addr_dx        <= instr_addr_fd;
                 pc_plus_4_dx         <= pc_plus_4_fd;
                 reg_f_rdata1_bar_dx  <= reg_f_rdata1_bar;
                 branch_t_dx          <= branch_t;
                 jump_t_dx            <= jump_t;
                 imm_extended_dx      <= imm_extended;
                 reg_f_we_dx          <= reg_file_we;
                 alu_operand_a_src_dx <= alu_operand_a_src;
                 alu_operand_b_src_dx <= alu_operand_b_src;
                 alu_op_dx            <= alu_op;
                 csr_wdata_src_dx     <= csr_wdata_src;
                 csr_addr_dx          <= csr_addr;
                 decode_valid_o_dx    <= '1';
           else 
                 decode_valid_o <= '0';
                 decode_ready <= '1';
           end if;
       end if;
    end if;
end process;
illegal_instr_o <= illegal_instr;
end architecture;