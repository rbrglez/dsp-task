--------------------------------------------------------------------------------
-- fix_dsp_mac_tb
--------------------------------------------------------------------------------

library std;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library xbc;
context xbc.xbc_testbench_context;

library olo;
use olo.olo_base_pkg_logic.all;
use olo.olo_base_pkg_array.all;
use olo.olo_base_pkg_math.all;
use olo.en_cl_fix_pkg.all;
use olo.olo_fix_pkg.all;

entity fix_dsp_mac_tb is
    generic (
        TEST_CASE_G : string := "demo";

        FMT_MULT_A_G : string := "(0, 2, 2)";
        FMT_MULT_B_G : string := "(0, 2, 2)";
        FMT_ADD_G    : string := "(0, 4, 4)";
        FMT_RESULT_G : string := "(0, 5, 4)"
    );
end entity fix_dsp_mac_tb;

architecture tb of fix_dsp_mac_tb is

    constant T_C : time := 10 ns;

    ----------------------------------------------------------------------------
    -- DUT
    ----------------------------------------------------------------------------
    signal clk_i : std_logic;
    signal rst_i : std_logic;

    signal in_valid_i  : std_logic;
    signal in_mult_a_i : std_logic_vector(fixFmtWidthFromString(FMT_MULT_A_G) - 1 downto 0);
    signal in_mult_b_i : std_logic_vector(fixFmtWidthFromString(FMT_MULT_B_G) - 1 downto 0);
    signal in_add_i    : std_logic_vector(fixFmtWidthFromString(FMT_ADD_G) - 1 downto 0);

    signal out_valid_o  : std_logic;
    signal out_result_o : std_logic_vector(fixFmtWidthFromString(FMT_RESULT_G) - 1 downto 0);

    signal sel : std_logic;

begin

    ----------------------------------------------------------------------------
    -- DUT
    ----------------------------------------------------------------------------
    dut : entity work.fix_dsp_mac
        generic map (
            FMT_MULT_A_G => FMT_MULT_A_G,
            FMT_MULT_B_G => FMT_MULT_B_G,
            FMT_ADD_G    => FMT_ADD_G,
            FMT_RESULT_G => FMT_RESULT_G
        )
        port map (
            clk_i => clk_i,
            rst_i => rst_i,

            in_valid_i  => in_valid_i,
            in_mult_a_i => in_mult_a_i,
            in_mult_b_i => in_mult_b_i,
            in_add_i    => in_add_i,

            out_valid_o  => out_valid_o,
            out_result_o => out_result_o
        );

    -- MUX
    in_add_i <= out_result_o(in_add_i'left downto 0) when sel = '1' else (in_add_i'range => '0');

    ----------------------------------------------------------------------------
    -- Clock process
    ----------------------------------------------------------------------------
    tb_clock(clk_i, T_C);

    ----------------------------------------------------------------------------
    -- Simulation process
    ----------------------------------------------------------------------------
    p_main : process is
    begin

        log_info("Reset DUT");
        rst_i <= '0';
        tb_clk_period(clk_i);
        rst_i <= '1';
        tb_clk_period(clk_i, 5);
        rst_i <= '0';
        tb_clk_period(clk_i, 10);

        log_info("Initialize");
        sel        <= '0';
        in_valid_i <= '0';

        tb_clk_period(clk_i, 10);

        if (TEST_CASE_G = "demo") then

            --------------------------------------------------------------------
            log_info("Test Case: demo");
            for i in 0 to 32 - 1 loop
                in_valid_i <= '1';
                in_mult_a_i   <= toUslv(1, in_mult_a_i'length);
                in_mult_b_i   <= toUslv(1, in_mult_b_i'length);

                tb_clk_period(clk_i);
                sel <= '1';
            end loop;

            in_valid_i <= '0';
            sel        <= '0';

            tb_clk_period(clk_i, 100);

            for i in 0 to 32 - 1 loop

                in_valid_i <= '1';
                in_mult_a_i   <= toUslv(i mod 4, in_mult_a_i'length);
                in_mult_b_i   <= toUslv(i mod 4, in_mult_b_i'length);

                tb_clk_period(clk_i);
                sel <= '1';
            end loop;

            in_valid_i <= '0';
            sel        <= '0';

            tb_clk_period(clk_i, 100);

        end if;

        tb_finish;

    end process;

end architecture tb;