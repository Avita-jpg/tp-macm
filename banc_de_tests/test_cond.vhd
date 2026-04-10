-------------------------------------------------

-- Test de l'unite COND

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.std_logic_arith.all;

entity test_cond is
    -- pas d'entrees/sorties: composant de test
end test_cond;

architecture test of test_cond is

    constant TIMEOUT  : time := 150 ns;
    constant clkpulse : time := 5 ns;

    signal E_Cond, E_CC_EX, E_CC, E_CCp : std_logic_vector(3 downto 0);
    signal E_CCWr_EX, E_CondEx : std_logic;

begin

P_TIMEOUT: process
begin
    wait for TIMEOUT;
    assert FALSE report "SIMULATION TIMEOUT!!!" severity FAILURE;
end process P_TIMEOUT;

cond0 : entity work.cond_entity(cond_arch)
    port map(
        Cond => E_Cond,
        CC_EX => E_CC_EX,
        CC => E_CC,
        CCWr_EX => E_CCWr_EX,
        CCp => E_CCp,
        CondEx => E_CondEx
    );

P_TEST: process
begin
    -- N Z C V
    -- Convention de l'unite:
    --   * CondEx est calcule sur CC_EX (flags courants)
    --   * si CCWr_EX=1 et condition vraie, CCp prend CC (nouveaux flags ALU)

    -- TEST 1: EQ (0000) avec Z=1 => CondEx=1
    E_Cond <= "0000";
    E_CC_EX <= "0100"; -- Z=1
    E_CC <= "1010";
    E_CCWr_EX <= '1';
    wait for clkpulse;

    assert E_CondEx = '1' report "CondEx incorrect pour EQ avec Z=1" severity FAILURE;
    assert E_CCp = E_CC report "CCp devrait prendre CC quand condition vraie et CCWr_EX=1" severity FAILURE;

    -- TEST 2: NE (0001) avec Z=1 => CondEx=0
    E_Cond <= "0001";
    E_CC_EX <= "0100"; -- Z=1
    E_CC <= "0011";
    E_CCWr_EX <= '1';
    wait for clkpulse;

    assert E_CondEx = '0' report "CondEx incorrect pour NE avec Z=1" severity FAILURE;
    assert E_CCp = E_CC_EX report "CCp devrait rester CC_EX quand condition fausse" severity FAILURE;

    -- TEST 3: AL (1110) toujours vrai
    E_Cond <= "1110";
    E_CC_EX <= "0000";
    E_CC <= "1111";
    E_CCWr_EX <= '1';
    wait for clkpulse;

    assert E_CondEx = '1' report "CondEx incorrect pour AL" severity FAILURE;
    assert E_CCp = E_CC report "CCp devrait prendre CC pour AL si CCWr_EX=1" severity FAILURE;

    -- TEST 4: GE (1010): N=V => vrai
    E_Cond <= "1010";
    E_CC_EX <= "1001"; -- N=1, V=1
    E_CC <= "0110";
    E_CCWr_EX <= '1';
    wait for clkpulse;

    assert E_CondEx = '1' report "CondEx incorrect pour GE avec N=V" severity FAILURE;

    -- TEST 5: LT (1011): N/=V => vrai
    E_Cond <= "1011";
    E_CC_EX <= "1000"; -- N=1, V=0
    E_CC <= "0001";
    E_CCWr_EX <= '0';
    wait for clkpulse;

    assert E_CondEx = '1' report "CondEx incorrect pour LT avec N/=V" severity FAILURE;
    assert E_CCp = E_CC_EX report "CCp devrait rester CC_EX si CCWr_EX=0" severity FAILURE;

    -- TEST 6: GT (1100): Z=0 et N=V => vrai
    E_Cond <= "1100";
    E_CC_EX <= "0000"; -- Z=0, N=0, V=0
    E_CC <= "0010";
    E_CCWr_EX <= '1';
    wait for clkpulse;

    assert E_CondEx = '1' report "CondEx incorrect pour GT" severity FAILURE;

    -- LATEST COMMAND (NE PAS ENLEVER !!!)
    wait for clkpulse;
    assert FALSE report "FIN DE SIMULATION" severity FAILURE;

end process P_TEST;

end test;
