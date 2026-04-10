-------------------------------------------------

-- Test de l'étage ER (Retire)

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.std_logic_arith.all;


entity test_retire is
    -- pas d'entrées sorties car composant de test
end test_retire;

-- Definition de l'architecture
architecture test of test_retire is

-- definition des constantes de test
    constant TIMEOUT 	: time := 150 ns; -- timeout de la simulation
    constant clkpulse   : time := 5 ns;

-- definition de ressources externes
    
    signal E_Res_Mem_RE, E_Res_ALU_RE, E_Res_RE : std_logic_vector(31 downto 0);
    signal E_Op3_RE, E_Op3_RE_out : std_logic_vector(3 downto 0);
    signal E_MemToReg_RE : std_logic;

    signal E_clk : std_logic;

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
etageER0 : entity work.etageER(etageER_arch)
    port map (
    Res_Mem_RE => E_Res_Mem_RE,
    Res_ALU_RE => E_Res_ALU_RE,
    Res_RE => E_Res_RE,
    Op3_RE => E_Op3_RE,
    MemToReg_RE => E_MemToReg_RE,
    Op3_RE_out => E_Op3_RE_out
);

-----------------------------
-- debut sequence de test
P_TEST_1: process
begin 

    -- cette partie n'est pas synchrone
    -- l'execution est cadencée grâce aux bascules inter etage
    -- donc on fait varier les siganux en meme temps que le front montnant d'horloge
    -- pour simuler le comportement des bascules inter etage

    E_clk <= '0';
    -- init
    E_Res_Mem_RE <= conv_std_logic_vector(0, 32);
    E_Res_ALU_RE <= conv_std_logic_vector(0, 32);
    E_Op3_RE <= conv_std_logic_vector(0, 4);
    E_MemToReg_RE <= '0';

    wait for clkpulse;
    E_clk <= '1';

    E_Res_Mem_RE <= conv_std_logic_vector(1234, 32);
    E_Res_ALU_RE <= conv_std_logic_vector(5678, 32);
    E_Op3_RE <= conv_std_logic_vector(3, 4);
    E_MemToReg_RE <= '1'; -- on selectionne Res_Mem_RE 

    wait for clkpulse;
    E_clk <= '0';

    -- ATTENDU : Res_RE = 1234, Op3_RE_out = Op3_RE
    wait for clkpulse/2;
    assert E_Res_RE = conv_std_logic_vector(1234, 32)
        report "Res_RE bad value when MemToReg_RE=1"
        severity FAILURE;
    assert E_Op3_RE_out = conv_std_logic_vector(3, 4)
        report "Op3_RE_out bad value in test 1"
        severity FAILURE;
    
    wait for clkpulse;
    E_clk <= '1';

    E_MemToReg_RE <= '0'; -- on selectionne Res_ALU_RE

    wait for clkpulse;
    E_clk <= '0';

    -- ATTENDU : Res_RE = 5678, Op3_RE_out = Op3_RE
    wait for clkpulse/2;
    assert E_Res_RE = conv_std_logic_vector(5678, 32)
        report "Res_RE bad value when MemToReg_RE=0"
        severity FAILURE;
    assert E_Op3_RE_out = conv_std_logic_vector(3, 4)
        report "Op3_RE_out bad value in test 2"
        severity FAILURE;

    -- LATEST COMMAND (NE PAS ENLEVER !!!)
	wait for clkpulse;
	assert FALSE report "FIN DE SIMULATION" severity FAILURE;

end process P_TEST_1;

end test;

