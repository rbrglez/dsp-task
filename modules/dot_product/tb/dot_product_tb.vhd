--------------------------------------------------------------------------------
-- dot_product_tb
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

entity dot_product_tb is
    generic (
        TEST_CASE_G       : string  := "demo";
        DIMENSION_WIDTH_G : natural := 8;
        ELEMENT_WIDTH_G   : natural := 4;
        PRODUCT_WIDTH_G   : natural := 11
    );
end entity dot_product_tb;

architecture tb of dot_product_tb is

    constant T_C : time := 10 ns;


    ----------------------------------------------------------------------------
    -- DUT
    ----------------------------------------------------------------------------
    signal clk_i             : std_logic;
    signal rst_i             : std_logic;
    signal in_valid_i        : std_logic;
    signal in_ready_o        : std_logic;
    signal in_vector_a_i     : StlvArray_t(DIMENSION_WIDTH_G - 1 downto 0)(ELEMENT_WIDTH_G - 1 downto 0);
    signal in_vector_b_i     : StlvArray_t(DIMENSION_WIDTH_G - 1 downto 0)(ELEMENT_WIDTH_G - 1 downto 0);
    signal out_valid_o       : std_logic;
    signal out_dot_product_o : std_logic_vector(PRODUCT_WIDTH_G - 1 downto 0);

begin

    ----------------------------------------------------------------------------
    -- DUT
    ----------------------------------------------------------------------------
    dut : entity work.dot_product
        generic map (
            DIMENSION_WIDTH_G => DIMENSION_WIDTH_G,
            ELEMENT_WIDTH_G   => ELEMENT_WIDTH_G,
            PRODUCT_WIDTH_G   => PRODUCT_WIDTH_G
        )
        port map (
            clk_i => clk_i,
            rst_i => rst_i,

            in_valid_i    => in_valid_i,
            in_ready_o    => in_ready_o,
            in_vector_a_i => in_vector_a_i,
            in_vector_b_i => in_vector_b_i,

            out_valid_o       => out_valid_o,
            out_dot_product_o => out_dot_product_o
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
        in_vector_a_i <= (others => (others => '0'));
        in_vector_b_i <= (others => (others => '0'));

        tb_clk_period(clk_i, 10);

        if (TEST_CASE_G = "demo") then
            --------------------------------------------------------------------
            log_info("Test Case: demo");
            for i in 0 to DIMENSION_WIDTH_G - 1 loop
                in_vector_a_i(i) <= toUslv(i, ELEMENT_WIDTH_G);
                in_vector_b_i(i) <= toUslv(DIMENSION_WIDTH_G - i, ELEMENT_WIDTH_G);
            end loop;

            in_valid_i <= '1';
            tb_clk_period(clk_i);
            in_valid_i <= '0';


            tb_clk_period(clk_i, 100);


        end if;

        tb_finish;

    end process;

end architecture tb;