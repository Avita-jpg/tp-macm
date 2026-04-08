LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity pipeline is 
  port(
    clk: in std_logic
  );
end entity;

architecture pipeline_arch of pipeline is
    signal clk, init, ALUSrc_EX, MemWr_Mem, MemWr_RE, PCSrc_ER, Bpris_EX, Gel_LI, Gel_DI, RAZ_DI, RegWR, Clr_EX, MemToReg_RE : std_logic;
    signal RegSrc, EA_EX, EB_EX, immSrc, ALUCtrl_EX : std_logic_vector(1 downto 0);

    signal instr_DE: std_logic_vector(31 downto 0);
    signal a1, a2, rs1, rs2, CC, op3_EX_out, op3_ME_out, op3_RE_out: std_logic_vector(3 downto 0);
begin
    entity work.proc
      port map(
        clk => clk,
        init => init,
        ALUSrc_EX => ALUSrc_EX,
        MemWr_Mem => MemWr_Mem,
        MemWr_RE => MemWr_RE,
        PCSrc_ER => PCSrc_ER,
        Bpris_EX => Bpris_EX,
        Gel_LI => Gel_LI,
        Gel_DI => Gel_DI,
        RAZ_DI => RAZ_DI,
        RegWR => RegWR,
        Clr_EX => Clr_EX,
        MemToReg_RE => MemToReg_RE,
        RegSrc => RegSrc,
        EA_EX => EA_EX,
        EB_EX => EB_EX,
        immSrc => immSrc,
        ALUCtrl_EX => ALUCtrl_EX,
        instr_DE => instr_DE,
        a1 => a1,
        a2 => a2,
        rs1 => rs1,
        rs2 => rs2,
        CC => CC,
        op3_EX_out => op3_EX_out,
        op3_ME_out => op3_ME_out,
        op3_RE_out => op3_RE_out
    );

    entity work.ctrl -- ???
      port map(
        instr => instr_DE,
        Branch => open,
        MemToReg => open,
        MemWr => open,
        RegWr => RegWR,
        CCWr => open,
        PCSrc => PCSrc_ER,
        ImmSrc => immSrc,
        RegSrc => RegSrc
      );

