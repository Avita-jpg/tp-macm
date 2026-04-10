LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity aleas is 
    port (
        a1, a2, rs1, rs2, op3_EX_out, op3_ME_out, op3_RE_out: in std_logic_vector(3 downto 0);
        RegWr_Mem, RegWr_RE: in std_logic;
        MemToReg_EX: in std_logic;
        PCSrc_DE, PCSrc_EX, PCSrc_ME, PCSrc_RE: in std_logic;
        Bpris_EX: in std_logic;

        EA_EX, EB_EX: out std_logic_vector(1 downto 0);
        Gel_LI, Gel_DI, RAZ_DI, Clr_EX: out std_logic
    );
end entity;

architecture aleas_arch of aleas is
    signal LDRStall : std_logic;
begin
    EA_EX <= "10" when a1 = Op3_ME_out and RegWr_Mem = '1' else
             "01" when a1 /= Op3_ME_out and a1 = Op3_RE_out and RegWr_RE = '1' else
             "00";

    EB_EX <= "10" when a2 = Op3_ME_out and RegWr_Mem = '1' else
             "01" when a2 /= Op3_ME_out and a2 = Op3_RE_out and RegWr_RE = '1' else
             "00";

    LDRStall <= '1' when (rs1 = Op3_EX_out or rs2 = Op3_EX_out) and MemToReg_EX = '1' else
                '0';

    
    Gel_DI <= '0' when LDRStall = '1' else '1';
    
    Clr_EX <= not (LDRStall or Bpris_EX);
    Gel_LI <= not (LDRStall or PCSrc_DE or PCSrc_EX or PCSrc_ME);
    RAZ_DI <= not (PCSrc_DE or PCSrc_EX or PCSrc_ME or PCSrc_RE or Bpris_EX);
    
end architecture;