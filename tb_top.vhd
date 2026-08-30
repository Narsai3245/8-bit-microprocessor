library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_top is
end tb_top;

architecture sim of tb_top is
  -- DUT signals
  signal clk    : std_logic := '0';
  signal resetn : std_logic := '0';       -- active-low
  signal w      : std_logic := '0';
  signal IR_in  : std_logic_vector(5 downto 0) := (others => '0');
  signal IN_sw  : std_logic_vector(7 downto 0) := (others => '0');
  signal seg    : std_logic_vector(6 downto 0);
  signal an     : std_logic_vector(7 downto 0);

  constant Tclk : time := 10 ns;

  -- Opcodes (IR[5:2]) (these are what we will be testing in simulation
  constant OP_LDI   : std_logic_vector(3 downto 0) := "0000"; -- LDI Rx : Rx<=IN
  constant OP_INC_A : std_logic_vector(3 downto 0) := "0001"; -- Rx<=A+1
  constant OP_ADD   : std_logic_vector(3 downto 0) := "0110"; -- Rx<=A+B
  constant OP_MOV_B : std_logic_vector(3 downto 0) := "0011"; -- Rx<=B (=Ry)

  -- Constants that represent how many clock cycles each FSM Path takes
  constant CYC_LDI_RUN : integer := 4;  -- CAPTURE_IN -> LOAD_IN_TO_RX -> COMPLETE -> back to IDLE (takes 4 clock cycles).
  constant CYC_ALU_RUN : integer := 5;  -- LOAD_A -> EXEC1 -> WRITEBK -> COMPLETE -> back to IDLE  (takes 5 clock cycles).

  -- function for constructing a IR value. Will require less typing.
  function mk_ir(op: std_logic_vector(3 downto 0);
                 Ry: std_logic;  -- 0=R0, 1=R1
                 Rx: std_logic   -- 0=R0, 1=R1
                ) return std_logic_vector is
    variable v : std_logic_vector(5 downto 0);
  begin
    v(5 downto 2) := op;
    v(1) := Ry;
    v(0) := Rx;
    return v;
  end function;

  -- Wait n rising edgeds. This is useful fo making sure we pulse w at the right time and give enough time for an instruction to complete).
  procedure tick(n : in integer) is
  begin
    for i in 1 to n loop
      wait until rising_edge(clk);
    end loop;
  end procedure;

begin
  -- Clock
  clk <= not clk after Tclk/2;

  -- DUT
  uut: entity work.top
    port map (
      clk    => clk,
      resetn => resetn,
      w      => w,
      IR_in  => IR_in,
      IN_sw  => IN_sw,
      seg    => seg,
      an     => an
    );

  -- Stimulus
  stim: process
  begin
    -- Reset
    resetn <= '0';
    w      <= '0';
    IR_in  <= (others => '0');
    IN_sw  <= (others => '0');
    tick(6);
    resetn <= '1';
    tick(2);

    -- 1) LDI R0 <= 0x0A
    IN_sw <= x"0A";
    IR_in <= mk_ir(OP_LDI, '0', '0');  -- Ry don't care
    tick(1);
    w <= '1'; tick(1); w <= '0'; -- pulse w for one clock cycle
    tick(CYC_LDI_RUN);

    -- 2) LDI R1 <= 0x05
    IN_sw <= x"05";
    IR_in <= mk_ir(OP_LDI, '0', '1');
    tick(1);
    w <= '1'; tick(1); w <= '0';
    tick(CYC_LDI_RUN);

    -- 3) R0 <= R0 + R1 (ADD, Ry=1, Rx=0)  expect R0 = 0x0F
    IR_in <= mk_ir(OP_ADD, '1', '0');
    tick(1);
    w <= '1'; tick(1); w <= '0';
    tick(CYC_ALU_RUN);

    -- 4) INC_A R0 (Rx=0)  expect R0 = 0x10
    IR_in <= mk_ir(OP_INC_A, '0', '0');  -- Ry ignored
    tick(2); --wait for 2 ticks this time around. We had to adjust this due to timing issues. w was not being pulsed during IDLE waiting a bit longer fixed it.
    w <= '1'; tick(1); w <= '0';
    tick(CYC_ALU_RUN);

    -- 5) MOV_B R1,R0 (copy R0 into R1) using Y<=B; expect R1 = 0x10
    IR_in <= mk_ir(OP_MOV_B, '0', '1');  -- from R0 (Ry=0) to R1 (Rx=1)
    tick(2); --same here
    w <= '1'; tick(1); w <= '0';
    tick(CYC_ALU_RUN);

    wait;
  end process;
end sim;
