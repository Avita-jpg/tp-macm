-------------------------------------------------

-- Test de l'étage ME (Memory)

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.std_logic_arith.all;


entity test_memory is
    -- pas d'entrées sorties car composant de test
end test_memory;

-- Definition de l'architecture
architecture test of test_memory is

-- definition des constantes de test
    constant TIMEOUT 	: time := 150 ns; -- timeout de la simulation
    constant clkpulse   : time := 5 ns;

-- definition de ressources externes
    signal E_Res_ME, E_WD_ME : std_logic_vector(31 downto 0);
    signal E_Op3_ME : std_logic_vector(3 downto 0);
    signal E_MemWR_Mem, E_clk : std_logic;

    signal E_Res_Mem_ME, E_Res_ALU_ME, E_Res_fwd_ME : std_logic_vector(31 downto 0);
    signal E_Op3_ME_out : std_logic_vector(3 downto 0);
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
etageME0 : entity work.etageME(etageME_arch)
    port map (
        Res_ME => E_Res_ME,
        WD_ME => E_WD_ME,
        Op3_ME => E_Op3_ME,
        MemWR_Mem => E_MemWR_Mem,
        clk => E_clk,
        Res_Mem_ME => E_Res_Mem_ME,
        Res_ALU_ME => E_Res_ALU_ME,
        Res_fwd_ME => E_Res_fwd_ME,
        Op3_ME_out => E_Op3_ME_out
    );
-----------------------------
-- debut sequence de test
P_TEST_1: process
begin 
    E_clk <= '0';
    --init 
    E_Op3_ME <= conv_std_logic_vector(0, 4); -- operation d'écriture (SW)

    -- TEST 1 : écriture memoire pour l'initialiser (et tester l'écriture)
    E_Res_ME <= conv_std_logic_vector(16, 32); -- adresse d'écriture
    E_WD_ME <= conv_std_logic_vector(1234, 32); -- donnée 
    E_MemWR_Mem <= '1'; -- on active l'écriture en mémoire
    
    wait for clkpulse;
    E_clk <= '1';
    wait for clkpulse;
    E_clk <= '0';

    wait for clkpulse/2;
    E_Res_ME <= conv_std_logic_vector(20, 32); -- adresse d'écriture
    E_WD_ME <= conv_std_logic_vector(5678, 32); -- donnée
    E_MemWR_Mem <= '1'; -- on active l'écriture en mémoire

    wait for clkpulse/2;
    E_clk <= '1';
    wait for clkpulse;
    E_clk <= '0';

    -------------------
    -- TEST 2: lecture -- verification de la bonne ecriture memoire
    -- Attention: l'ecriture est synchrone mais la lecture est asynchrone
    -- on simule le comportement de bascules inter etage en faisant varier les signaux d'entree au moment du front montant d'horloge
    
    wait for clkpulse;
    E_clk <= '1';
    
    E_MemWR_Mem <= '0'; -- on désactive l'écriture en mémoire pour faire une lecture
    E_Res_ME <= conv_std_logic_vector(16, 32); -- adresse de lecture

    
    wait for clkpulse;
    E_clk <= '0';

    -- ATTENDU : Res_Mem_ME = 1234, Res_ALU_ME = 16, Res_fwd_ME = 16, Op3_ME_out = Op3_ME
    wait for clkpulse/2;
    assert E_Res_Mem_ME = conv_std_logic_vector(1234, 32)
        report "Res_Mem_ME bad value for read @16"
        severity FAILURE;
    assert E_Res_ALU_ME = conv_std_logic_vector(16, 32)
        report "Res_ALU_ME bad value for read @16"
        severity FAILURE;
    assert E_Res_fwd_ME = conv_std_logic_vector(16, 32)
        report "Res_fwd_ME bad value for read @16"
        severity FAILURE;
    assert E_Op3_ME_out = conv_std_logic_vector(0, 4)
        report "Op3_ME_out bad value for read @16"
        severity FAILURE;

    wait for clkpulse;
    E_clk <= '1';

    E_Res_ME <= conv_std_logic_vector(20, 32); -- adresse de lecture

    wait for clkpulse;
    E_clk <= '0';

    -- ATTENDU : Res_Mem_ME = 5678, Res_ALU_ME = 20, Res_fwd_ME = 20, Op3_ME_out = Op3_ME
    wait for clkpulse/2;
    assert E_Res_Mem_ME = conv_std_logic_vector(5678, 32)
        report "Res_Mem_ME bad value for read @20"
        severity FAILURE;
    assert E_Res_ALU_ME = conv_std_logic_vector(20, 32)
        report "Res_ALU_ME bad value for read @20"
        severity FAILURE;
    assert E_Res_fwd_ME = conv_std_logic_vector(20, 32)
        report "Res_fwd_ME bad value for read @20"
        severity FAILURE;
    assert E_Op3_ME_out = conv_std_logic_vector(0, 4)
        report "Op3_ME_out bad value for read @20"
        severity FAILURE;

    -- LATEST COMMAND (NE PAS ENLEVER !!!)
	wait for clkpulse;
	assert FALSE report "FIN DE SIMULATION" severity FAILURE;

end process P_TEST_1;

end test;

