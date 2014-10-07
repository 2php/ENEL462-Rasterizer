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
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity rasterizer is
    Port ( 
        -- Signals to Input Generator
        tri_coords      : in   STD_LOGIC_VECTOR (19 downto 0);
        start_raster    : in   STD_LOGIC;
        rasterizer_busy : out  STD_LOGIC;
        -- Signals to Output Renderer	  
        frag_coords   : out  STD_LOGIC_VECTOR (19 downto 0);
        start_read    : out  STD_LOGIC;
        renderer_busy : in STD_LOGIC
    );
end rasterizer;


architecture Behavioral of rasterizer is
begin


end Behavioral;

