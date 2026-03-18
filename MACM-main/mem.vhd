-----------------------------------------------

-- IMEM, alternative implementation

library IEEE; 
use IEEE.STD_LOGIC_1164.all; use STD.TEXTIO.all;
use IEEE.NUMERIC_STD.all;  
entity imem is -- instruction memory
  port(a:  in  STD_LOGIC_VECTOR(31 downto 0);
       rd: out STD_LOGIC_VECTOR(31 downto 0));
end;
architecture behave of imem is -- instruction memory
begin
  process is
    file mem_file: TEXT;
    variable L: line;
    variable ch: character;
    variable i, index, result: integer;
    variable conv : std_logic_vector(3 downto 0);
    type ramtype is array (63 downto 0) of 
                    STD_LOGIC_VECTOR(31 downto 0);
    variable mem: ramtype;
  begin
    -- initialize memory from file
    for i in 0 to 63 loop -- set all contents low
      mem(i) := (others => '0'); 
    end loop;
    index := 0; 
    FILE_OPEN(mem_file, "memfile.dat", READ_MODE);
    while not endfile(mem_file) loop
      readline(mem_file, L);
      result := 0;
      for i in 1 to 8 loop
        read(L, ch);
        if '0' <= ch and ch <= '9' then 
            result := character'pos(ch) - character'pos('0');
        elsif 'a' <= ch and ch <= 'f' then
           result := character'pos(ch) - character'pos('a')+10;
        elsif 'A' <= ch and ch <= 'F' then
           result := character'pos(ch) - character'pos('A')+10;
        else report "Format error on line " & integer'image(index)
             severity error;
        end if;
        --conv := std_logic_vector(result);
        mem(index)(35-i*4 downto 32-i*4) := --conv;
          std_logic_vector(to_unsigned(result, 4));
      end loop;
      index := index + 1;
    end loop;

    -- read memory
    loop
      rd <= mem(to_integer(unsigned(a(7 downto 2)))); 
      wait on a;
    end loop;
  end process;
end;


-------------------------------------------------------

-- Simplified memory interface

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;


entity inst_mem is
  port (
    addr : in std_logic_vector(31 downto 0);
    instr : out std_logic_vector(31 downto 0)
    );
end entity;

architecture arch_inst_mem of inst_mem is
begin

  mem: entity work.imem
    port map(addr, instr);
end architecture;

-------------------------------------------------------

-- DMEM, alternative implementation

library IEEE; 
use IEEE.STD_LOGIC_1164.all; use STD.TEXTIO.all;
use IEEE.NUMERIC_STD.all; 
entity dmem is -- data memory
  port(clk, we:  in STD_LOGIC;
       a, wd:    in STD_LOGIC_VECTOR(31 downto 0);
       rd:       out STD_LOGIC_VECTOR(31 downto 0));
end;

architecture behave of dmem is
begin
  process is
    type ramtype is array (63 downto 0) of 
                    STD_LOGIC_VECTOR(31 downto 0);
    variable mem: ramtype;
  begin -- read or write memory
    loop
      if clk'event and clk = '1' then
          if (we = '1') then 
            mem(to_integer(unsigned(a(7 downto 2)))) := wd;
          end if;
      end if;
      rd <= mem(to_integer(unsigned(a(7 downto 2)))); 
      wait on clk, a;
    end loop;
  end process;
end;

-------------------------------------------------------

-- Simplified data memory interface

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;


entity data_mem is
  port (
    addr, WD : in std_logic_vector(31 downto 0);
    clk, WR : in std_logic;
    data : out std_logic_vector(31 downto 0)
    );
end entity;


architecture arch_data_mem of data_mem is
begin

  mem: entity work.dmem
    port map(clk, WR, addr, WD, data);
end architecture;


-- ---------------------------------------

-- -- Memory read port

-- LIBRARY IEEE;
-- USE IEEE.STD_LOGIC_1164.ALL;
-- USE IEEE.NUMERIC_STD.ALL;

-- entity ReadPort is
--   port(
--     BusIn : in std_logic_vector(31 downto 0);
--     address : in std_logic_vector(31 downto 0);
--     LireMem_W, LireMem_UB, LireMem_SB, LireMem_UH, LireMem_SH : in std_logic;
--     BusOut : out std_logic_vector(31 downto 0)
--     );
-- end entity;


-- architecture arch_ReadPort_simple of ReadPort is
--   signal b7, b15 : STD_LOGIC;
--   signal HW : STD_LOGIC_VECTOR(15 downto 0);
--   signal B : std_logic_vector(7 downto 0);
--   signal ones_16, zeros_16 : STD_LOGIC_VECTOR(15 downto 0);
--   signal ones_24, zeros_24 : STD_LOGIC_VECTOR(23 downto 0);
--   signal C : std_logic_vector(6 downto 0);
-- begin
--    -- Validation signals for tri-state gates
--   C(0) <= LireMem_W;
--   C(1) <= LireMem_UB or LireMem_SB;
--   C(2) <= LireMem_UH or LireMem_SH;
-- --  C(3) <= LireMem_UB or (LireMem_SB and not b7);
-- --  C(4) <= LireMem_SB and b7;
--   C(5) <= LireMem_UB or (LireMem_SB and not b7) or LireMem_SH or (LireMem_SH and not b15);
--   C(6) <= (LireMem_SB and b7) or (LireMem_SH and b15);


--   ones_16 <= (others => '1');
--   zeros_16 <= (others => '0');
--   ones_24 <= (others => '1');
--   zeros_24 <= (others => '0');

--   HW <= BusIn(15 downto 0) when address(1)= '0' else
--         BusIn(31 downto 0);

--   B <= BusIn(7 downto 0) when (address(1)= '0') and (address(0)= '0') else
--        BusIn(15 downto 8) when (address(1)= '0') and address(0)= '1' else
--        BusIn(23 downto 16) when address(1)= '1' and (address(0)= '0') else
--        BusIn(31 downto 24);
  
--   b7 <= B(7);
--   b15 <= HW(15);
  
--   BusOut <= BusIn when C(0)= '1' else
--             ones_16 & HW when C(2)= '1' and C(6)='1' else
--             zeros_16 & HW when C(2)= '1' and C(5)='1' else
--             ones_24 & B when C(1)='1' and C(6)='1' else
--             zeros_24 & B;
-- end architecture;

-- -------------------------------------------------------

-- -- Memory write port

-- LIBRARY IEEE;
-- USE IEEE.STD_LOGIC_1164.ALL;
-- USE IEEE.NUMERIC_STD.ALL;

-- entity WritePort is
--   port(
--     address, data_in, current_mem : in std_logic_vector(31 downto 0);
    
--     EcrireMem_W, EcrireMem_H, EcrireMem_B : std_logic;
--     data_out : out std_logic_vector(31 downto 0)
--     );
-- end entity;

-- architecture arch_WP of WritePort is
-- begin
--   data_out <= data_in when EcrireMem_W='1' else
--               current_mem(31 downto 16) & data_in(15 downto 0) when EcrireMem_H= '1' and address(1)='0' else
--               data_in(15 downto 0) & current_mem(15 downto 0) when EcrireMem_H='1' and address(1)='1' else
--               current_mem(31 downto 8) & data_in(7 downto 0) when EcrireMem_B='1' and (address(0)='0') and (address(1)='0') else
--               current_mem(31 downto 16) & data_in(7 downto 0)&current_mem(7 downto 0)  when EcrireMem_B= '1' and address(0)='1' and (address(1)='0') else
--               current_mem(31 downto 24) & data_in(7 downto 0)&current_mem(15 downto 0)  when EcrireMem_B='1' and (address(0)='0') and address(1)='1' else
--               data_in(7 downto 0)&current_mem(23 downto 0)  when EcrireMem_B='1' and address(0)='1' and address(1)='1' else
--               (others => 'X');
-- end architecture;
              
-- -------------------------------------------------------

-- -- Memory

-- LIBRARY IEEE;
-- USE IEEE.STD_LOGIC_1164.ALL;
-- USE IEEE.NUMERIC_STD.ALL;



-- entity memory is
--   port(
--     address : in std_logic_vector(31 downto 0);
--     CS, WE, OE, CLK : in std_logic;
--     LireMem_W, LireMem_UB, LireMem_SB, LireMem_UH, LireMem_SH : in std_logic;
--     EcrireMem_W, EcrireMem_H, EcrireMem_B : std_logic;
--     data_in : in std_logic_vector(31 downto 0);
--     init: in std_logic;
--     data_out : out std_logic_vector(31 downto 0)
--     );
-- end entity;

-- architecture arch_memory of memory is
--   TYPE memory_array IS ARRAY(NATURAL RANGE<>) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
--   signal mem : memory_array(0 to 2047); -- 64KBytes
--   signal output_sig, s_addr : STD_LOGIC_VECTOR(31 downto 0);
--   signal word : std_logic_vector(31 downto 0);
--   signal to_write : std_logic_vector(31 downto 0);
-- begin
  
  
--   --Reading from memory
--   data_out <= (others=> 'Z') when CS = '1' or OE = '1' else
--               (others=> '0') when  WE = '0' else
--               (others=> 'X') when (to_integer(unsigned(s_addr)) > 2047) else
--               output_sig;
--   s_addr <= "00"&address(31 downto 2);
--   word <= mem(to_integer(unsigned(s_addr)));
--   memRdCtrl : entity work.ReadPort
--     port map(word, address, LireMem_W, LireMem_UB, LireMem_SB, LireMem_UH, LireMem_SH, output_sig);

--   memWrCtrl : entity work.WritePort
--     port map(address, data_in, word, EcrireMem_W, EcrireMem_H, EcrireMem_B, to_write);
--   --Writing to memory
--   process(CLK, init)
--     variable addr : integer := to_integer(unsigned(address(31 downto 2)));

--   begin
--     if(init='1') then -- initialize memory
--       mem(0) <= "00000000000000000000000000000000";
--       mem(1) <= "00000000000000000000000000000001";
--       mem(2) <= "00000000000000000000000000000011";
--       mem(3) <= "00000000000000000000000000000100";
--       mem(4) <= "00000000000000000000000000000101";
--       mem(5) <= "00000000000000000000000000000110";
--       mem(6) <= "00000000000000000000000000000111";
--       mem(7) <= "00000000000000000000000000001000";
--       mem(8) <= "00000000000000000000000000001001";
--       mem(9) <= "00000000000000000000000000001010";
--       mem(10) <= "00000000000000000000000000001011";
--       mem(11) <= "00000000000000000000000000001100";
--       mem(12) <= "00000000000000000000000000001101";
--       mem(13) <= "00000000000000000000000000001110";
--       mem(14) <= "00000000000000000000000000001111";
--       mem(15) <= "00000000000000000000000000010000";
--       mem(16) <= "00000000000000000000000000010001";
--       mem(17) <= "00000000000000000000000000010010";
--       mem(18) <= "00000000000000000000000000010011";
--       mem(19) <= "00000000000000000000000000010100";
--       mem(20) <= "00000000000000000000000000010101";
--       else
--         if(rising_edge(CLK) and WE = '0' and CS = '0') then
--           mem(addr) <= to_write;
--         end if;
--       end if; 
--   end process;
-- end architecture;





