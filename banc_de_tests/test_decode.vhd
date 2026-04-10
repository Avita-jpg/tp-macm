-------------------------------------------------

-- Test de l'étage FE (Fetch)

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.std_logic_arith.all;


entity test_decode is
    -- pas d'entrées sorties car composant de test
end test_decode;

-- Definition de l'architecture
architecture test of test_decode is

-- definition des constantes de test
    constant TIMEOUT 	: time := 150 ns; -- timeout de la simulation
    constant clkpulse   : time := 5 ns;

-- definition de ressources externes

    signal E_i_DE, E_WD_ER, E_pc_plus_4 : std_logic_vector(31 downto 0);
    signal E_Op3_ER : std_logic_vector(3 downto 0); 
    signal E_RegSrc, E_immSrc : std_logic_vector(1 downto 0);
    signal E_RegWr, E_clk, E_Init : std_logic;
  
    signal E_Reg1, E_Reg2, E_Op3_DE : std_logic_vector(3 downto 0);
    signal E_extImm, E_Op1, E_Op2 : std_logic_vector(31 downto 0);
    
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
etageDE0 : entity work.etageDE(etageDE_arch)
    port map(
    i_DE => E_i_DE,
    WD_ER => E_WD_ER,
    pc_plus_4 => E_pc_plus_4,
    Op3_ER => E_Op3_ER,
    RegSrc => E_RegSrc,
    immSrc => E_immSrc,
    RegWr => E_RegWr,
    clk => E_clk,
    Init => E_Init,
    Reg1 => E_Reg1,
    Reg2 => E_Reg2,
    Op3_DE => E_Op3_DE,
    extImm => E_extImm,
    Op1 => E_Op1,
    Op2 => E_Op2
);

-----------------------------
-- debut sequence de test
P_TEST_1: process
begin 
    E_clk <= '0';

    -- TEST 1 : écriture dans les registres et lecture des opérandes
    E_Init <= '1'; -- initialisation asynchrone des registres

    E_i_DE <= conv_std_logic_vector(0, 32); -- pour ce test l'instruction n'est pas importante
    E_WD_ER <= conv_std_logic_vector(1234, 32); -- donnée à écrire dans le registre de destination
    E_pc_plus_4 <= conv_std_logic_vector(8, 32); -- on peut egalement tester l'enregistrement du pc
    E_Op3_ER <= conv_std_logic_vector(4, 4); -- registre de destination = r4
    E_RegSrc <= "00"; -- pas important pour ce test
    E_immSrc <= "00"; -- pas d'immédiat

    E_RegWr <= '1'; -- on active l'écriture dans le registre de destination 
    
    wait for clkpulse;
    E_Init <= '0';

    wait for clkpulse;
    E_clk <= '1';
    wait for clkpulse;
    E_clk <= '0';

    wait for clkpulse/2;
    -------------------
    -- TEST 2: lecture -- verification de la bonne ecriture dans le banc de registres

    E_RegWr <= '0'; -- on desactive l'écriture dans le registre de destination

    -- lecture registre 4 
    E_i_DE <= (14=>'1', others => '0'); -- <15..12> = 0100 => on selectionne le registre r4 pour la lecture de Op2
    E_RegSrc <= "11"; -- on selectionne lire l'adresse 15 et l'adresse Rm (dans l'instruction)

    wait for clkpulse/2; 
    E_clk <= '1';
    wait for clkpulse;
    E_clk <= '0';

    wait for clkpulse/2;
    -- ATTENDU : on lit la donnée 1234 dans Op2 et la valeur du pc (8) dans Op1

    assert E_Op2 = conv_std_logic_vector(1234, 32)
        report "Op2 register bad value"
        severity FAILURE;
    assert E_Op1 = conv_std_logic_vector(8, 32)
        report "Op1 register bad value"
        severity FAILURE;
    assert E_Reg1 = "1111"
        report "Reg1 address bad value"
        severity FAILURE;
    assert E_Reg2 = "0100"
        report "Reg2 address bad value"
        severity FAILURE;

    --------------------
    -- TEST 3: lecture classique avec RegSrc = "00" (Rn et Rm)
    -- On lit r4 sur les deux ports pour verifier les chemins de selection
    E_RegSrc <= "00";
    E_i_DE <= (others => '0');
    E_i_DE(19 downto 16) <= "0100"; -- Rn = r4 -> Op1
    E_i_DE(3 downto 0) <= "0100";   -- Rm = r4 -> Op2

    wait for clkpulse/2;
    E_clk <= '1';
    wait for clkpulse;
    E_clk <= '0';
    wait for clkpulse/2;

    assert E_Reg1 = "0100"
        report "Reg1 should select Rn when RegSrc(0)=0"
        severity FAILURE;
    assert E_Reg2 = "0100"
        report "Reg2 should select Rm when RegSrc(1)=0"
        severity FAILURE;
    assert E_Op1 = conv_std_logic_vector(1234, 32)
        report "Op1 register bad value for RegSrc=00"
        severity FAILURE;
    assert E_Op2 = conv_std_logic_vector(1234, 32)
        report "Op2 register bad value for RegSrc=00"
        severity FAILURE;

    -- TEST 4: extension immediate 12 bits signee (immSrc = "00")
    -- immIn(11) = 1 -> extension signee attendue: 0xFFFFF800
    E_immSrc <= "00";
    E_i_DE <= (others => '0');
    E_i_DE(11) <= '1';

    wait for clkpulse/2;

    assert E_extImm = std_logic_vector(to_signed(-2048, 32))
        report "extImm bad value for immSrc=00 (signed 12-bit extension)"
        severity FAILURE;

    -- TEST 5: extension immediate 24 bits (immSrc = "10")
    -- immIn = 0xFFFFFF -> extension attendue: 0xFFFFFFFF
    E_immSrc <= "10";
    E_i_DE <= (others => '0');
    E_i_DE(23 downto 0) <= (others => '1');

    wait for clkpulse/2;

    assert E_extImm = std_logic_vector(to_signed(-1, 32))
        report "extImm bad value for immSrc=10 (24-bit extension)"
        severity FAILURE;
    
    -- LATEST COMMAND (NE PAS ENLEVER !!!)
	wait for clkpulse;
	assert FALSE report "FIN DE SIMULATION" severity FAILURE;

end process P_TEST_1;

end test;

