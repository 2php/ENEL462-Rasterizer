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


entity line_sign_checker is
    -- This entity tests whether a point lies on the inside of a line.
    -- When init is high, it will recalculate the constants it needs for the
    -- calculation based on the two line points input. When init is low, it
    -- will calculate the result (whether the point test_x, test_y is inside
    -- the line) every clock cycle.
    -- Note that init may need more than one cycle - unsure.
    
    Port ( clk : in STD_LOGIC;
           p1x, p1y, p2x, p2y : in UNSIGNED (9 downto 0);
           test_x, test_y : in UNSIGNED (9 downto 0);
           init : in STD_LOGIC;
           result : out STD_LOGIC);
end line_sign_checker;


architecture Behavioural of line_sign_checker is
    
    signal a, b, c : SIGNED (20 downto 0);
    signal p1x2, p1y2, p2x2, p2y2, test_x2, test_y2 : UNSIGNED (20 downto 0);
    signal dist : SIGNED (20 downto 0);
    
begin
    
    process (clk)
    begin
        if clk'event and clk = '1' then
            if init = '1' then -- Note: this may take more than one clock cycle?
                -- set constants
                b <= signed(p2x2) - signed(p1x2);
                a <= signed(p1y2) - signed(p2y2);
                c <= b * signed(p2y2) + a * signed(p2x2);
            else
                -- calc result
                dist <= a * signed(test_x2) + b * signed(test_y2);
                if dist >= c then
                    result <= '1';
                else
                    result <= '0';
                end if;
            end if;
        end if;
    end process;
    
    p1x2 <= resize(unsigned(p1x), 21); -- Convert to 21 bits signed
    p1y2 <= resize(unsigned(p1y), 21);
    p2x2 <= resize(unsigned(p2x), 21);
    p2y2 <= resize(unsigned(p2y), 21);
    test_x2 <= resize(unsigned(test_x), 21);
    test_y2 <= resize(unsigned(test_y), 21);
    
end Behavioural;
            

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use WORK.ALL;


entity raster_hit_tester is
    -- This entity combines three line testing entities to provide a containment
    -- test for a triangle. It has an init state where it allows the line test
    -- entities to calculate their constants, then a calculation state where it
    -- generates a result, and an idle state where the result can be read and inputs
    -- can be changed.
    
    Port ( clk : in STD_LOGIC;
           t1x, t1y, t2x, t2y, t3x, t3y : in  UNSIGNED (9 downto 0);
           setup : in  STD_LOGIC;
           ready : out  STD_LOGIC;
           test_x, test_y : in  UNSIGNED (9 downto 0);
           run_test : in STD_LOGIC;
           result : out  STD_LOGIC);
end raster_hit_tester;

architecture Behavioral of raster_hit_tester is
    type STATE_TYPE is (idle, calc, init);
    signal state : STATE_TYPE := idle;
    signal init_sign_checkers : STD_LOGIC;
    signal res0, res1, res2 : STD_LOGIC;
    
    component line_sign_checker
        Port ( clk : in STD_LOGIC;
               p1x, p1y, p2x, p2y : in UNSIGNED (9 downto 0);
               test_x, test_y : in UNSIGNED (9 downto 0);
               init : in STD_LOGIC;
               result : out STD_LOGIC);
    end component;
    
begin

    LineTest0: line_sign_checker port map (
        clk, t1x, t1y, t2x, t2y, test_x, test_y, init_sign_checkers, res0
    );
    
    LineTest1: line_sign_checker port map (
        clk, t2x, t2y, t3x, t3y, test_x, test_y, init_sign_checkers, res1
    );
    
    LineTest2: line_sign_checker port map (
        clk, t3x, t3y, t1x, t1y, test_x, test_y, init_sign_checkers, res2
    );
    
    process (clk)
    begin
        if clk'event and clk = '1' then
            case state is
            
                when idle =>
                    if setup = '1' then
                        state <= init;
                    elsif run_test = '1' then
                        state <= calc;
                    end if;
                    
                when calc =>
                    state <= idle; -- I expect this to finish within one cycle
                    
                when init =>
                    state <= idle; -- Hopefully this finishes in one cycle, else may need counter
                
                when others => null;
            end case;
        end if;
    end process;
    
    ready <= '1' when state = idle else '0';
    init_sign_checkers <= '1' when state = init else '0';
    result <= '1' when (res0 = '1' and res1 = '1' and res2 = '1') else '0'; -- TODO: check that this is not inverted

end Behavioral;

