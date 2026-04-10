-------------------------------------------------
-- Test de pipeline_complet
-- Objectif: verifier l'execution de l'entite pipeline_complet

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;


entity test_pipeline_complet is
	-- pas d'entrees/sorties: composant de test
end test_pipeline_complet;

architecture test of test_pipeline_complet is

	constant TIMEOUT  : time := 1000 ns;
	constant clkpulse : time := 5 ns;

	-- Entrees du pipeline
	signal E_clk, E_init : std_logic;

begin

--------------------------
-- definition du timeout de la simulation
P_TIMEOUT: process
begin
	wait for TIMEOUT;
	assert FALSE report "SIMULATION TIMEOUT!!!" severity FAILURE;
end process P_TIMEOUT;


--------------------------------------------------
-- instantiation du pipeline complet
pipeline_complet_0 : entity work.pipeline
	port map(
		clk => E_clk,
		init => E_init
	);

-----------------------------
-- Clock generation
P_CLOCK: process
begin
	E_clk <= '0';
	wait for clkpulse;
	E_clk <= '1';
	wait for clkpulse;
end process P_CLOCK;


-----------------------------
-- debut sequence de test
P_TEST: process
begin
	-- Valeurs par defaut
	E_init <= '1';
	wait for 2 * clkpulse;

	-- Démarrage normal (init=0)
	E_init <= '0';
	wait for 40 * clkpulse;

	-- Fin de test
	wait for clkpulse;
    assert FALSE report "FIN DE SIMULATION" severity FAILURE;

end process P_TEST;

end architecture test;

