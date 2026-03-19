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

    constant clkpulse : Time := 5 ns; -- 1/2 periode horloge


-- definition de ressources externes
    signal E_npc, E_npc_fw_br, E_pc_plus_4, E_i_FE : std_logic_vector(31 downto 0);

    signal E_PCSrc_ER, E_Bpris_EX, E_GEL_LI, E_clk : std_logic;

begin

--------------------------
-- definition de l'horloge
P_E_CLK: process
begin
	E_clk <= '1';
	wait for clkpulse;
	E_clk <= '0';
	wait for clkpulse;
end process P_E_CLK;


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
-- debut sequence de test, cas nouvelle adresse pc
P_TEST_0: process
begin 
    -- initialisations
    
    wait for clkpulse*2; 
    wait for clkpulse/2;

    E_npc <= conv_std_logic_vector(4, 32);
    E_GEL_LI <= '1';
    E_PCSrc_ER <= '0';
    E_Bpris_EX <= '0';
    E_npc_fw_br <= (others =>'U');

    wait until (E_CLK = '1');

    assert E_i_FE /= conv_std_logic_vector(4, 32)
        report "Instr register bad value"
        severity FAILURE; 


    -- LATEST COMMAND (NE PAS ENLEVER !!!)
	wait until (E_CLK='1'); wait for clkpulse/2;
	assert FALSE report "FIN DE SIMULATION" severity FAILURE;

end process P_TEST_0;

end test;

