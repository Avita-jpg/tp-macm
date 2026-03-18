------------------------------------------------------

-- Full adder 1b, 32b with carry bits out


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity fulladd1b is
  port(
    a, b, cin : in std_logic;
    s, cout : out std_logic
    );
end entity;

architecture arche_full_add of fulladd1b is
  begin
    s <= a xor b xor cin;
    cout <= (a and b) or (a and cin) or (b and cin);
end architecture;


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity addComplex is
  port(
    A, B: in std_logic_vector(31 downto 0);
    cin: in std_logic;
    s : out std_logic_vector(31 downto 0);
    c30, c31: out std_logic);
end entity;

architecture arch_add_complex of addComplex is
  signal carry : std_logic_vector(32 downto 0);
begin
  for1: for i in 0 to 31 generate
    addi: entity work.fulladd1b
      port map(A(i), B(i), carry(i), s(i), carry(i+1));
  end generate;

  carry(0) <= cin;
  c30 <= carry(31);
  c31 <= carry(32);

end architecture;

----------------------------------------------

-- ALU

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY ALU IS
	PORT
	(
		A : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		B : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		sel : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		Res : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
                CC : OUT STD_LOGIC_VECTOR(3 downto 0)
		
	);
END ENTITY ALU;

architecture arch_ALU of ALU is
  signal pos, c30, c31, Z, N, C, V : STD_LOGIC;
  signal addSig, SR, SL, Bmod, Zint, resint : STD_LOGIC_VECTOR(31 downto 0);
begin
  
  forBmod: for i in 0 to 31 generate
    Bmod(i) <= B(i) xor sel(0);
  end generate;
  
  add: entity work.addComplex
    port map(A, Bmod, sel(0), addSig, c30, c31);

  resint <= A and B when sel= "10" else
            A or B when sel = "11" else
            addSig when sel = "00" or sel = "01" else
            (others =>'X')
            ;

  Zint(0) <= resint(0);
  for1: for i in 1 to 31 generate
        Zint(i) <= Zint(i-1) or resint(i);
  end generate;
  

  Z <= not Zint(31);
  N <= addSig(31);
  V <= (not sel(1)) and (not (A(31) xor B(31) xor sel(0))) and (A(31) xor c31);
  C <= c31 xor sel(1);

  CC <= N & Z & C & V;
  Res <= resint;
  
end architecture;

---------------------------------------------------

-- Extension logic for immediate inputs

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity extension is
  port(
    immIn : in std_logic_vector(23 downto 0);
    immSrc : in std_logic_vector(1 downto 0);
    ExtOut : out std_logic_vector(31 downto 0)
    );
end entity;

architecture arch_ext of extension is
  signal extImm12, extImm24: std_logic_vector(31 downto 0);
  signal extSign20: std_logic_vector(19 downto 0);
  signal extSign8: std_logic_vector(7 downto 0);
  
  signal zeros: std_logic_vector(7 downto 0);
begin
  extSign20 <= (others => immIn(11))when immSrc(0) = '0' else
                  (others => '0');
  
  extImm12 <= extSign20 & immIn(11 downto 0) ;
  
  
  extSign8 <= (others => immIn(23));
  extImm24 <= extSign8 & immIn;

  ExtOut <= extImm12 when immSrc(1) = '0' else
            extImm24 when immSrc = "10" else
            (others => 'X');
  
end architecture;
