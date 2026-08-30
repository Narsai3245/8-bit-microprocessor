library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity control_unit is
  port (
    clk     : in  std_logic;
    resetn  : in  std_logic;  -- active-low
    -- step/execute: pulse 'w' while in IDLE to latch IR_in and start
    w       : in  std_logic;

    -- 6-bit instruction from switches: [5:2]=op, [1]=Ry, [0]=Rx
    IR_in   : in  std_logic_vector(5 downto 0);

    -- datapath control outputs
    SM      : out std_logic_vector(1 downto 0); -- 00=IN, 01=G, 10=R0, 11=R1
    E_IN    : out std_logic;                    -- IN <= IN_sw
    E_R0    : out std_logic;                    -- R0 <= bus
    E_R1    : out std_logic;                    -- R1 <= bus
    E_A     : out std_logic;                    -- A  <= bus
    E_G     : out std_logic;                    -- G  <= ALU.Y
    E_OUT   : out std_logic;                    -- OUT<= bus
    op      : out std_logic_vector(3 downto 0); -- ALU opcode
    done    : out std_logic                     -- one-cycle pulse in COMPLETE
  );
end control_unit;

architecture rtl of control_unit is

  -- Instruction register (latched in IDLE when w='1')
  signal IRq  : std_logic_vector(5 downto 0) := (others => '0');
  signal op_q : std_logic_vector(3 downto 0);
  signal Ry_q : std_logic;
  signal Rx_q : std_logic;

  -- Bus source selects
  constant SM_IN  : std_logic_vector(1 downto 0) := "00";
  constant SM_G   : std_logic_vector(1 downto 0) := "01";
  constant SM_R0  : std_logic_vector(1 downto 0) := "10";
  constant SM_R1  : std_logic_vector(1 downto 0) := "11";

  -- FSM States for LDI path and ALU path.
  type state_t is (
    IDLE,
    -- LDI path
    CAPTURE_IN,            -- E_IN=1
    LOAD_IN_TO_RX,         -- SM=IN,  E_Rx=1
    -- ALU path
    LOAD_A,                -- SM=Rx,  E_A=1
    EXEC1,                 -- SM=Ry,  E_G=1
    WRITEBK,               -- SM=G,   E_Rx=1
    COMPLETE               -- SM=Rx,  E_OUT=1, done=1
  );
  signal state : state_t := IDLE;

begin
 
  -- Extract instuction (comes from switches)
  op_q <= IRq(5 downto 2);
  Ry_q <= IRq(1);
  Rx_q <= IRq(0);

  -- Drive ALU opcode continuously from latched IR
  op   <= op_q;

 
  -- State register & IR latch (single clocked process)
  process(clk, resetn)
  begin
    if resetn = '0' then
      state <= IDLE;
      IRq   <= (others => '0');

    elsif rising_edge(clk) then
      case state is
        when IDLE =>
          -- Latch the instruction and branch based on opcode
          if w = '1' then
            IRq <= IR_in;
            if IR_in(5 downto 2) = "0000" then
              state <= CAPTURE_IN;   -- LDI Rx Path
            else
              state <= LOAD_A;       -- ALU Path
            end if;
          end if;

        -- LDI (IN -> Rx)
        when CAPTURE_IN    => state <= LOAD_IN_TO_RX;
        when LOAD_IN_TO_RX => state <= COMPLETE;

        -- ALU
        when LOAD_A  => state <= EXEC1;
        when EXEC1   => state <= WRITEBK;
        when WRITEBK => state <= COMPLETE;

        when COMPLETE => state <= IDLE;
        when others   => state <= IDLE;
      end case;
    end if;
  end process;

  
  -- Output decode, which are combinational Moore outputs from the current state.
  process(state, Rx_q, Ry_q)
  begin
    -- defaults
    SM    <= SM_IN;
    E_IN  <= '0';
    E_R0  <= '0';
    E_R1  <= '0';
    E_A   <= '0';
    E_G   <= '0';
    E_OUT <= '0';
    done  <= '0';

    case state is
      -- LDI path
      when CAPTURE_IN =>
        E_IN <= '1';                       -- IN <= switches this cycle

      when LOAD_IN_TO_RX =>
        SM <= SM_IN;                       -- bus = IN
        if Rx_q = '0' then E_R0 <= '1'; else E_R1 <= '1'; end if;

      -- ALU path
      when LOAD_A =>
        if Rx_q = '0' then SM <= SM_R0; else SM <= SM_R1; end if;  -- bus = Rx
        E_A <= '1';                                                -- A <= bus

      when EXEC1 =>
        if Ry_q = '0' then SM <= SM_R0; else SM <= SM_R1; end if;  -- bus = Ry
        E_G <= '1';                                                -- G <= ALU(A,bus)

      when WRITEBK =>
        SM <= SM_G;                                                -- bus = G
        if Rx_q = '0' then E_R0 <= '1'; else E_R1 <= '1'; end if;  -- Rx <= G

      when COMPLETE =>
        -- Present destination register on the bus and show it on OUT
        if Rx_q = '0' then SM <= SM_R0; else SM <= SM_R1; end if;
        E_OUT <= '1';
        done  <= '1';

      when others =>
        null;
    end case;
  end process;

end rtl;
