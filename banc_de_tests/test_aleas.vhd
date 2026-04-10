-------------------------------------------------

-- Test de l'unite ALEAS

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.std_logic_arith.all;

entity test_aleas is
    -- pas d'entrees/sorties: composant de test
end test_aleas;

architecture test of test_aleas is

    constant TIMEOUT  : time := 150 ns;
    constant clkpulse : time := 5 ns;

    signal E_a1, E_a2, E_rs1, E_rs2, E_op3_EX_out, E_op3_ME_out, E_op3_RE_out : std_logic_vector(3 downto 0);
    signal E_RegWr_Mem, E_RegWr_RE, E_MemToReg_EX : std_logic;
    signal E_PCSrc_DE, E_PCSrc_EX, E_PCSrc_ME, E_PCSrc_RE : std_logic;
    signal E_Bpris_EX : std_logic;

    signal E_EA_EX, E_EB_EX : std_logic_vector(1 downto 0);
    signal E_Gel_LI, E_Gel_DI, E_RAZ_DI, E_Clr_EX : std_logic;

begin

P_TIMEOUT: process
begin
    wait for TIMEOUT;
    assert FALSE report "SIMULATION TIMEOUT!!!" severity FAILURE;
end process P_TIMEOUT;

aleas0 : entity work.aleas(aleas_arch)
    port map(
        a1 => E_a1,
        a2 => E_a2,
        rs1 => E_rs1,
        rs2 => E_rs2,
        op3_EX_out => E_op3_EX_out,
        op3_ME_out => E_op3_ME_out,
        op3_RE_out => E_op3_RE_out,
        RegWr_Mem => E_RegWr_Mem,
        RegWr_RE => E_RegWr_RE,
        MemToReg_EX => E_MemToReg_EX,
        PCSrc_DE => E_PCSrc_DE,
        PCSrc_EX => E_PCSrc_EX,
        PCSrc_ME => E_PCSrc_ME,
        PCSrc_RE => E_PCSrc_RE,
        Bpris_EX => E_Bpris_EX,
        EA_EX => E_EA_EX,
        EB_EX => E_EB_EX,
        Gel_LI => E_Gel_LI,
        Gel_DI => E_Gel_DI,
        RAZ_DI => E_RAZ_DI,
        Clr_EX => E_Clr_EX
    );

P_TEST: process
begin
    -- Etat nominal sans alea
    E_a1 <= conv_std_logic_vector(1, 4);
    E_a2 <= conv_std_logic_vector(2, 4);
    E_rs1 <= conv_std_logic_vector(3, 4);
    E_rs2 <= conv_std_logic_vector(4, 4);
    E_op3_EX_out <= conv_std_logic_vector(5, 4);
    E_op3_ME_out <= conv_std_logic_vector(6, 4);
    E_op3_RE_out <= conv_std_logic_vector(7, 4);

    E_RegWr_Mem <= '0';
    E_RegWr_RE <= '0';
    E_MemToReg_EX <= '0';
    E_PCSrc_DE <= '0';
    E_PCSrc_EX <= '0';
    E_PCSrc_ME <= '0';
    E_PCSrc_RE <= '0';
    E_Bpris_EX <= '0';

    wait for clkpulse;

    assert E_EA_EX = "00" report "EA_EX devrait valoir 00 en etat nominal" severity FAILURE;
    assert E_EB_EX = "00" report "EB_EX devrait valoir 00 en etat nominal" severity FAILURE;
    assert E_Gel_DI = '1' report "Gel_DI devrait etre inactif en etat nominal" severity FAILURE;
    assert E_Clr_EX = '1' report "Clr_EX devrait etre inactif en etat nominal" severity FAILURE;
    assert E_Gel_LI = '1' report "Gel_LI devrait etre inactif en etat nominal" severity FAILURE;
    assert E_RAZ_DI = '1' report "RAZ_DI devrait etre inactif en etat nominal" severity FAILURE;

    -- TEST 1: forwarding prioritaire depuis ME
    E_RegWr_Mem <= '1';
    E_RegWr_RE <= '1';
    E_a1 <= conv_std_logic_vector(6, 4); -- match op3_ME_out
    E_a2 <= conv_std_logic_vector(6, 4); -- match op3_ME_out

    wait for clkpulse;

    assert E_EA_EX = "10" report "EA_EX devrait selectionner ME (10)" severity FAILURE;
    assert E_EB_EX = "10" report "EB_EX devrait selectionner ME (10)" severity FAILURE;

    -- TEST 2: forwarding depuis RE quand pas de match ME
    E_a1 <= conv_std_logic_vector(7, 4); -- match op3_RE_out
    E_a2 <= conv_std_logic_vector(7, 4); -- match op3_RE_out

    wait for clkpulse;

    assert E_EA_EX = "01" report "EA_EX devrait selectionner RE (01)" severity FAILURE;
    assert E_EB_EX = "01" report "EB_EX devrait selectionner RE (01)" severity FAILURE;

    -- TEST 3: LDR => stall 
    E_RegWr_Mem <= '0';
    E_RegWr_RE <= '0';
    E_rs1 <= conv_std_logic_vector(5, 4); -- match op3_EX_out
    E_rs2 <= conv_std_logic_vector(9, 4);
    E_MemToReg_EX <= '1';

    wait for clkpulse;

    assert E_Gel_DI = '0' report "Gel_DI doit etre actif pendant un LDR stall" severity FAILURE;
    assert E_Clr_EX = '0' report "Clr_EX doit etre actif pendant un LDR stall" severity FAILURE;
    assert E_Gel_LI = '0' report "Gel_LI doit etre actif pendant un LDR stall" severity FAILURE;
    assert E_RAZ_DI = '1' report "RAZ_DI ne doit pas s'activer pour un simple LDR stall" severity FAILURE;

    -- TEST 4: branchement pris => flush
    E_MemToReg_EX <= '0';
    E_Bpris_EX <= '1';

    wait for clkpulse;

    assert E_Clr_EX = '0' report "Clr_EX doit etre actif quand Bpris_EX=1" severity FAILURE;
    assert E_RAZ_DI = '0' report "RAZ_DI doit etre actif quand Bpris_EX=1" severity FAILURE;

    -- TEST 5: redirection PC en amont
    E_Bpris_EX <= '0';
    E_PCSrc_DE <= '1';

    wait for clkpulse;

    assert E_Gel_LI = '0' report "Gel_LI doit etre actif quand PCSrc_DE=1" severity FAILURE;
    assert E_RAZ_DI = '0' report "RAZ_DI doit etre actif quand PCSrc_DE=1" severity FAILURE;

    -- retour nominal
    E_PCSrc_DE <= '0';
    E_rs1 <= conv_std_logic_vector(3, 4);

    wait for clkpulse;

    assert E_Gel_DI = '1' report "Gel_DI devrait revenir a 1" severity FAILURE;
    assert E_Clr_EX = '1' report "Clr_EX devrait revenir a 1" severity FAILURE;
    assert E_Gel_LI = '1' report "Gel_LI devrait revenir a 1" severity FAILURE;
    assert E_RAZ_DI = '1' report "RAZ_DI devrait revenir a 1" severity FAILURE;

    -- LATEST COMMAND (NE PAS ENLEVER !!!)
    wait for clkpulse;
    assert FALSE report "FIN DE SIMULATION" severity FAILURE;

end process P_TEST;

end test;
