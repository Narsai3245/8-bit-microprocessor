----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/10/2025 10:31:01 PM
-- Design Name: 
-- Module Name: top - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top is
  port(
    clk     : in  std_logic;
    resetn  : in  std_logic;
    w       : in  std_logic;
    IR_in   : in  std_logic_vector(5 downto 0);
    IN_sw   : in  std_logic_vector(7 downto 0);
    seg     : out std_logic_vector(6 downto 0);  -- CA..CG (active-low)
    an      : out std_logic_vector(7 downto 0)   -- AN7..AN0 (active-low)
  );
end top;
architecture Behavioral of top is

    component my_rege
        Port (
            clock  : in  STD_LOGIC;
            resetn : in  STD_LOGIC;
            E      : in  STD_LOGIC;
            sclr   : in  STD_LOGIC;
            D      : in  STD_LOGIC_VECTOR(7 downto 0);
            Q      : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;
    
    component mux4to1_8bit
        Port (
            sel : in  STD_LOGIC_VECTOR(1 downto 0);
            in0 : in  STD_LOGIC_VECTOR(7 downto 0);
            in1 : in  STD_LOGIC_VECTOR(7 downto 0);
            in2 : in  STD_LOGIC_VECTOR(7 downto 0);
            in3 : in  STD_LOGIC_VECTOR(7 downto 0);
            y   : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;
    
    component alu8
        Port (
            A      : in  STD_LOGIC_VECTOR(7 downto 0);
            B      : in  STD_LOGIC_VECTOR(7 downto 0);
            op     : in  STD_LOGIC_VECTOR(3 downto 0);
            Y      : out STD_LOGIC_VECTOR(7 downto 0)
           
        );
    end component;
    
    component control_unit
        Port (
            clk     : in  STD_LOGIC;
            resetn  : in  STD_LOGIC;
            w       : in  STD_LOGIC;
            IR_in   : in  STD_LOGIC_VECTOR(5 downto 0);
            SM      : out STD_LOGIC_VECTOR(1 downto 0);
            E_IN    : out STD_LOGIC;
            E_R0    : out STD_LOGIC;
            E_R1    : out STD_LOGIC;
            E_A     : out STD_LOGIC;
            E_G     : out STD_LOGIC;
            E_OUT   : out STD_LOGIC;
            op      : out STD_LOGIC_VECTOR(3 downto 0);
            done    : out STD_LOGIC
        );
    end component;
    
    --7-segment serializer, declare it here
     component serializer_2disp
    port (
      resetn : in  STD_LOGIC;
      clock  : in  STD_LOGIC;
      done   : in  STD_LOGIC;
      A      : in  STD_LOGIC_VECTOR (3 downto 0);
      B      : in  STD_LOGIC_VECTOR (3 downto 0);
      segs   : out STD_LOGIC_VECTOR (6 downto 0); -- active-low
      AN     : out STD_LOGIC_VECTOR (7 downto 0)  -- active-low
    );
  end component;
  
component mydebouncer  --Added a debouncer only used for bitstream generation.
  port (
    resetn : in  std_logic;
    clock  : in  std_logic;   
    w      : in  std_logic;   
    w_db   : out std_logic    
  );
  
  end component;

    -- Internal signals
    signal SM_sel     : STD_LOGIC_VECTOR(1 downto 0);
    signal E_IN, E_R0, E_R1, E_A, E_G, E_OUT : STD_LOGIC;
    signal op_code    : STD_LOGIC_VECTOR(3 downto 0);
    signal done       : STD_LOGIC;

    -- Data path signals
    signal IN_reg, R0_reg, R1_reg, A_reg, IRR_reg : STD_LOGIC_VECTOR(7 downto 0);
    signal data_bus      : STD_LOGIC_VECTOR(7 downto 0);
    signal alu_Y    : STD_LOGIC_VECTOR(7 downto 0);
    signal alu_Z, alu_C, alu_C_add, alu_B_sub : STD_LOGIC;
    
    -- display wiring
  signal OUT_reg : STD_LOGIC_VECTOR(7 downto 0);
  signal segs7   : STD_LOGIC_VECTOR(6 downto 0);
  signal AN8     : STD_LOGIC_VECTOR(7 downto 0);
  
signal w_db_sig, w_db_d, w_pulse : std_logic;

begin 

--W_DB: mydebouncer
  --port map (
    --resetn => resetn,
    --clock  => clk,
    --w      => w,        -- raw button
    --w_db   => w_db_sig  -- debounced level
  --);

--process(clk, resetn)
--begin
  --if resetn = '0' then
    --w_db_d  <= '0';
    --w_pulse <= '0';
  --elsif rising_edge(clk) then
    --w_db_d  <= w_db_sig;
--w_pulse <= w_db_sig and not w_db_d;  -- 1-cycle pulse on 0->1
  --end if;
--end process;


    CU: control_unit
        port map (
            clk     => clk,
            resetn  => resetn,
            w       => w,
            IR_in   => IR_in,
            SM      => SM_sel,
            E_IN    => E_IN,
            E_R0    => E_R0,
            E_R1    => E_R1,
            E_A     => E_A,
            E_G     => E_G,
            E_OUT   => E_OUT,
            op      => op_code,
            done    => done
        );
     
     INREG: my_rege
        port map (
            clock  => clk,
            resetn => resetn,
            E      => E_IN,
            sclr   => '0',
            D      => IN_sw,
            Q      => IN_reg
        );

    R0REG: my_rege
        port map (
            clock  => clk,
            resetn => resetn,
            E      => E_R0,
            sclr   => '0',
            D      => data_bus,
            Q      => R0_reg
        );

    R1REG: my_rege
        port map (
            clock  => clk,
            resetn => resetn,
            E      => E_R1,
            sclr   => '0',
            D      => data_bus,
            Q      => R1_reg
        );

    ACCREG: my_rege
        port map (
            clock  => clk,
            resetn => resetn,
            E      => E_A,
            sclr   => '0',
            D      => data_bus,
            Q      => A_reg
        );

    IRR: my_rege
        port map (
            clock  => clk,
            resetn => resetn,
            E      => E_G,
            sclr   => '0',
            D      => alu_Y,
            Q      => IRR_reg
        );
        
    OUTREG: my_rege
    port map (
      clock  => clk,
      resetn => resetn,
      E      => E_OUT,       
      sclr   => '0',
      D      => data_bus,    
      Q      => OUT_reg
    );
    
     MUX: mux4to1_8bit
        port map (
            sel => SM_sel,
            in0 => IN_reg,
            in1 => IRR_reg,
            in2 => R0_reg,
            in3 => R1_reg,
            y   => data_bus
        );
     ALU: alu8
        port map (
            A      => A_reg,
            B      => data_bus,
            op     => op_code,
            Y      => alu_Y
        );
        
        
        
    -- 7-Segment Dispaly
    DISP: serializer_2disp
    port map (
      resetn => resetn,
      clock  => clk,
      done   => done,              
      A      => OUT_reg(3 downto 0),
      B      => OUT_reg(7 downto 4),
      segs   => segs7,             -- active-low segments
      AN     => AN8                -- active-low digit enables
    );
    
   --Final wiring for seg
seg(0) <= segs7(6);  
seg(1) <= segs7(5); 
seg(2) <= segs7(4);  
seg(3) <= segs7(3); 
seg(4) <= segs7(2);  
seg(5) <= segs7(1);  
seg(6) <= segs7(0);  
an      <= AN8;       


end Behavioral;
