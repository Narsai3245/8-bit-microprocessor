----------------------------------------------------------------------------------
-- Module Name: serializer_2disp - Behavioral
-- Purpose    : Time-multiplex two hex nibbles across two 7-seg digits (active-low).
-- Notes      : Exposes 8-bit AN so it can plug into Nexys A7 XDC directly.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.math_real.log2;
use ieee.math_real.ceil;

entity serializer_2disp is
  port (
    resetn : in  std_logic;
    clock  : in  std_logic;
    done   : in  std_logic;                         -- one-shot "start" (can be tied high)
    A      : in  std_logic_vector (3 downto 0);     -- right-most digit
    B      : in  std_logic_vector (3 downto 0);     -- next digit to the left
    segs   : out std_logic_vector (6 downto 0);     -- active-low segments a..g
    AN     : out std_logic_vector (7 downto 0)      -- active-low enables AN7..AN0
  );
end serializer_2disp;

architecture Behavioral of serializer_2disp is
  component my_genpulse_sclr
    generic (COUNT: INTEGER:= (10**5)); -- ~1 kHz on 100 MHz for comfortable refresh
    port (
      clock : in  std_logic;
      resetn: in  std_logic;
      E     : in  std_logic;
      sclr  : in  std_logic;
      Q     : out std_logic_vector ( integer(ceil(log2(real(COUNT)))) - 1 downto 0);
      z     : out std_logic
    );
  end component;

  component hex2sevenseg
    port ( hex  : in  std_logic_vector (3 downto 0);
           leds : out std_logic_vector (6 downto 0) );  -- active-high a..g
  end component;

  component MUX2_1
    Port ( A, B : in  std_logic_vector(3 downto 0);
           s    : in  std_logic_vector(1 downto 0);
           omux : out std_logic_vector(3 downto 0) );
  end component;

  component Dec2_2
    Port ( s   : in  std_logic_vector(1 downto 0);
           buf : out std_logic_vector(1 downto 0) );
  end component;

  component FSM_Ser_2
    Port ( resetn, clock, done, E : in std_logic;
           sclrc: out std_logic;
           sel  : out std_logic_vector(1 downto 0) );
  end component;

  signal s     : std_logic_vector(1 downto 0);
  signal nib   : std_logic_vector(3 downto 0);
  signal leds  : std_logic_vector(6 downto 0);
  signal buf2  : std_logic_vector(1 downto 0);
  signal z     : std_logic;         -- pulse from divider
  signal dummy : std_logic_vector(integer(ceil(log2(real(10**5)))) - 1 downto 0);
  signal sclrc : std_logic;
begin
  -- Refresh pulse generator (~1 kHz) - gate with 'E'='1' (always enabled here).
  gp: my_genpulse_sclr
    generic map (COUNT => 10**5)
    port map (
      clock  => clock,
      resetn => resetn,
      E      => '1',
      sclr   => sclrc,
      Q      => dummy,
      z      => z
    );

  -- FSM to step between the two digits on each 'z' pulse
  fsm: FSM_Ser_2
    port map (
      clock  => clock,
      resetn => resetn,
      done   => done,
      E      => z,
      sclrc  => sclrc,
      sel    => s
    );

  -- Select nibble and encode to segments (active-high a..g), then invert to active-low
  mux: MUX2_1 port map (A => A, B => B, s => s, omux => nib);
  enc: hex2sevenseg port map (hex => nib, leds => leds);
  segs <= not leds;

  -- Drive only AN0 and AN1; others inactive high
  dec: Dec2_2 port map (s => s, buf => buf2);
  AN <= "111111" & buf2;
end Behavioral;
