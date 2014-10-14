----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Brenton Milne
-- 
-- Create Date:    21:35:23 10/04/2014 
-- Design Name: 
-- Module Name:    rasterizer - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: Top level rasterizer unit that defines interactions with other
--              components.
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
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity rasterizer is
    -- This unit wraps the rasterizer_iterator to provide the interface seen to
    -- other units in the system (inputgenerator and outputrenderer).
    -- It has little function other than decoupling

    Port ( 
        clk : in STD_LOGIC;
        -- Signals to Input Generator
        t1x : in  UNSIGNED (9 downto 0);
        t1y : in  UNSIGNED (9 downto 0);
        t2x : in  UNSIGNED (9 downto 0);
        t2y : in  UNSIGNED (9 downto 0);
        t3x : in  UNSIGNED (9 downto 0);
        t3y : in  UNSIGNED (9 downto 0);
        start_raster    : in   STD_LOGIC;
        rasterizer_busy : out  STD_LOGIC;
        -- Signals to Output Renderer	  
        frag_x : out  UNSIGNED (9 downto 0);
        frag_y : out  UNSIGNED (9 downto 0);
        start_read    : out  STD_LOGIC;
        renderer_busy : in   STD_LOGIC
    );
end rasterizer;


architecture Behavioral of rasterizer is
    type STATE_TYPE is (idle, starting, running, output_ready, output_hold);
    signal state : STATE_TYPE := idle;
    signal frag_ready : STD_LOGIC;
    signal iter_complete : STD_LOGIC;
    signal continue_iter : STD_LOGIC;
    signal reset_iter : STD_LOGIC;
    
    component raster_iterator
    port (
        clk   : in STD_LOGIC;
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
        continue : in  STD_LOGIC
    );
    end component;
    
begin
    raster_iterator : raster_iterator
    port map (
        clk => clk,
        reset_iter => reset,
        t1x => t1x,
        t1y => t1y,
        t2x => t2x,
        t2y => t2y,
        t3x => t3x,
        t3y => t3y,
        frag_x => frag_x,
        frag_y => frag_y,
        frag_ready => frag_out,
        iter_complete => complete,
        continue_iter => continue
    );
    
    process (clk)
    begin
        if clk'event and clk = '1' then
            case state is
            
                when idle =>
                    if start_raster = '1' then
                        state <= starting;
                    end if;
                    
                when starting =>
                    if start_raster = '0' then
                        state <= running;
                    end if;
                    
                when running =>
                    if frag_ready = '1' then
                        state <= output_ready;
                    elsif iter_complete = '1' then
                        state <= idle;
                    end if;
                    
                when output_ready =>
                    if renderer_busy = '1' then
                        state <= output_hold;
                    end if;
                    
                when output_hold =>
                    if renderer_busy = '0' then
                        state <= running;
                    end if;
                    
                when others => null;
            end case;
        end if;
    end process;
    
    rasterizer_busy <= '0' when state = idle else '1';
    continue_iter <= '1' when state = running else '0';
    reset_iter <= '1' when state = idle else '0';
    

end Behavioral;

