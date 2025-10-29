--------------------------------------------------------------------------------
-- dsp_mac
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Libraries
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity dsp_mac is
    generic (
        WIDTH_A_G : natural := 16;
        WIDTH_B_G : natural := 16;
        WIDTH_C_G : natural := 36;
        WIDTH_P_G : natural := 37
    );
    port (
        clk_i : in  std_logic;
        a_i   : in  std_logic_vector(WIDTH_A_G - 1 downto 0);
        b_i   : in  std_logic_vector(WIDTH_B_G - 1 downto 0);
        c_i   : in  std_logic_vector(WIDTH_C_G - 1 downto 0);
        p_o   : out std_logic_vector(WIDTH_P_G - 1 downto 0)
    );
end entity dsp_mac;

architecture rtl of dsp_mac is

begin
    process(clk_i)
    begin
        if rising_edge(clk_i) then
            p_o <= std_logic_vector(resize(unsigned(a_i) * unsigned(b_i), WIDTH_A_G + WIDTH_B_G) + resize(unsigned(c_i), WIDTH_P_G));
        end if;
    end process;
end architecture rtl;
