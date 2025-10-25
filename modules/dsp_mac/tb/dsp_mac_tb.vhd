--------------------------------------------------------------------------------
-- dsp_mac_tb
--------------------------------------------------------------------------------

library std;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library xbc;
context xbc.xbc_testbench_context;

library olo;
use olo.olo_base_pkg_logic.all;
use olo.olo_base_pkg_array.all;
use olo.olo_base_pkg_math.all;

entity dsp_mac_tb is
    generic (
        TEST_CASE_G : string := "demo";

        WIDTH_A_G : natural := 25;
        WIDTH_B_G : natural := 18;
        WIDTH_C_G : natural := 43;
        WIDTH_P_G : natural := 44
    );
end entity dsp_mac_tb;

architecture tb of dsp_mac_tb is

    constant T_C : time := 10 ns;


    ----------------------------------------------------------------------------
    -- DUT
    ----------------------------------------------------------------------------
    signal clk_i : std_logic;

    signal a_i : std_logic_vector(WIDTH_A_G - 1 downto 0);
    signal b_i : std_logic_vector(WIDTH_B_G - 1 downto 0);
    signal c_i : std_logic_vector(WIDTH_C_G - 1 downto 0);

    signal p_o : std_logic_vector(WIDTH_P_G - 1 downto 0);

    signal sel : std_logic;

begin

    ----------------------------------------------------------------------------
    -- DUT
    ----------------------------------------------------------------------------
    dut : entity work.dsp_mac
        generic map (
            WIDTH_A_G => WIDTH_A_G,
            WIDTH_B_G => WIDTH_B_G,
            WIDTH_C_G => WIDTH_C_G,
            WIDTH_P_G => WIDTH_P_G
        )
        port map (
            clk_i => clk_i,

            a_i => a_i,
            b_i => b_i,
            c_i => c_i,

            p_o => p_o
        );


    -- MUX
    c_i <= p_o(c_i'left downto 0) when sel = '1' else (others => '0');

    ----------------------------------------------------------------------------
    -- Clock process
    ----------------------------------------------------------------------------
    tb_clock(clk_i, T_C);

    ----------------------------------------------------------------------------
    -- Simulation process
    ----------------------------------------------------------------------------
    p_main : process is
    begin


        log_info("Initialize");
        sel <= '0';

        tb_clk_period(clk_i, 10);

        if (TEST_CASE_G = "demo") then
            --------------------------------------------------------------------
            log_info("Test Case: demo");
            for i in 0 to 32 - 1 loop

                a_i <= toUslv(1, a_i'length);
                b_i <= toUslv(1, b_i'length);

                tb_clk_period(clk_i);
                sel <= '1';
            end loop;

            sel <= '0';

            tb_clk_period(clk_i, 100);

            for i in 0 to 32 - 1 loop

                a_i <= toUslv(i mod 4, a_i'length);
                b_i <= toUslv(i mod 4, b_i'length);

                tb_clk_period(clk_i);
                sel <= '1';
            end loop;

            sel <= '0';

            tb_clk_period(clk_i, 100);

        end if;

        tb_finish;

    end process;

end architecture tb;