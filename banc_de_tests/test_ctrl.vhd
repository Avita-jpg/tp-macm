-------------------------------------------------

-- Test de l'unite CTRL

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.std_logic_arith.all;

entity test_ctrl is
    -- pas d'entrees/sorties: composant de test
end test_ctrl;

architecture test of test_ctrl is

    constant TIMEOUT  : time := 150 ns;
    constant clkpulse : time := 5 ns;

    signal E_instr : std_logic_vector(31 downto 0);
    signal E_PCSrc, E_RegWr, E_MemToReg, E_MemWr, E_Branch, E_CCWr, E_AluSrc : std_logic;
    signal E_ImmSrc, E_RegSrc, E_AluCtrl : std_logic_vector(1 downto 0);
    signal E_Cond : std_logic_vector(3 downto 0);

begin

P_TIMEOUT: process
begin
    wait for TIMEOUT;
    assert FALSE report "SIMULATION TIMEOUT!!!" severity FAILURE;
end process P_TIMEOUT;

ctrl0 : entity work.ctrl(ctrl_arch)
    port map(
        instr => E_instr,
        PCSrc => E_PCSrc,
        RegWr => E_RegWr,
        MemToReg => E_MemToReg,
        MemWr => E_MemWr,
        Branch => E_Branch,
        CCWr => E_CCWr,
        AluSrc => E_AluSrc,
        ImmSrc => E_ImmSrc,
        RegSrc => E_RegSrc,
        AluCtrl => E_AluCtrl,
        Cond => E_Cond
    );

P_TEST: process
begin
    -- TEST 1: instruction data processing registre-registre (ADD)
    E_instr <= (others => '0');
    E_instr(31 downto 28) <= "1110"; -- Cond = AL
    E_instr(27 downto 26) <= "00";   -- data processing
    E_instr(25) <= '0';               -- reg/reg
    E_instr(24 downto 21) <= "0100"; -- ADD
    E_instr(20) <= '0';
    E_instr(15 downto 12) <= "0001";
    wait for clkpulse;

    assert E_Cond = "1110" report "Cond incorrect pour ADD" severity FAILURE;
    assert E_Branch = '0' report "Branch incorrect pour ADD" severity FAILURE;
    assert E_MemToReg = '0' report "MemToReg incorrect pour ADD" severity FAILURE;
    assert E_MemWr = '0' report "MemWr incorrect pour ADD" severity FAILURE;
    assert E_AluSrc = '0' report "AluSrc incorrect pour ADD" severity FAILURE;
    assert E_RegWr = '1' report "RegWr incorrect pour ADD" severity FAILURE;
    assert E_CCWr = '0' report "CCWr incorrect pour ADD" severity FAILURE;
    assert E_ImmSrc = "00" report "ImmSrc incorrect pour ADD" severity FAILURE;
    assert E_RegSrc = "00" report "RegSrc incorrect pour ADD" severity FAILURE;
    assert E_AluCtrl = "00" report "AluCtrl incorrect pour ADD" severity FAILURE;
    assert E_PCSrc = '0' report "PCSrc incorrect pour ADD" severity FAILURE;

    -- TEST 2: instruction LDR
    E_instr <= (others => '0');
    E_instr(31 downto 28) <= "1110";
    E_instr(27 downto 26) <= "01"; -- mem
    E_instr(20) <= '1';             -- LDR
    E_instr(15 downto 12) <= "0010";
    wait for clkpulse;

    assert E_Branch = '0' report "Branch incorrect pour LDR" severity FAILURE;
    assert E_MemToReg = '1' report "MemToReg incorrect pour LDR" severity FAILURE;
    assert E_MemWr = '0' report "MemWr incorrect pour LDR" severity FAILURE;
    assert E_AluSrc = '1' report "AluSrc incorrect pour LDR" severity FAILURE;
    assert E_RegWr = '1' report "RegWr incorrect pour LDR" severity FAILURE;
    assert E_CCWr = '0' report "CCWr incorrect pour LDR" severity FAILURE;
    assert E_ImmSrc = "01" report "ImmSrc incorrect pour LDR" severity FAILURE;
    assert E_RegSrc = "10" report "RegSrc incorrect pour LDR" severity FAILURE;
    assert E_AluCtrl = "00" report "AluCtrl incorrect pour LDR" severity FAILURE;
    assert E_PCSrc = '0' report "PCSrc incorrect pour LDR" severity FAILURE;

    -- TEST 3: instruction STR
    E_instr <= (others => '0');
    E_instr(31 downto 28) <= "1110";
    E_instr(27 downto 26) <= "01"; -- mem
    E_instr(20) <= '0';             -- STR
    wait for clkpulse;

    assert E_MemToReg = '0' report "MemToReg incorrect pour STR" severity FAILURE;
    assert E_MemWr = '1' report "MemWr incorrect pour STR" severity FAILURE;
    assert E_RegWr = '0' report "RegWr incorrect pour STR" severity FAILURE;
    assert E_ImmSrc = "01" report "ImmSrc incorrect pour STR" severity FAILURE;

    -- TEST 4: instruction branchement B
    E_instr <= (others => '0');
    E_instr(31 downto 28) <= "1110";
    E_instr(27 downto 26) <= "10"; -- branch
    wait for clkpulse;

    assert E_Branch = '1' report "Branch incorrect pour B" severity FAILURE;
    assert E_AluSrc = '1' report "AluSrc incorrect pour B" severity FAILURE;
    assert E_ImmSrc = "10" report "ImmSrc incorrect pour B" severity FAILURE;
    assert E_RegSrc = "11" report "RegSrc incorrect pour B" severity FAILURE;
    assert E_RegWr = '0' report "RegWr incorrect pour B" severity FAILURE;

    -- TEST 5: PCSrc actif quand destination = r15
    E_instr <= (others => '0');
    E_instr(27 downto 26) <= "00";
    E_instr(25) <= '0';
    E_instr(24 downto 21) <= "0100";
    E_instr(20) <= '0';
    E_instr(15 downto 12) <= "1111"; -- Rd = PC
    wait for clkpulse;

    assert E_PCSrc = '1' report "PCSrc devrait etre a 1 quand Rd = r15" severity FAILURE;

    -- LATEST COMMAND (NE PAS ENLEVER !!!)
    wait for clkpulse;
    assert FALSE report "FIN DE SIMULATION" severity FAILURE;

end process P_TEST;

end test;
