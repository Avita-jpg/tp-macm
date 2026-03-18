LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

PACKAGE bus_mux_pkg IS
	TYPE bus_mux_array IS ARRAY(NATURAL RANGE<>) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
END PACKAGE bus_mux_pkg;

-------------------------------------------------

-- 32 bits Register (For PC storage )

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity Reg32 is
  PORT(
    source: in std_logic_vector(31 downto 0);
    output : out std_logic_vector(31 downto 0);
    wr, raz, clk : in std_logic
    );
end entity;

architecture arch_reg of Reg32 is
  signal sig : std_logic_vector(31 downto 0):=(others => '0');
begin
  output <= sig;
  process(clk, raz)
  begin
    if raz = '0' then
      sig <= (others => '0');
    else
      if(rising_edge(clk)) then
        if(wr = '1') then
          sig <= source;    
        end if;
      end if;
    end if;
  end process;
end architecture;

-------------------------------------------------

-- 32 bits Register (For inter-stage buffers )

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity Reg32sync is
  PORT(
    source: in std_logic_vector(31 downto 0);
    output : out std_logic_vector(31 downto 0);
    wr, raz, clk : in std_logic
    );
end entity;

architecture arch_reg_sync of Reg32sync is
  signal sig : std_logic_vector(31 downto 0):=(others => '0');
begin
  output <= sig;
  process(clk)
  begin
    if(rising_edge(clk)) then
      if raz = '0' then
        sig <= (others => '0');
      else
        if(wr = '1') then
          sig <= source;    
        end if;
      end if;
    end if;
  end process;
end architecture;


-------------------------------------------------

-- 4 bits Register (For inter-stage buffers)

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity Reg4 is
  PORT(
    source: in std_logic_vector(3 downto 0);
    output : out std_logic_vector(3 downto 0);
    wr, raz, clk : in std_logic
    );
end entity;

architecture arch_reg of Reg4 is
  signal sig : std_logic_vector(3 downto 0):=(others => '0');
begin
  output <= sig;
  process(clk)
  begin
    if(rising_edge(clk)) then
      if raz = '0' then
        sig <= (others => '0');
      else
        if(wr = '1') then
          sig <= source;    
        end if;
      end if;
    end if;
  end process;
end architecture;

-------------------------------------------------

-- 2 bits Register (For inter-stage buffers)

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity Reg2 is
  PORT(
    source: in std_logic_vector(1 downto 0);
    output : out std_logic_vector(1 downto 0);
    wr, raz, clk : in std_logic
    );
end entity;

architecture arch_reg of Reg2 is
  signal sig : std_logic_vector(1 downto 0):=(others => '0');
begin
  output <= sig;
  process(clk)
  begin
    if(rising_edge(clk)) then
      if raz = '0' then
        sig <= (others => '0');
      else
        if(wr = '1') then
          sig <= source;    
        end if;
      end if;
    end if;
  end process;
end architecture;

-------------------------------------------------

-- 1 bit Register (For inter-stage buffers)

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity Reg1 is
  PORT(
    source: in std_logic;
    output : out std_logic;
    wr, raz, clk : in std_logic
    );
end entity;

architecture arch_reg of Reg1 is
  signal sig : std_logic:='0';
begin
  output <= sig;
  process(clk)
  begin
    if(rising_edge(clk)) then
      if raz = '0' then
        sig <= '0';
      else
        if(wr = '1') then
          sig <= source;    
        end if;
      end if;
    end if;
  end process;
end architecture;


-------------------------------------------------

-- Register bank

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.bus_mux_pkg.ALL;

ENTITY RegisterBank IS
	PORT
	(
		s_reg_0 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		data_o_0 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		s_reg_1 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		data_o_1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		dest_reg : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		data_i : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
                pc_in : in STD_LOGIC_VECTOR(31 downto 0);
                init : in STD_LOGIC; 
		wr_reg : IN STD_LOGIC;
		clk : IN STD_LOGIC
	);
END ENTITY RegisterBank;


architecture arch_reg_bank of RegisterBank IS
  signal regs : bus_mux_array(31 downto 0);

begin
  data_o_0 <= pc_in when to_integer(unsigned(s_reg_0)) = 15 else regs(to_integer(unsigned(s_reg_0)));
  data_o_1 <= pc_in when to_integer(unsigned(s_reg_1)) = 15 else regs(to_integer(unsigned(s_reg_1)));
  process(clk, init)
    variable dest: integer;  
  begin
    if(init='1') then
      for i in 0 to 15 loop
        regs(i)<=(others => '0');
      end loop;
    end if;
    
    if(wr_reg='1' and rising_edge(clk)) then
      dest := to_integer(unsigned(dest_reg));
      regs(dest)<=data_i;
    end if;
  end process;
  
end architecture;
