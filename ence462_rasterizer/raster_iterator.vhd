----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Brenton Milne
-- 
-- Create Date:    11:50:02 10/13/2014 
-- Design Name: 
-- Module Name:    raster_iterator - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: Calculates a bounding box for the triangle then iterates over
--              each pixel running a hit test and outputting its coords if hit.
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity raster_iterator is
    Port ( clk   : in  STD_LOGIC;
           reset : in STD_LOGIC;
    
           t1x : in  UNSIGNED (9 downto 0);
           t1y : in  UNSIGNED (9 downto 0);
           t2x : in  UNSIGNED (9 downto 0);
           t2y : in  UNSIGNED (9 downto 0);
           t3x : in  UNSIGNED (9 downto 0);
           t3y : in  UNSIGNED (9 downto 0);
           
           frag_x : out  UNSIGNED (9 downto 0);
           frag_y : out  UNSIGNED (9 downto 0);
           frag_out : out  STD_LOGIC;
           complete : out STD_LOGIC;
           continue : in  STD_LOGIC);
end raster_iterator;

architecture Behavioral of raster_iterator is
    type STATE_TYPE is (
        idle, 
        compute_bounds,
        init_hit_tester,
        wait_hit_test_init,
        hit_test,
        wait_hit_test_calc,
        next_frag,
        output_ready,
        output_hold
    );
    signal state : STATE_TYPE := idle;
    signal start_x : UNSIGNED (9 downto 0);
    signal start_y : UNSIGNED (9 downto 0);
    signal end_x   : UNSIGNED (9 downto 0);
    signal end_y   : UNSIGNED (9 downto 0);
    
    signal start_hit_test_init : STD_LOGIC;
    signal start_hit_test : STD_LOGIC;
    signal hit_test_ready : STD_LOGIC;
    signal hit_test_result : STD_LOGIC;
    
    component raster_hit_tester
    port ( clk : in STD_LOGIC;
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
           run_test : in STD_LOGIC;
           result : out  STD_LOGIC);
    end component;
    
begin

    raster_hit_tester : raster_hit_tester
    port map (
        clk => clk,
        t1x => t1x,
        t1y => t1y,
        t2x => t2x,
        t2y => t2y,
        t3x => t3x,
        t3y => t3y,
        start_hit_test_init => init,
        hit_test_ready => ready,
        frag_x => test_x,
        frag_y => test_y,
        start_hit_test => run_test,
        hit_test_result => result
    );

    process (clk)
    
        function min3(a : UNSIGNED (9 downto 0);
                      b : UNSIGNED (9 downto 0);
                      c : UNSIGNED (9 downto 0)) return UNSIGNED (9 downto 0) is
        begin
            if a < b and a < c then return a;
            elsif b < a and b < c then return b;
            else return c;
            end if;
        end function min3;
        
        function max3(a : UNSIGNED (9 downto 0);
                      b : UNSIGNED (9 downto 0);
                      c : UNSIGNED (9 downto 0)) return UNSIGNED (9 downto 0) is
        begin
            if a > b and a > c then return a;
            elsif b > a and b > c then return b;
            else return c;
            end if;
        end function max3;
        
    begin
        if clk'event and clk = '1' then
            case state is
            
                when idle =>
                    frag_x <= "0000000000";
                    frag_y <= "0000000000";
                    if continue = '1' then
                        state <= compute_bounds;
                    end if;
                    
                when compute_bounds =>
                    start_x <= min3(t1x, t2x, t3x);
                    start_y <= min3(t1y, t2y, t3y);
                    end_x <= max3(t1x, t2x, t3x);
                    end_y <= max3(t1y, t2y, t3y);
                    state <= init_hit_tester;
                    
                when init_hit_tester =>
                    frag_x <= start_x;
                    cur_y <= start_y;
                    assert 0 <= start_x and start_x < "1111111111"; -- Todo: change to resolution?
                    assert 0 <= start_y and start_y < "1111111111"; -- Todo: change to resolution?
                    if hit_test_ready = '0' then
                        state <= wait_hit_test_init;
                    end if;
                    
                when wait_hit_test_init =>
                    if hit_test_ready = '1' then
                        state <= hit_test;
                    end if;
                    
                when hit_test =>
                    assert start_x <= frag_x and start_y <= frag_y;
                    assert end_x >= frag_x and end_y >= frag_y;
                    if hit_test_ready = '0' then
                        state <= wait_hit_test_calc;
                    end if;
                    
                when wait_hit_test_calc =>
                    if hit_test_ready = '1' and hit_test_result = '1' then
                        state <= output_ready;
                    elsif hit_test_ready = '1' and hit_test_result = '0' then
                        state <= next_frag;
                    end if;
                    
                when next_frag =>
                    if frag_y > end_y then
                        state <= finished;
                    else
                        state <= hit_test;
                    end if;
                    if frag_x > end_x then
                        frag_x <= start_x;
                        frag_y <= frag_y + 1;
                    else
                        frag_x <= frag_x + 1;
                    end if;
                    
                when output_ready =>
                    if continue = '0' then
                        state <= output_hold;
                    end if;
                    
                when output_hold =>
                    if continue = '1' then
                        state <= next_frag;
                    end if;
                
                when finished =>
                    if reset = '1' then
                        state <= idle;
                    end if;
                    
                when others => null;
            end case;
        end if;
    end process;
    
    frag_out <= '1' when state = output_ready else '0';
    complete <= '1' when state = finished else '0';
    start_hit_test_init <= '1' when state = init_hit_tester else '0';
    start_hit_test <= '1' when state = hit_test else '0';

end Behavioral;

