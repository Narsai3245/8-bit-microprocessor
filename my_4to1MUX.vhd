----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/10/2025 09:52:40 PM
-- Design Name: 
-- Module Name: my_4to1MUX - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mux4to1_8bit is
    Port (
        sel : in  STD_LOGIC_VECTOR(1 downto 0);
        in0 : in  STD_LOGIC_VECTOR(7 downto 0);
        in1 : in  STD_LOGIC_VECTOR(7 downto 0);
        in2 : in  STD_LOGIC_VECTOR(7 downto 0);
        in3 : in  STD_LOGIC_VECTOR(7 downto 0);
        y   : out STD_LOGIC_VECTOR(7 downto 0)
    );
end mux4to1_8bit;

architecture Behavioral of mux4to1_8bit is
begin
    process(sel, in0, in1, in2, in3)
    begin
        case sel is
            when "00" => y <= in0;
            when "01" => y <= in1;
            when "10" => y <= in2;
            when "11" => y <= in3;
            when others => y <= (others => '0');
        end case;
    end process;
end Behavioral;