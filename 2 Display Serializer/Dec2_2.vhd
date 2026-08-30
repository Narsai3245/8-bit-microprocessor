----------------------------------------------------------------------------------
-- Module Name: Dec2_2 - Behavioral
-- Purpose    : 2:2 active-low decoder for two 7-seg digit enables.
--              "00" -> "10" (AN0 active), "01" -> "01" (AN1 active)
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Dec2_2 is
  Port (
    s   : in  std_logic_vector(1 downto 0);
    buf : out std_logic_vector(1 downto 0)  -- active-low enables
  );
end Dec2_2;

architecture Behavioral of Dec2_2 is
begin
  with s select
    buf <= "10" when "00",
           "01" when "01",
           "11" when others; -- none selected
end Behavioral;
