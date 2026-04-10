LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity ctrl is
  port(
    instr : in std_logic_vector(31 downto 0);
    PCSrc, RegWr, MemToReg, MemWr, Branch, CCWr, AluSrc : out std_logic;
    ImmSrc, RegSrc, AluCtrl : out std_logic_vector(1 downto 0);
    Cond : out std_logic_vector(3 downto 0)
  );
end entity;

architecture ctrl_arch of ctrl is
begin

  Cond <= instr(31 downto 28);

  Branch   <= '1' when instr(27 downto 26) = "10" else '0';
  MemToReg <= '1' when instr(27 downto 26) = "01" and instr(20) = '1' else '0';
  MemWr    <= '1' when instr(27 downto 26) = "01" and instr(20) = '0' else '0';
  AluSrc   <= '1' when instr(27 downto 26) = "00" and instr(25) = '1' else
              '1' when instr(27 downto 26) = "01" else
              '1' when instr(27 downto 26) = "10" else
              '0';
  RegWr    <= '1' when instr(27 downto 26) = "00" and instr(20) = '0' else
              '1' when instr(27 downto 26) = "00" and instr(25) = '1' else
              '1' when instr(27 downto 26) = "01" and instr(20) = '1' else
              '0';
  CCWr     <= '1' when instr(27 downto 26) = "00" and instr(20) = '1' else '0';
  
  PCSrc    <= '1' when instr(15 downto 12) = "1111" else '0'; 

  
  ImmSrc <= "00" when instr(27 downto 26) = "00" and instr(25) = '1' else
            "01" when instr(27 downto 26) = "01" else
            "10" when instr(27 downto 26) = "10" else
            "00";

  RegSrc <= "00" when instr(27 downto 26) = "00" else -- reg/reg ou cmp ou reg/imm
            "10" when instr(27 downto 26) = "01" else -- LDR ou STR
            "11" when instr(27 downto 26) = "10" else   -- B               
            "00";

  -- ALU control
  -- 00 = ADD, 01 = SUB, 10 = AND, 11 = ORR
  AluCtrl <= "00" when instr(27 downto 26) = "10" else
             "00" when instr(27 downto 26) = "01" else
             "00" when instr(27 downto 26) = "00" and instr(24 downto 21) = "0100" else
             "01" when instr(27 downto 26) = "00" and (instr(24 downto 21) = "0010" or instr(24 downto 21) = "1010") else
             "10" when instr(27 downto 26) = "00" and instr(24 downto 21) = "0000" else
             "11" when instr(27 downto 26) = "00" and instr(24 downto 21) = "1100" else
             "00";

end architecture;
