-------------------------------------------------

-- Test integre du dataPath (proc)
-- Objectif: verifier le chainage FE -> DE -> EX -> ME -> RE
-- et montrer la correspondance "type d'instruction" -> signaux de controle.

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.std_logic_arith.all;


entity test_proc is
	-- pas d'entrees/sorties: composant de test
end test_proc;

architecture test of test_proc is

	constant TIMEOUT  : time := 300 ns;
	constant clkpulse : time := 5 ns;

	-- Entrees du dataPath
	signal E_clk, E_init, E_ALUSrc_EX, E_MemWr_Mem, E_MemWr_RE, E_PCSrc_ER,
		   E_Bpris_EX, E_Gel_LI, E_Gel_DI, E_RAZ_DI, E_RegWR, E_Clr_EX,
		   E_MemToReg_RE : std_logic;

	signal E_RegSrc, E_EA_EX, E_EB_EX, E_immSrc, E_ALUCtrl_EX : std_logic_vector(1 downto 0);

	-- Sorties observees
	signal E_instr_DE : std_logic_vector(31 downto 0);
	signal E_a1, E_a2, E_rs1, E_rs2, E_CC, E_op3_EX_out, E_op3_ME_out, E_op3_RE_out : std_logic_vector(3 downto 0);

	-- Rappel des signaux de controle attendus
	-- reg    : Branch=0 MemToReg=0 MemWr=0 AluSrc=0 ImmSrc=-- RegWr=1 RegSrc=00
	-- CMP    : Branch=0 MemToReg=0 MemWr=0 AluSrc=0 ImmSrc=-- RegWr=0 RegSrc=00
	-- regimm : Branch=0 MemToReg=0 MemWr=0 AluSrc=1 ImmSrc=00 RegWr=1 RegSrc=*0
	-- LDR    : Branch=0 MemToReg=1 MemWr=0 AluSrc=1 ImmSrc=01 RegWr=1 RegSrc=*0
	-- STR    : Branch=0 MemToReg=0 MemWr=1 AluSrc=1 ImmSrc=01 RegWr=0 RegSrc=10
	-- B      : Branch=1 MemToReg=0 MemWr=0 AluSrc=1 ImmSrc=10 RegWr=0 RegSrc=*1

begin

--------------------------
-- definition du timeout de la simulation
P_TIMEOUT: process
begin
	wait for TIMEOUT;
	assert FALSE report "SIMULATION TIMEOUT!!!" severity FAILURE;
end process P_TIMEOUT;


--------------------------------------------------
-- instantiation et mapping du composant a tester
dataPath0 : entity work.dataPath(dataPath_arch)
	port map(
		clk => E_clk,
		init => E_init,
		ALUSrc_EX => E_ALUSrc_EX,
		MemWr_Mem => E_MemWr_Mem,
		MemWr_RE => E_MemWr_RE,
		PCSrc_ER => E_PCSrc_ER,
		Bpris_EX => E_Bpris_EX,
		Gel_LI => E_Gel_LI,
		Gel_DI => E_Gel_DI,
		RAZ_DI => E_RAZ_DI,
		RegWR => E_RegWR,
		Clr_EX => E_Clr_EX,
		MemToReg_RE => E_MemToReg_RE,
		RegSrc => E_RegSrc,
		EA_EX => E_EA_EX,
		EB_EX => E_EB_EX,
		immSrc => E_immSrc,
		ALUCtrl_EX => E_ALUCtrl_EX,
		instr_DE => E_instr_DE,
		a1 => E_a1,
		a2 => E_a2,
		rs1 => E_rs1,
		rs2 => E_rs2,
		CC => E_CC,
		op3_EX_out => E_op3_EX_out,
		op3_ME_out => E_op3_ME_out,
		op3_RE_out => E_op3_RE_out
	);


-----------------------------
-- debut sequence de test
P_TEST_0: process
begin
	-- Valeurs par defaut
	E_clk <= '0';
	E_init <= '1';

	E_ALUSrc_EX <= '0';
	E_MemWr_Mem <= '0';
	E_MemWr_RE <= '0';
	E_PCSrc_ER <= '0';
	E_Bpris_EX <= '0';
	E_Gel_LI <= '1';
	E_Gel_DI <= '1';
	E_RAZ_DI <= '1';
	E_RegWR <= '0';
	E_Clr_EX <= '1';
	E_MemToReg_RE <= '0';

	E_RegSrc <= "00";
	E_EA_EX <= "00";
	E_EB_EX <= "00";
	E_immSrc <= "00";
	E_ALUCtrl_EX <= "00";

	-- 1) Reset du banc de registres
	wait for clkpulse;
	E_init <= '0';

	-- 2) Premier cycle: fetch/decode de la premiere instruction (mem[0])
	wait for clkpulse;
	E_clk <= '1';
	wait for clkpulse;
	E_clk <= '0';

	wait for clkpulse/2;
	assert E_instr_DE = x"00001005"
		report "instr_DE devrait etre la premiere instruction (00001005)"
		severity FAILURE;

	-- 3) Exemple de pseudo instruction type ADDI:
	--    ADD Rd,Rn,#imm
	--    Branch=0, MemToReg=0, MemWr=0, AluSrc=1, ImmSrc="00", RegWr=1, RegSrc="00"
	E_RegSrc <= "00";
	E_immSrc <= "00";
	E_ALUSrc_EX <= '1';
	E_ALUCtrl_EX <= "00";
	E_RegWR <= '1';
	E_MemToReg_RE <= '0';
	E_MemWr_Mem <= '0';
	E_Bpris_EX <= '0';
	E_PCSrc_ER <= '0';

	wait for clkpulse/2;
	E_clk <= '1';
	wait for clkpulse;
	E_clk <= '0';

	wait for clkpulse/2;
	assert E_instr_DE = x"00012003"
		report "instr_DE devrait avancer a l'instruction suivante (00012003)"
		severity FAILURE;
	assert E_rs1 = conv_std_logic_vector(1, 4)
		report "RegSrc(0)=0: rs1 doit prendre i_DE(19 downto 16)"
		severity FAILURE;
	assert E_rs2 = conv_std_logic_vector(3, 4)
		report "RegSrc(1)=0: rs2 doit prendre i_DE(3 downto 0)"
		severity FAILURE;

	-- 4) Test selection du PC comme operande (ex: branchement / ADR)
	--    RegSrc="01" => rs1 = 15 (PC)
	E_RegSrc <= "01";

	wait for clkpulse/2;
	assert E_rs1 = conv_std_logic_vector(15, 4)
		report "RegSrc(0)=1: rs1 doit valoir 15 (PC)"
		severity FAILURE;

	-- 5) Test gel FE/DE: Gel_DI='0' garde instr_DE constant
	E_Gel_DI <= '0';

	wait for clkpulse/2;
	E_clk <= '1';
	wait for clkpulse;
	E_clk <= '0';

	wait for clkpulse/2;
	assert E_instr_DE = x"00012003"
		report "Gel_DI=0: instr_DE doit rester gele"
		severity FAILURE;

	E_Gel_DI <= '1';

	-- 6) Test RAZ FE/DE
	E_RAZ_DI <= '0';
	wait for clkpulse/2;
	assert E_instr_DE = conv_std_logic_vector(0, 32)
		report "RAZ_DI=0: registre instruction DE doit etre remis a 0"
		severity FAILURE;
	E_RAZ_DI <= '1';

	-- 7) Test flush DE/EX
	--    Clr_EX='0' efface les bascules entre DE et EX
	E_Clr_EX <= '0';
	wait for clkpulse/2;
	E_clk <= '1';
	wait for clkpulse;
	E_clk <= '0';
	wait for clkpulse/2;
	assert E_a1 = conv_std_logic_vector(0, 4)
		report "Clr_EX=0: a1 doit etre remis a 0"
		severity FAILURE;
	assert E_a2 = conv_std_logic_vector(0, 4)
		report "Clr_EX=0: a2 doit etre remis a 0"
		severity FAILURE;
	E_Clr_EX <= '1';

	-- 8) Exercice du chemin memoire (store puis load)
	--    Type STR: Branch=0, MemToReg=0, MemWr=1, AluSrc=1, ImmSrc="01", RegWr=0, RegSrc=10
	E_MemWr_Mem <= '1';
	E_RegWR <= '0';
	E_ALUSrc_EX <= '0';
	E_immSrc <= "01";
	E_RegSrc <= "10";
	E_EA_EX <= "00";
	E_EB_EX <= "00";
	E_ALUCtrl_EX <= "00";

	wait for clkpulse/2;
	E_clk <= '1';
	wait for clkpulse;
	E_clk <= '0';

	--    Type LDR: Branch=0, MemToReg=1, MemWr=0, AluSrc=1, ImmSrc="01", RegWr=1, RegSrc=*0
	E_MemWr_Mem <= '0';
	E_MemToReg_RE <= '1';
	E_RegWR <= '1';
	E_ALUSrc_EX <= '1';
	E_immSrc <= "01";
	E_RegSrc <= "00";

	wait for clkpulse/2;
	E_clk <= '1';
	wait for clkpulse;
	E_clk <= '0';

	-- 9) Exercice branchement
	--    Type B: Branch=1, MemToReg=0, MemWr=0, AluSrc=1, ImmSrc="10", RegWr=0, RegSrc=*1
	E_Bpris_EX <= '1';
	E_PCSrc_ER <= '1';
	E_MemToReg_RE <= '0';
	E_RegWR <= '0';
	E_ALUSrc_EX <= '1';
	E_immSrc <= "10";
	E_RegSrc <= "01";

	wait for clkpulse/2;
	E_clk <= '1';
	wait for clkpulse;
	E_clk <= '0';

	-- LATEST COMMAND (NE PAS ENLEVER !!!)
	wait for clkpulse;
	assert FALSE report "FIN DE SIMULATION" severity FAILURE;

end process P_TEST_0;

end test;
