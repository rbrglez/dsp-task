--------------------------------------------------------------------------------
-- fix_dot_product_tb
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Libraries
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library xbc;
context xbc.xbc_testbench_context;

library olo;
use olo.olo_base_pkg_logic.all;
use olo.olo_base_pkg_array.all;
use olo.olo_base_pkg_math.all;
use olo.en_cl_fix_pkg.all;
use olo.olo_fix_pkg.all;

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity fix_dot_product_tb is
    generic (
        TEST_CASE_G       : string  := "demo";
        DIMENSION_WIDTH_G : natural := 8;

        FMT_IN_ELEMENT_A_G : string := "(0, 2, 2)";
        FMT_IN_ELEMENT_B_G : string := "(0, 2, 2)";
        FMT_OUT_RESULT_G   : string := "(0, 9, 4)"
    );
end entity fix_dot_product_tb;

architecture tb of fix_dot_product_tb is

    constant T_C : time := 10 ns;

    ----------------------------------------------------------------------------
    -- DUT
    ----------------------------------------------------------------------------
    signal clk_i : std_logic;
    signal rst_i : std_logic;

    signal in_valid_i    : std_logic;
    signal in_ready_o    : std_logic;
    signal in_vector_a_i : StlvArray_t(DIMENSION_WIDTH_G - 1 downto 0)(fixFmtWidthFromString(FMT_IN_ELEMENT_A_G) - 1 downto 0);
    signal in_vector_b_i : StlvArray_t(DIMENSION_WIDTH_G - 1 downto 0)(fixFmtWidthFromString(FMT_IN_ELEMENT_B_G) - 1 downto 0);

    signal out_valid_o  : std_logic;
    signal out_result_o : std_logic_vector(fixFmtWidthFromString(FMT_OUT_RESULT_G) - 1 downto 0);

begin

    ----------------------------------------------------------------------------
    -- DUT
    ----------------------------------------------------------------------------
    dut : entity work.fix_dot_product
        generic map (
            DIMENSION_WIDTH_G  => DIMENSION_WIDTH_G,
            FMT_IN_ELEMENT_A_G => FMT_IN_ELEMENT_A_G,
            FMT_IN_ELEMENT_B_G => FMT_IN_ELEMENT_B_G,
            FMT_OUT_RESULT_G   => FMT_OUT_RESULT_G
        )
        port map (
            clk_i => clk_i,
            rst_i => rst_i,

            in_valid_i    => in_valid_i,
            in_ready_o    => in_ready_o,
            in_vector_a_i => in_vector_a_i,
            in_vector_b_i => in_vector_b_i,

            out_valid_o  => out_valid_o,
            out_result_o => out_result_o
        );

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
        in_valid_i    <= '0';
        in_vector_a_i <= (others => (others => 'X'));
        in_vector_b_i <= (others => (others => 'X'));

        tb_clk_period(clk_i, 10);

        if (TEST_CASE_G = "demo") then
            --------------------------------------------------------------------
            log_info("Test Case: demo");

            for i in 0 to DIMENSION_WIDTH_G - 1 loop
                in_vector_a_i(i) <= toUslv(i, fixFmtWidthFromString(FMT_IN_ELEMENT_A_G));
                in_vector_b_i(i) <= toUslv(DIMENSION_WIDTH_G - i, fixFmtWidthFromString(FMT_IN_ELEMENT_B_G));
            end loop;

            in_valid_i <= '1';
            tb_clk_period(clk_i);
            in_valid_i <= '0';

            in_vector_a_i <= (others => (others => 'X'));
            in_vector_b_i <= (others => (others => 'X'));

            tb_clk_period(clk_i, 8);

            --------------------------------------------------------------------
            for i in 0 to DIMENSION_WIDTH_G - 1 loop
                in_vector_a_i(i) <= toUslv(1, fixFmtWidthFromString(FMT_IN_ELEMENT_A_G));
                in_vector_b_i(i) <= toUslv(i, fixFmtWidthFromString(FMT_IN_ELEMENT_B_G));
            end loop;

            in_valid_i <= '1';
            tb_clk_period(clk_i);
            in_valid_i <= '0';

            in_vector_a_i <= (others => (others => 'X'));
            in_vector_b_i <= (others => (others => 'X'));

            tb_clk_period(clk_i, 8);

            --------------------------------------------------------------------
            for i in 0 to DIMENSION_WIDTH_G - 1 loop
                in_vector_a_i(i) <= toUslv(i mod 4, fixFmtWidthFromString(FMT_IN_ELEMENT_A_G));
                in_vector_b_i(i) <= toUslv(i mod 2, fixFmtWidthFromString(FMT_IN_ELEMENT_B_G));
            end loop;

            in_valid_i <= '1';
            tb_clk_period(clk_i);
            in_valid_i <= '0';

            in_vector_a_i <= (others => (others => 'X'));
            in_vector_b_i <= (others => (others => 'X'));

            tb_clk_period(clk_i, 8);

            tb_clk_period(clk_i, 10);

        end if;

        tb_finish;

    end process;

end architecture tb;