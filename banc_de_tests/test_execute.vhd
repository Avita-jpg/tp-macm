-------------------------------------------------

-- Test de l'étage EX (Execute)

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.std_logic_arith.all;


entity test_execute is
    -- pas d'entrées sorties car composant de test
end test_execute;

-- Definition de l'architecture
architecture test of test_execute is

-- definition des constantes de test
    constant TIMEOUT 	: time := 150 ns; -- timeout de la simulation
    constant clkpulse   : time := 5 ns;

-- definition de ressources externes
    
    signal E_Op1_EX, E_Op2_EX, E_ExtImm_EX, E_Res_fwd_ME, E_Res_fwd_ER : std_logic_vector(31 downto 0);
    signal E_Op3_EX : std_logic_vector(3 downto 0);
    signal E_EA_EX, E_EB_EX, E_ALUCtrl_EX : std_logic_vector(1 downto 0);
    signal E_ALUSrc_EX : std_logic;

    signal E_Res_EX, E_WD_EX, E_npc_fw_br : std_logic_vector(31 downto 0);
    signal E_CC, E_Op3_EX_out : std_logic_vector(3 downto 0);

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
etageEX0 : entity work.etageEX(etageEX_arch)
    port map (
    Op1_EX => E_Op1_EX,
    Op2_EX => E_Op2_EX,
    ExtImm_EX => E_ExtImm_EX,
    Res_fwd_ME => E_Res_fwd_ME,
    Res_fwd_ER => E_Res_fwd_ER,
    Op3_EX => E_Op3_EX,
    EA_EX => E_EA_EX,
    EB_EX => E_EB_EX,
    ALUCtrl_EX => E_ALUCtrl_EX,
    ALUSrc_EX => E_ALUSrc_EX,
    Res_EX => E_Res_EX,
    WD_EX => E_WD_EX,
    npc_fw_br => E_npc_fw_br,
    CC => E_CC,
    Op3_EX_out => E_Op3_EX_out
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

    -- init à 0
    E_Op1_EX <= conv_std_logic_vector(0, 32);
    E_Op2_EX <= conv_std_logic_vector(0, 32);
    E_ExtImm_EX <= conv_std_logic_vector(0, 32);
    E_Res_fwd_ME <= conv_std_logic_vector(0, 32);
    E_Res_fwd_ER <= conv_std_logic_vector(0, 32);
    E_Op3_EX <= conv_std_logic_vector(0, 4);
    E_EA_EX <= "00";
    E_EB_EX <= "00";
    E_ALUCtrl_EX <= "00";
    E_ALUSrc_EX <= '0';

    wait for clkpulse;
    E_clk <= '1';

    -- affecter des nombres differents a chaque entree
    E_Op1_EX <= conv_std_logic_vector(123, 32);
    E_Op2_EX <= conv_std_logic_vector(57, 32);
    E_ExtImm_EX <= conv_std_logic_vector(42, 32);
    E_Res_fwd_ME <= conv_std_logic_vector(86, 32);
    E_Res_fwd_ER <= conv_std_logic_vector(111, 32);
    E_Op3_EX <= conv_std_logic_vector(4, 4);

    -- faire varier les autres signaux de controle pour tester les differentes fonctionnalites de l'etage EX
    E_EA_EX <= "00"; -- on selectionne Op1_EX pour ALUOp1
    E_EB_EX <= "00"; -- on selectionne Op2_EX pour Oper2
    E_ALUCtrl_EX <= "00"; -- on selectionne l'operation ADD pour l'ALU
    E_ALUSrc_EX <= '0'; -- on selectionne Oper2 pour ALUOp2


    wait for clkpulse;
    E_clk <= '0';
    
    -- ATTENDU : Res_EX = Op1_EX + Op2_EX = 123 + 57 = 180, CC = condition codes de l'operation ADD, npc_fw_br = Res_EX, Op3_EX_out = Op3_EX
    wait for clkpulse/2;
    assert E_Res_EX = conv_std_logic_vector(180, 32)
        report "Res_EX bad value for test 1"
        severity FAILURE;
    assert E_npc_fw_br = conv_std_logic_vector(180, 32)
        report "npc_fw_br bad value for test 1"
        severity FAILURE;
    assert E_Op3_EX_out = conv_std_logic_vector(4, 4)
        report "Op3_EX_out bad value for test 1"
        severity FAILURE;
    
    wait for clkpulse;
    E_clk <= '1';
    
    
    E_EA_EX <= "01"; -- on selectionne Res_fwd_ER pour ALUOp1
    E_EB_EX <= "10"; -- on selectionne Res_fwd_ME pour Oper2
    E_ALUCtrl_EX <= "00"; -- on selectionne l'operation ADD pour l'ALU
    E_ALUSrc_EX <= '0'; -- on selectionne Oper2 pour ALUOp2

    wait for clkpulse;
    E_clk <= '0';

    -- ATTENDU : Res_EX = Res_fwd_ER + Res_fwd_ME = 111 + 86 = 197, CC = condition codes de l'operation ADD, npc_fw_br = Res_EX, Op3_EX_out = Op3_EX
    wait for clkpulse/2;
    assert E_Res_EX = conv_std_logic_vector(197, 32)
        report "Res_EX bad value for test 2"
        severity FAILURE;
    assert E_npc_fw_br = conv_std_logic_vector(197, 32)
        report "npc_fw_br bad value for test 2"
        severity FAILURE;
    assert E_Op3_EX_out = conv_std_logic_vector(4, 4)
        report "Op3_EX_out bad value for test 2"
        severity FAILURE;

    wait for clkpulse;
    E_clk <= '1';

    E_EA_EX <= "10"; -- on selectionne Res_fwd_ME pour ALUOp1
    E_EB_EX <= "00"; -- on selectionne Op2_EX pour Oper2
    E_ALUCtrl_EX <= "00"; -- on selectionne l'operation ADD pour l'ALU
    E_ALUSrc_EX <= '1'; -- on selectionne ExtImm_EX pour ALUOp2

    wait for clkpulse;
    E_clk <= '0';

    -- ATTENDU : Res_EX = Res_fwd_ME + ExtImm_EX = 86 + 42 = 128, CC = condition codes de l'operation ADD, npc_fw_br = Res_EX, Op3_EX_out = Op3_EX
    wait for clkpulse/2;
    assert E_Res_EX = conv_std_logic_vector(128, 32)
        report "Res_EX bad value for test 3"
        severity FAILURE;
    assert E_npc_fw_br = conv_std_logic_vector(128, 32)
        report "npc_fw_br bad value for test 3"
        severity FAILURE;
    assert E_Op3_EX_out = conv_std_logic_vector(4, 4)
        report "Op3_EX_out bad value for test 3"
        severity FAILURE;

    -- LATEST COMMAND (NE PAS ENLEVER !!!)
	wait for clkpulse;
	assert FALSE report "FIN DE SIMULATION" severity FAILURE;

end process P_TEST_1;

end test;

