LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity cond_entity is
  port(
    Cond, CC_EX, CC: in std_logic_vector(3 downto 0);
    CCWr_EX : in std_logic;
    CCp : out std_logic_vector(3 downto 0);
    CondEx : out std_logic
  );
end entity;

architecture cond_arch of cond_entity is
    signal CondEx_calc : std_logic;
    signal N, Z, C, V : std_logic;
begin
    
  -- La condition d'execution doit etre evaluee sur les flags courants
  -- (flags latched en entree CC_EX), pas sur les nouveaux flags de l'ALU.
  N <= CC_EX(3);
  Z <= CC_EX(2);
  C <= CC_EX(1);
  V <= CC_EX(0);

    CCp <= CC when CCWr_EX = '1' and CondEx_calc = '1' 
                    else CC_EX;

    CondEx_calc <= '1' when 
        (Cond = "0000" and Z = '1') or
        (Cond = "0001" and Z = '0') or
        (Cond = "0010" and C = '1') or
        (Cond = "0011" and C = '0') or
        (Cond = "0100" and N = '1') or
        (Cond = "0101" and N = '0') or
        (Cond = "0110" and V = '1') or
        (Cond = "0111" and V = '0') or
        (Cond = "1000" and C = '1' and Z = '0') or
        (Cond = "1001" and (C = '0' or Z = '1')) or
        (Cond = "1010" and N = V) or
        (Cond = "1011" and N /= V) or
        (Cond = "1100" and Z = '0' and N = V) or
        (Cond = "1101" and (Z = '1' or N /= V)) or
        (Cond = "1110") 
                    else '0';

    CondEx <= CondEx_calc;

end architecture;