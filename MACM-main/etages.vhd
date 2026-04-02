-------------------------------------------------

-- Etage FE

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity etageFE is
  port(
    npc, npc_fw_br : in std_logic_vector(31 downto 0);
    PCSrc_ER, Bpris_EX, GEL_LI, clk : in std_logic;
    pc_plus_4, i_FE : out std_logic_vector(31 downto 0)
);
end entity;


architecture etageFE_arch of etageFE is
  signal pc_inter, pc_reg_in, pc_reg_out, sig_pc_plus_4, sig_4: std_logic_vector(31 downto 0);
begin

  sig_4 <= (2=>'1', others => '0');
  
  -- Architecture à compléter
  REGS_I: entity work.inst_mem
    port map(addr => pc_reg_out, instr => i_FE);
  
  PC: entity work.Reg32
    port map(source => pc_reg_in, output => pc_reg_out, wr => GEL_LI, raz => '1', clk => clk);

  ADD4: entity work.addComplex
    port map(A => pc_reg_out, B => sig_4, cin => '0', s => sig_pc_plus_4, c30 => open, c31 => open);
  
  
  pc_inter <= npc when (PCSrc_ER = '1') else sig_pc_plus_4;
  pc_reg_in <= npc_fw_br when (Bpris_EX = '1') else pc_inter;
    
  pc_plus_4 <= sig_pc_plus_4;
  
end architecture;

-- -------------------------------------------------

-- -- Etage DE

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity etageDE is
  port (
    i_DE, WD_ER, pc_plus_4 : in std_logic_vector(31 downto 0);
    Op3_ER : in std_logic_vector(3 downto 0); 
    RegSrc, immSrc : in std_logic_vector(1 downto 0);
    RegWr, clk, Init : in std_logic;
  
    Reg1, Reg2, Op3_DE : out std_logic_vector(3 downto 0);
    extImm, Op1, Op2 : out std_logic_vector(31 downto 0)
    );

end entity;

architecture etageDE_arch  of etageDE is
  signal sigOp1, sigOp2, sig_15 : std_logic_vector(3 downto 0);
begin

  REGS_BANK: entity work.RegisterBank
    port map (
      s_reg_0 => sigOp1,
		  data_o_0 => Op1,
		  s_reg_1 => sigOp2,
		  data_o_1 => Op2,
		  dest_reg => Op3_ER,
		  data_i => WD_ER,
      pc_in => pc_plus_4,
      init => Init, 
		  wr_reg => RegWr,
      clk => clk
    );

    sig_15 <= (others => '1');

    sigOp1 <= i_DE(19 downto 16) when RegSrc(0) = '0' else sig_15;
    sigOp2 <= i_DE (3 downto 0) when RegSrc(1) = '0' else i_DE(15 downto 12);
    Op3_DE <= i_DE(15 downto 12);

    Reg1 <= sigOp1;
    Reg2 <= sigOp2;

  EXT: entity work.extension
    port map(
      immIn => i_DE(23 downto 0),
      immSrc => immSrc,
      ExtOut => extImm
    );

end architecture;

-- -------------------------------------------------

-- -- Etage EX

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity etageEX is
  port (
    Op1_EX, Op2_EX, ExtImm_EX, Res_fwd_ME, Res_fwd_ER : in std_logic_vector(31 downto 0);
    Op3_EX : in std_logic_vector(3 downto 0);
    EA_EX, EB_EX, ALUCtrl_EX : in std_logic_vector(1 downto 0);
    ALUSrc_EX : in std_logic;

    Res_EX, WD_EX, npc_fw_br : out std_logic_vector(31 downto 0);
    CC, Op3_EX_out : out std_logic_vector(3 downto 0)
  );

end entity;

architecture etageEX_arch of etageEX is
  signal ALUOp1, Oper2, ALUOp2, Res : std_logic_vector(31 downto 0);
begin 
  ALU: entity work.ALU 
    port map (
      A => ALUOp1,
      B => ALUOp2,
      sel => ALUCtrl_EX,
      Res => Res,
      CC => CC
    );

  Res_EX <= Res;
  npc_fw_br <= Res;
  Op3_EX_out <= Op3_EX;
  WD_EX <= OP2_EX;

  Oper2 <= Op2_EX when EB_EX = "00" else 
           Res_fwd_ER when EB_EX = "01" else
           Res_fwd_ME when EB_EX = "10" else
           (others => 'X');
  
  ALUOp1 <= Op1_EX when EA_EX = "00" else
            Res_fwd_ER when EA_EX = "01" else
            Res_fwd_ME when EA_EX = "10" else
            (others => 'X');

  ALUOp2 <= Oper2 when ALUSrc_EX = '0' else
            ExtImm_Ex;
            
end architecture;

-- -------------------------------------------------

-- -- Etage ME

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity etageME is
  port (
    Res_ME, WD_ME : in std_logic_vector(31 downto 0);
    Op3_ME : in std_logic_vector(3 downto 0);
    MemWR_Mem, clk : in std_logic;

    Res_Mem_ME, Res_ALU_ME, Res_fwd_ME : out std_logic_vector(31 downto 0);
    Op3_ME_out : out std_logic_vector(3 downto 0)
  );
end entity;

architecture etageME_arch of etageME is

begin
  -- port (
  --   addr, WD : in std_logic_vector(31 downto 0);
  --   clk, WR : in std_logic;
  --   data : out std_logic_vector(31 downto 0)
  --   );
  MEM: entity work.data_mem
    port map(
      addr => Res_ME,
      WD => WD_ME,
      clk => clk,
      WR => MemWR_Mem,
      data => Res_Mem_ME
    );

  Res_ALU_ME <= Res_ME;
  Res_fwd_ME <= Res_ME;
  Op3_ME_out <= Op3_ME;

end architecture;
-- -------------------------------------------------

-- Etage ER

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity etageER is
  port (
    Res_Mem_RE, Res_ALU_RE : in std_logic_vector(31 downto 0);
    Op3_RE : in std_logic_vector(3 downto 0);
    MemToReg_RE : in std_logic;

    Res_RE : out std_logic_vector(31 downto 0);
    Op3_RE_out : out std_logic_vector(3 downto 0)
  );
end entity;

architecture etageER_arch of etageER is
begin
  Res_RE <= Res_Mem_RE when MemToReg_RE = '1' else Res_ALU_RE;
  Op3_RE_out <= Op3_RE;
end architecture;
