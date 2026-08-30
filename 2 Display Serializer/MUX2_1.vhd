----------------------------------------------------------------------------------
-- Module Name: MUX2_1 - Behavioral
-- Purpose    : 2-input nibble multiplexer for 7-seg serializer (A/B select).
-- Notes      : Use "0000" for others to avoid '----'/X propagation into the decoder.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MUX2_1 is
  Port (
    A    : in  std_logic_vector(3 downto 0);
    B    : in  std_logic_vector(3 downto 0);
    s    : in  std_logic_vector(1 downto 0);
    omux : out std_logic_vector(3 downto 0)
  );
end MUX2_1;

architecture Behavioral of MUX2_1 is
begin
  with s select
    omux <= A     when "00",
            B     when "01",
            "0000" when others;  -- blank/known safe
end Behavioral;
