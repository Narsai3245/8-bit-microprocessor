----------------------------------------------------------------------------------
-- Module Name: FSM_Ser_2 - Behavioral
-- Purpose    : FSM for 2-digit 7-seg serializer.
-- States     : S1 (clear), S2 (digit 0), S3 (digit 1)
-- Handshakes : "done" moves S1->S2 once; subsequent E pulses toggle S2<->S3.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FSM_Ser_2 is
  Port (
    resetn : in  std_logic;
    clock  : in  std_logic;
    done   : in  std_logic;
    E      : in  std_logic;
    sclrc  : out std_logic;
    sel    : out std_logic_vector(1 downto 0)
  );
end FSM_Ser_2;

architecture Behavioral of FSM_Ser_2 is
  type state_t is (S1, S2, S3);
  signal y : state_t;
begin
  -- Transitions
  process(resetn, clock)
  begin
    if resetn = '0' then
      y <= S1;
    elsif rising_edge(clock) then
      case y is
        when S1 =>
          if done = '1' then y <= S2; else y <= S1; end if;
        when S2 =>
          if E = '1' then y <= S3; else y <= S2; end if;
        when S3 =>
          if E = '1' then y <= S2; else y <= S3; end if;
      end case;
    end if;
  end process;

  -- Outputs
  process(y)
  begin
    sclrc <= '0';
    sel   <= "11"; -- default: none selected
    case y is
      when S1 => sclrc <= '1';           -- clear the divider/counter once
      when S2 => sel   <= "00";          -- digit 0
      when S3 => sel   <= "01";          -- digit 1
    end case;
  end process;
end Behavioral;
