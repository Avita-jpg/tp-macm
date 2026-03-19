-------------------------------------------------

-- Etage FE

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity etageFE is
  port(
    npc, npc_fw_br : in std_logic_vector(31 downto 0);
    PCSrc_ER, Bpris_EX, GEL_LI, clk : in std_logic;
    pc_plus_4, i_FE : out std_logic_vector(31 downto 0)
);
end entity;


architecture etageFE_arch of etageFE is
  signal pc_inter, pc_reg_in, pc_reg_out, sig_pc_plus_4, sig_4: std_logic_vector(31 downto 0);
begin

  sig_4 <= (2=>'1', others => '0');
  
  -- Architecture à compléter
  REGS_I: entity work.inst_mem
    port map(addr => pc_reg_out, instr => i_FE);
  
  PC: entity work.Reg32
    port map(source => pc_reg_in, output => pc_reg_out, wr => GEL_LI, raz => '1', clk => clk);

  ADD4: entity work.addComplex
    port map(A => pc_reg_out, B => sig_4, cin => '0', s => sig_pc_plus_4, c30 => open, c31 => open);
  
  
  pc_inter <= npc when (PCSrc_ER = '1') else sig_pc_plus_4;
  pc_reg_in <= npc_fw_br when (Bpris_EX = '1') else pc_inter;
    
  pc_plus_4 <= sig_pc_plus_4;
  
end architecture;

-- -------------------------------------------------

-- -- Etage DE

-- LIBRARY IEEE;
-- USE IEEE.STD_LOGIC_1164.ALL;
-- USE IEEE.NUMERIC_STD.ALL;

-- entity etageDE is
-- end entity;

-- -------------------------------------------------

-- -- Etage EX

-- LIBRARY IEEE;
-- USE IEEE.STD_LOGIC_1164.ALL;
-- USE IEEE.NUMERIC_STD.ALL;

-- entity etageEX is
-- end entity
-- -------------------------------------------------

-- -- Etage ME

-- LIBRARY IEEE;
-- USE IEEE.STD_LOGIC_1164.ALL;
-- USE IEEE.NUMERIC_STD.ALL;

-- entity etageME is
-- end entity;
-- -------------------------------------------------

-- -- Etage ER

-- LIBRARY IEEE;
-- USE IEEE.STD_LOGIC_1164.ALL;
-- USE IEEE.NUMERIC_STD.ALL;

-- entity etageER is
-- end entity;
