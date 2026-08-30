library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu8 is
  port (
    A      : in  std_logic_vector(7 downto 0);
    B      : in  std_logic_vector(7 downto 0);
    op     : in  std_logic_vector(3 downto 0);
    Y      : out std_logic_vector(7 downto 0)
   
  );
end entity;

architecture simplified of alu8 is
  signal Au, Bu : unsigned(7 downto 0);
begin
  Au <= unsigned(A);
  Bu <= unsigned(B);

  process(Au, Bu, op)
    variable yv : unsigned(7 downto 0);
  begin
    -- default
    yv := (others => '0');

    case op is
      when "0000" =>  -- Y <= A
        yv := Au;

      when "0001" =>  -- Y <= A + 1 (wraps naturally)
        yv := Au + 1;

      when "0010" =>  -- Y <= A - 1 (wraps naturally)
        yv := Au - 1;

      when "0011" =>  -- Y <= B
        yv := Bu;

      when "0100" =>  -- Y <= B + 1
        yv := Bu + 1;

      when "0101" =>  -- Y <= B - 1
        yv := Bu - 1;

      when "0110" =>  -- Y <= A + B
        yv := Au + Bu;

      when "0111" =>  -- Y <= A - B
        yv := Au - Bu;

      when "1000" =>  -- NOT A
        yv := not Au;

      when "1001" =>  -- NOT B
        yv := not Bu;

      when "1010" =>  -- AND
        yv := Au and Bu;

      when "1011" =>  -- NAND
        yv := not (Au and Bu);

      when "1100" =>  -- OR
        yv := Au or Bu;

      when "1101" =>  -- NOR
        yv := not (Au or Bu);

      when "1110" =>  -- XOR
        yv := Au xor Bu;

      when others =>  -- 1111: XNOR
        yv := not (Au xor Bu);
    end case;

    Y <= std_logic_vector(yv);

   
  end process;
end architecture;
