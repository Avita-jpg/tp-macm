-------------------------------------------------

-- Test de l'étage FE (Fetch)

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.std_logic_arith.all;


entity test_fetch is
    -- pas d'entrées sorties car composant de test
end test_fetch;

-- Definition de l'architecture
architecture test of test_fetch is

-- definition des constantes de test
    constant TIMEOUT 	: time := 150 ns; -- timeout de la simulation
    constant clkpulse   : time := 5 ns;
-- definition de ressources externes
    signal E_npc, E_npc_fw_br, E_pc_plus_4, E_i_FE : std_logic_vector(31 downto 0);

    signal E_PCSrc_ER, E_Bpris_EX, E_GEL_LI, E_clk : std_logic;

begin

--------------------------
-- definition du timeout de la simulation
P_TIMEOUT: process
begin
	wait for TIMEOUT;
	assert FALSE report "SIMULATION TIMEOUT!!!" severity FAILURE;
end process P_TIMEOUT;


--------------------------------------------------
-- instantiation et mapping du composant à tester
etageFE0 : entity work.etageFE(etageFE_arch)
    port map(
        npc => E_npc,
        npc_fw_br => E_npc_fw_br,
        PCSrc_ER => E_PCSrc_ER, 
        Bpris_EX => E_Bpris_EX,
        GEL_LI => E_GEL_LI,
        clk => E_clk,
        pc_plus_4 => E_pc_plus_4,
        i_FE => E_i_FE
);

-----------------------------
-- debut sequence de test
P_TEST_0: process
begin 
    E_CLK <= '0';

    -- TEST 1: cas nouvelle adresse pc 
    E_npc <= conv_std_logic_vector(5*4, 32);
    E_GEL_LI <= '1';
    E_PCSrc_ER <= '1';
    E_Bpris_EX <= '0';
    
    E_npc_fw_br <= conv_std_logic_vector(0, 32); -- pas utilisé pour ce premier test

    wait for clkpulse; 
    E_CLK <= '1';
    wait for clkpulse;
    E_CLK <= '0';

    wait for clkpulse/2;
    -- ATTENDU : il lit la donnée à l'adresse 5*4 = 20
    assert E_pc_plus_4 = conv_std_logic_vector(24, 32)
        report "pc_plus_4 bad value after TEST 1"
        severity FAILURE;

    -- TEST 2: cas adresse pc+4
    E_PCSrc_ER <= '0';

    wait for clkpulse/2;
    E_CLK <= '1';
    wait for clkpulse;
    E_CLK <= '0';

    wait for clkpulse/2;
    -- ATTENDU:  il lit la donnée suivante à l'adresse pc+4, soit 6*4 = 24
    assert E_pc_plus_4 = conv_std_logic_vector(28, 32)
        report "pc_plus_4 bad value after TEST 2"
        severity FAILURE;
    
    -- TEST 3: cas prise de branchement à l'addresse 10*4 = 40
    E_Bpris_EX <= '1';
    E_npc_fw_br <= conv_std_logic_vector(10*4, 32);

    wait for clkpulse/2;
    E_CLK <= '1';
    wait for clkpulse;
    E_CLK <= '0';

    wait for clkpulse/2;
    -- ATTENDU:  il lit la donnée à l'adresse de branchement, soit 10*4 = 40
    assert E_pc_plus_4 = conv_std_logic_vector(44, 32)
        report "pc_plus_4 bad value after TEST 3"
        severity FAILURE;

    -- TEST 4: cas gel du pipeline -- GEL_LI = '0' => pas de mise à jour du PC
    E_GEL_LI <= '0';

    wait for clkpulse/2;
    E_CLK <= '1';
    wait for clkpulse;
    E_CLK <= '0';

    wait for clkpulse/2;
    -- ATTENDU: le pc garde la même adresse que le cycle précédent, soit 10*4 = 40
    assert E_pc_plus_4 = conv_std_logic_vector(44, 32)
        report "pc_plus_4 should stay unchanged when GEL_LI=0"
        severity FAILURE;
    wait for clkpulse/2;
    
    -- LATEST COMMAND (NE PAS ENLEVER !!!)
	wait for clkpulse;
	assert FALSE report "FIN DE SIMULATION" severity FAILURE;

end process P_TEST_0;

end test;

