-------------------------------------------------------

-- Chemin de données

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;


entity dataPath is
  port(
    clk,  init, ALUSrc_EX, MemWr_Mem, MemWr_RE, PCSrc_ER, Bpris_EX, Gel_LI, Gel_DI, RAZ_DI, RegWR, Clr_EX, MemToReg_RE : in std_logic;
    RegSrc, EA_EX, EB_EX, immSrc, ALUCtrl_EX : in std_logic_vector(1 downto 0);
    instr_DE: out std_logic_vector(31 downto 0);
    a1, a2, rs1, rs2, CC, op3_EX_out, op3_ME_out, op3_RE_out: out std_logic_vector(3 downto 0)
);      
end entity;

architecture dataPath_arch of dataPath is
  signal Res_RE, npc_fwd_br, pc_plus_4, i_FE, i_DE, Op1_DE, Op2_DE, Op1_EX, Op2_EX, extImm_DE, extImm_EX, Res_EX, Res_ME, WD_EX, WD_ME, Res_Mem_ME, Res_Mem_RE, Res_ALU_ME, Res_ALU_RE, Res_fwd_ME : std_logic_vector(31 downto 0);
  signal Op3_DE, Op3_EX, a1_DE, a1_EX, a2_DE, a2_EX, Op3_EX_out_t, Op3_ME, Op3_ME_out_t, Op3_RE, Op3_RE_out_t : std_logic_vector(3 downto 0);
begin

  -- FE
  Bascule_i_FE: entity work.Reg32
    port map (
      source => i_FE,
      output => i_DE, 
      wr => Gel_DI, 
      raz => RAZ_DI, 
      clk => clk
    );
  
  FE: entity work.etageFE
    port map(
      npc => Res_RE, 
      -- attention faute de frappe etage FE "fw" au lieu de "fwd"
      npc_fw_br => npc_fwd_br, 
      PCSrc_ER => PCSrc_ER,
      Bpris_EX => Bpris_EX,
      GEL_LI => Gel_LI, 
      clk => clk, 
      pc_plus_4 => pc_plus_4,
      i_FE => i_FE
    );

  -- DE

  DE: entity work.etageDE 
    port map (
      i_DE => i_DE,
      WD_ER => Res_RE,
      pc_plus_4 => pc_plus_4,
      Op3_ER => Res_fwd_ME,
      RegSrc => RegSrc,
      immSrc => immSrc,
      RegWr => RegWR,
      clk => clk,
      Init => init, 
      Reg1 => rs1,
      Reg2 => rs2, 
      Op3_DE => Op3_DE,
      extImm => extImm_DE,
      Op1 => Op1_DE,
      Op2 => Op2_DE
    );

  Bascule_Op1_DE: entity work.Reg32
    port map (
        source => Op1_DE,
        output => Op1_EX, 
        wr => '0', -- pas de gel ? 
        raz => Clr_EX, 
        clk => clk
      );
  
  Bascule_Op2_DE: entity work.Reg32
    port map (
        source => Op2_DE,
        output => Op2_EX, 
        wr => '0', 
        raz => Clr_EX, 
        clk => clk
      );

  Bascule_extImm_DE: entity work.Reg32
    port map (
        source => extImm_DE,
        output => extImm_EX, 
        wr => '0', 
        raz => Clr_EX, 
        clk => clk
      );

  Bascule_Op3_DE_DE: entity work.Reg4
    port map (
          source => Op3_DE,
          output => Op3_EX, 
          wr => '0', 
          raz => Clr_EX, 
          clk => clk
        );
  
  Bascule_rs1_DE: entity work.Reg4
    port map (
          source => rs1,
          output => a1, 
          wr => '0', 
          raz => Clr_EX, 
          clk => clk
        );
  
  Bascule_rs2_DE: entity work.Reg4
    port map (
          source => rs2,
          output => a2, 
          wr => '0', 
          raz => Clr_EX, 
          clk => clk
        );
  -- EX

  EX: entity work.etageEX
    port map (
      Op1_EX => Op1_EX,
      Op2_EX => Op2_EX,
      ExtImm_EX => extImm_EX,
      Res_fwd_ME => Res_fwd_ME,
      Res_fwd_ER => Res_RE,
      Op3_EX => Op3_EX,
      EA_EX => EA_EX,
      EB_EX => EB_EX,
      ALUCtrl_EX => ALUCtrl_EX,
      ALUSrc_EX => ALUSrc_EX,
      Res_EX => Res_EX,
      WD_EX => WD_EX,
      npc_fw_br => npc_fwd_br,
      CC => CC,
      Op3_EX_out => Op3_EX_out_t
    );
  
  Bascule_Res_EX: entity work.Reg32
    port map (
      source => Res_EX,
      output => Res_ME,
      wr => '0',
      raz => '0',
      clk => clk
    );

  Bascule_WD_EX: entity work.Reg32
    port map (
      source => WD_EX,
      output => WD_ME,
      wr => '0',
      raz => '0',
      clk => clk
    );

  Bascule_Op3_EX_out_EX: entity work.Reg4
    port map (
      source => Op3_EX_out_t,
      output => Op3_ME,
      wr => '0',
      raz => '0',
      clk => clk
    );
  
  -- ME
  ME: entity work.etageME
    port map (
      Res_EX => Res_EX,
      WD_EX => WD_EX,
      Op3_EX => Op3_ME,
      MemWr_Mem => MemWr_Mem,
      clk => clk,
      Res_Mem_ME => Res_Mem_ME,
      Res_ALU_ME => Res_ALU_ME,
      Op3_ME_out => Op3_ME_out_t
    );
 
  -- RE
 
  
end architecture;
