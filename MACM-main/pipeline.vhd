LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;


entity pipeline is 
  port(
    clk: in std_logic;
    init: in std_logic
    
  );
end entity;

architecture pipeline_arch of pipeline is
    signal ALUSrc_EX, MemWr_Mem, MemWr_RE, PCSrc_ER, RegWR, MemToReg_RE : std_logic;
    signal RegSrc, immSrc, ALUCtrl_EX : std_logic_vector(1 downto 0);

    signal instr_DE: std_logic_vector(31 downto 0);

    signal PCSrc_0, PCSrc_1, PCSrc_2, PCSrc_3, PCSrc_4: std_logic;
    signal RegWR_0, RegWR_1, RegWR_2, RegWR_3, RegWR_4 : std_logic;
    signal MemToReg_0, MemToReg_1, MemToReg_2, MemToReg_3 : std_logic;
    signal MemWr_0, MemWr_1, MemWr_2, MemWr_3 : std_logic;
    signal Branch_0, Branch_1, Branch_2 : std_logic;
    signal CCWr_0, CCWr_1 : std_logic;
    signal AluSrc_0, AluSrc_1 : std_logic; 
    signal immSrc_0 : std_logic_vector(1 downto 0);
    signal RegSrc_0 : std_logic_vector(1 downto 0);
    signal AluCtrl_0, AluCtrl_1 : std_logic_vector(1 downto 0);
    signal Cond_0, Cond_1, Cond_2, Cond_3 : std_logic_vector(3 downto 0);

    signal CCp_0, CCp_1 : std_logic_vector(3 downto 0);
    signal CC : std_logic_vector(3 downto 0);
    signal CondEx_0, CondEx_1, CondEx_2, CondEx_3 : std_logic;

    signal Gel_LI, Gel_DI, RAZ_DI, Clr_EX : std_logic;
    signal EA_EX, EB_EX : std_logic_vector(1 downto 0);
    signal a1, a2, rs1, rs2, op3_EX_out, op3_ME_out, op3_RE_out : std_logic_vector(3 downto 0);
    signal RegWr_Mem, RegWr_RE : std_logic;
    signal MemToReg_EX : std_logic;
    signal PCSrc_DE, PCSrc_EX, PCSrc_ME, PCSrc_RE : std_logic;
    signal Bpris_EX : std_logic;

begin
    Unite_ctrl: entity work.ctrl 
      port map(
        instr => instr_DE,
        PCSrc => PCSrc_0,
        RegWr => RegWR_0,
        MemToReg => MemToReg_0,
        MemWr => MemWr_0,
        Branch => Branch_0,
        CCWr => CCWr_0,
        AluSrc => ALUSrc_0,
        ImmSrc => immSrc_0,
        RegSrc => RegSrc_0,
        AluCtrl => AluCtrl_0,
        Cond => Cond_0
      );
      
    PCSrc_DE <= PCSrc_0;
    -- ------------ Bascules inter etages DE - EX --------------
    Bascule_PCSrc_1: entity work.Reg1
      port map(
        source => PCSrc_0,
        output => PCSrc_1,
        wr => '1',
        raz => Clr_EX,
        clk => clk
      );

    Bascule_RegWR_1: entity work.Reg1
      port map(
        source => RegWR_0,
        output => RegWR_1,
        wr => '1',
        raz => Clr_EX,
        clk => clk
      );

    Bascule_MemToReg_1: entity work.Reg1
      port map(
        source => MemToReg_0,
        output => MemToReg_1,
        wr => '1',
        raz => Clr_EX,
        clk => clk
      );

    Bascule_MemWr_1: entity work.Reg1
      port map(
        source => MemWr_0,
        output => MemWr_1,
        wr => '1',
        raz => Clr_EX,
        clk => clk
      );

    Bascule_Branch_1: entity work.Reg1
      port map(
        source => Branch_0,
        output => Branch_1,
        wr => '1',
        raz => Clr_EX,
        clk => clk
      );

    Bascule_CCWr_1: entity work.Reg1
      port map(
        source => CCWr_0,
        output => CCWr_1,
        wr => '1',
        raz => Clr_EX,
        clk => clk
      );

    Bascule_AluSrc_1: entity work.Reg1
      port map(
        source => AluSrc_0,
        output => AluSrc_1,
        wr => '1',
        raz => Clr_EX,
        clk => clk
      );

    Bascule_AluCtrl_1: entity work.Reg2
      port map(
        source => AluCtrl_0,
        output => AluCtrl_1,
        wr => '1',
        raz => Clr_EX,
        clk => clk
      );

    Bascule_Cond_1: entity work.Reg4
      port map(
        source => Cond_0,
        output => Cond_1,
        wr => '1',
        raz => Clr_EX,
        clk => clk
      );

    Bascule_CCp_1: entity work.Reg4
      port map(
        source => CCp_0,
        output => CCp_1,
        wr => '1',
        raz => Clr_EX,
        clk => clk
      );
      

    -- ------- connexions niveau etage EX --------
    Unite_cond: entity work.cond_entity
      port map(
        Cond => Cond_1,
        CC_EX => CCp_1,
        CC => CC,
        CCWr_EX => CCWr_1,
        CCp => CCp_0,
        CondEx => CondEx_0
      );

    RegWr_2 <= RegWr_1 and CondEx_0;
    PCSrc_2 <= PCSrc_1 and CondEx_0;
    MemWr_2 <= MemWr_1 and CondEx_0;
    Branch_2 <= Branch_1 and CondEx_0;

    MemToReg_EX <= MemToReg_1; 

    PCSrc_EX <= PCSrc_2;
    Bpris_EX <= Branch_2;

    -- ALUSrc_1 et ALUCtrl_1 vont dans l'ALU à ce niveau
    -- Branch_2 va dans Bpris_EX à ce niveau

    -- ------------ Bascules inter etages EX - ME --------------
    Bascule_RegWr_3: entity work.Reg1
      port map(
        source => RegWR_2,
        output => RegWR_3,
        wr => '1',
        raz => '1',
        clk => clk
      );

    Bascule_PCSrc_3: entity work.Reg1
      port map(
        source => PCSrc_2,
        output => PCSrc_3,
        wr => '1',
        raz => '1',
        clk => clk
      );

    Bascule_MemWr_3: entity work.Reg1
      port map(
        source => MemWr_2,
        output => MemWr_3,
        wr => '1',
        raz => '1',
        clk => clk
      );  

    Bascule_MemToReg_2: entity work.Reg1
      port map(
        source => MemToReg_1,
        output => MemToReg_2,
        wr => '1',
        raz => '1',
        clk => clk
      );
    
    -- ---------- connexions niveau etage ME -------
    -- MemWr_3 va dans MemWr_Mem à ce niveau  
    RegWr_Mem <= RegWr_3;
    PCSrc_ME <= PCSrc_3;

    -- ---------- Bascules inter etages ME - RE --------------
    Bascule_RegWr_4: entity work.Reg1
      port map(
        source => RegWR_3,
        output => RegWR_4,
        wr => '1',
        raz => '1',
        clk => clk
      );
    
    Bascule_MemToReg_3: entity work.Reg1
      port map(
        source => MemToReg_2,
        output => MemToReg_3,
        wr => '1',
        raz => '1',
        clk => clk
      );

    Bascule_PCSrc_4: entity work.Reg1
      port map(
        source => PCSrc_3,
        output => PCSrc_4,
        wr => '1',
        raz => '1',
        clk => clk
      );
    
    -- ---------- connexions niveau etage RE -------
    -- PCSrc_4 va dans PCSrc_ER à ce niveau
    -- RegWr_4 et MemToReg_4 vont dans RegWR et MemToReg_RE à ce niveau
    RegWr_RE <= RegWr_4;
    PCSrc_ER <= PCSrc_4;
    PCSrc_RE <= PCSrc_4;
    -- proc
    Proc:entity work.dataPath
      port map(
        clk => clk,
        init => init,
        ALUSrc_EX => AluSrc_1, --   UCtrl/UCond
        MemWr_Mem => MemWr_3, -- UCtrl/UCond
        PCSrc_ER => PCSrc_4, -- UCtrl/UCond
        Bpris_EX => Branch_2, -- UCtrl/UCond
        Gel_LI => Gel_LI, 
        Gel_DI => Gel_DI, 
        RAZ_DI => RAZ_DI, 
        RegWR => RegWR_4, -- UCtrl/UCond
        Clr_EX => Clr_EX, 
        MemToReg_RE => MemToReg_3, -- UCtrl/UCond
        RegSrc => RegSrc_0, -- UCtrl/UCond
        EA_EX => EA_EX, 
        EB_EX => EB_EX, 
        immSrc => immSrc_0, -- UCtrl/UCond
        ALUCtrl_EX => AluCtrl_1, -- UCtrl/UCond
        instr_DE => instr_DE, -- INPUT UCtrl
        a1 => a1, 
        a2 => a2, 
        rs1 => rs1, 
        rs2 => rs2,
        CC => CC,
        op3_EX_out => op3_EX_out,
        op3_ME_out => op3_ME_out,
        op3_RE_out => op3_RE_out
      );

    -- declaration unite controle des aleas
    aleas: entity work.aleas
      port map(
        a1 => a1, 
        a2 => a2, 
        rs1 => rs1, 
        rs2 => rs2,
        op3_EX_out => op3_EX_out,
        op3_ME_out => op3_ME_out,
        op3_RE_out => op3_RE_out,
        RegWr_Mem => RegWr_Mem,
        RegWr_RE => RegWr_RE,
        MemToReg_EX => MemToReg_EX,
        PCSrc_DE => PCSrc_DE,
        PCSrc_EX => PCSrc_EX,
        PCSrc_ME => PCSrc_ME,
        PCSrc_RE => PCSrc_RE,
        Bpris_EX => Bpris_EX,
        EA_EX => EA_EX, 
        EB_EX => EB_EX, 
        Gel_LI => Gel_LI, 
        Gel_DI => Gel_DI, 
        RAZ_DI => RAZ_DI, 
        Clr_EX => Clr_EX
      );
end architecture;

