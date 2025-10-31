---------------------------------------------------------------------------------------------------
-- fix_dot_product_vunit_tb
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
-- Libraries
---------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library vunit_lib;
context vunit_lib.vunit_context;
context vunit_lib.com_context;
context vunit_lib.vc_context;
use vunit_lib.queue_pkg.all;
use vunit_lib.sync_pkg.all;

library olo;
use olo.olo_base_pkg_array.all;
use olo.en_cl_fix_pkg.all;
use olo.olo_fix_pkg.all;

library work;
use work.olo_test_fix_stimuli_array_pkg.all;
use work.olo_test_fix_checker_pkg.all;

---------------------------------------------------------------------------------------------------
-- Entity
---------------------------------------------------------------------------------------------------
-- vunit: run_all_in_same_sim
entity fix_dot_product_vunit_tb is
    generic (
        DIMENSION_WIDTH_G : natural := 32;

        FMT_IN_ELEMENT_A_G : string := "(0,4,4)";
        FMT_IN_ELEMENT_B_G : string := "(0,4,4)";
        FMT_OUT_RESULT_G   : string := "(0,13,8)";

        runner_cfg : string
    );
end entity;

architecture sim of fix_dot_product_vunit_tb is

    -----------------------------------------------------------------------------------------------
    -- TB Definitions
    -----------------------------------------------------------------------------------------------
    constant CLK_FREQUENCY_C : real := 100.0e6; -- 100 MHz
    constant CLK_PERIOD_C    : time := (1 sec) / CLK_FREQUENCY_C;

    -----------------------------------------------------------------------------------------------
    -- Interface Signals
    -----------------------------------------------------------------------------------------------
    signal clk_i : std_logic := '0';
    signal rst_i : std_logic := '0';

    signal in_valid_i    : std_logic;
    signal in_ready_o    : std_logic;
    signal in_vector_a_i : StlvArray_t(DIMENSION_WIDTH_G - 1 downto 0)(fixFmtWidthFromString(FMT_IN_ELEMENT_A_G) - 1 downto 0);
    signal in_vector_b_i : StlvArray_t(DIMENSION_WIDTH_G - 1 downto 0)(fixFmtWidthFromString(FMT_IN_ELEMENT_B_G) - 1 downto 0);

    signal out_valid_o  : std_logic;
    signal out_result_o : std_logic_vector(fixFmtWidthFromString(FMT_OUT_RESULT_G) - 1 downto 0);

    -----------------------------------------------------------------------------------------------
    -- TB Definitions
    -----------------------------------------------------------------------------------------------

    -- *** Verification Components ***
    constant STIMULI_VECTOR_A_C : olo_test_fix_stimuli_t := new_olo_test_fix_stimuli;
    constant STIMULI_VECTOR_B_C : olo_test_fix_stimuli_t := new_olo_test_fix_stimuli;

    constant CHECKER_RESULT_C : olo_test_fix_checker_t := new_olo_test_fix_checker;

    -- *** Constants ***
    constant VECTOR_A_FILE_C : string := output_path(runner_cfg) & "vector_a.fix";
    constant VECTOR_B_FILE_C : string := output_path(runner_cfg) & "vector_b.fix";
    constant RESULT_FILE_C   : string := output_path(runner_cfg) & "result.fix";

begin

    -----------------------------------------------------------------------------------------------
    -- TB Control
    -----------------------------------------------------------------------------------------------
    test_runner_watchdog(runner, 10 ms);

    p_control : process is
    begin
        test_runner_setup(runner, runner_cfg);

        while test_suite loop

            -- Reset
            wait until rising_edge(clk_i);
            rst_i <= '1';
            wait for 1 us;
            wait until rising_edge(clk_i);
            rst_i <= '0';
            wait until rising_edge(clk_i);

            -- *** First Run ***
            if run("FullSpeed") then
                fix_stimuli_play_file (net, STIMULI_VECTOR_A_C, VECTOR_A_FILE_C);
                fix_stimuli_play_file (net, STIMULI_VECTOR_B_C, VECTOR_B_FILE_C);

                fix_checker_check_file (net, CHECKER_RESULT_C, RESULT_FILE_C);
            end if;

            -- *** Second run with delay ***
            if run("Throttled") then
                fix_stimuli_play_file (net, STIMULI_VECTOR_A_C, VECTOR_A_FILE_C, stall_probability => 0.5, stall_max_cycles => 10);
                fix_stimuli_play_file (net, STIMULI_VECTOR_B_C, VECTOR_B_FILE_C);

                fix_checker_check_file (net, CHECKER_RESULT_C, RESULT_FILE_C);
            end if;

            -- *** Wait until done ***
            wait_until_idle(net, as_sync(STIMULI_VECTOR_A_C));
            wait_until_idle(net, as_sync(STIMULI_VECTOR_B_C));
            wait_until_idle(net, as_sync(CHECKER_RESULT_C));
            wait for 1 us;

        end loop;

        -- TB done
        test_runner_cleanup(runner);
    end process;

    -----------------------------------------------------------------------------------------------
    -- Clock
    -----------------------------------------------------------------------------------------------
    clk_i <= not clk_i after 0.5*CLK_PERIOD_C;

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

    -----------------------------------------------------------------------------------------------
    -- Verification Components
    -----------------------------------------------------------------------------------------------
    vc_stimuli_vector_a : entity work.olo_test_fix_stimuli_array_vc
        generic map (
            Instance => STIMULI_VECTOR_A_C,
            Dim      => DIMENSION_WIDTH_G,
            Fmt      => cl_fix_format_from_string(FMT_IN_ELEMENT_A_G)
        )
        port map (
            Clk => clk_i,
            Rst => rst_i,

            Valid => in_valid_i,
            Ready => in_ready_o,
            Data  => in_vector_a_i
        );

    vc_stimuli_vector_b : entity work.olo_test_fix_stimuli_array_vc
        generic map (
            Instance => STIMULI_VECTOR_B_C,
            Dim      => DIMENSION_WIDTH_G,
            Fmt      => cl_fix_format_from_string(FMT_IN_ELEMENT_B_G),
            Is_Timing_Master => false
        )
        port map (
            Clk => clk_i,
            Rst => rst_i,

            Valid => in_valid_i,
            Ready => in_ready_o,
            Data  => in_vector_b_i
        );

    vc_checker_result : entity work.olo_test_fix_checker_vc
        generic map (
            Instance => CHECKER_RESULT_C,
            Fmt      => cl_fix_format_from_string(FMT_OUT_RESULT_G)
        )
        port map (
            Clk => clk_i,

            Valid => out_valid_o,
            Data  => out_result_o
        );

end architecture;
