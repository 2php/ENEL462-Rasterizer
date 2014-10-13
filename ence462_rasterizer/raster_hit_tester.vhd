----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:58:35 10/13/2014 
-- Design Name: 
-- Module Name:    raster_hit_tester - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: Performs the actual hit test for a given set of coordinates and
--              triangle vertices
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity raster_hit_tester is
    Port ( clk : in STD_LOGIC;
           t1x : in  UNSIGNED (9 downto 0);
           t1y : in  UNSIGNED (9 downto 0);
           t2x : in  UNSIGNED (9 downto 0);
           t2y : in  UNSIGNED (9 downto 0);
           t3x : in  UNSIGNED (9 downto 0);
           t3y : in  UNSIGNED (9 downto 0);
           init : in  STD_LOGIC;
           ready : out  STD_LOGIC;
           test_x : in  UNSIGNED (9 downto 0);
           test_y : in  UNSIGNED (9 downto 0);
           result : out  STD_LOGIC);
end raster_hit_tester;

architecture Behavioral of raster_hit_tester is
    type STATE_TYPE is (idle, calc, init);
    signal state : STATE_TYPE := idle;
begin
    
    process (clk)
    begin
        if clk'event and clk = '1' then
            case state is
                when idle =>
                when calc =>
                when init =>
                when others => null;
            end case;
        end if;
    end process;
    
    ready <= '1' when state = idle else '0';

end Behavioral;

