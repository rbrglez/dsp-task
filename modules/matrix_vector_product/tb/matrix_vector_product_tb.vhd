--------------------------------------------------------------------------------
-- matrix_vector_product_tb
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

library work;
use work.extend_pkg_array.all;

entity matrix_vector_product_tb is
    generic (
        TEST_CASE_G : string := "demo";

        NUM_DOT_PRODUCTS_G : positive := 11;

        MATRIX_ROW_WIDTH_G    : natural := 32;
        MATRIX_COLUMN_WIDTH_G : natural := 32;
        IN_ELEMENT_WIDTH_G    : natural := 16;
        OUT_ELEMENT_WIDTH_G   : natural := 37
    );
end entity matrix_vector_product_tb;

architecture tb of matrix_vector_product_tb is

    constant T_C : time := 10 ns;

    ----------------------------------------------------------------------------
    -- DUT
    ----------------------------------------------------------------------------
    signal clk_i : std_logic;
    signal rst_i : std_logic;

    signal in_valid_i  : std_logic;
    signal in_ready_o  : std_logic;
    signal in_matrix_i : StlvVectorArray_t(MATRIX_ROW_WIDTH_G - 1 downto 0)(MATRIX_COLUMN_WIDTH_G - 1 downto 0)(IN_ELEMENT_WIDTH_G - 1 downto 0);
    signal in_vector_i : StlvArray_t(MATRIX_COLUMN_WIDTH_G - 1 downto 0)(IN_ELEMENT_WIDTH_G - 1 downto 0);

    signal out_valid_o  : std_logic;
    signal out_result_o : StlvArray_t(MATRIX_ROW_WIDTH_G - 1 downto 0)(OUT_ELEMENT_WIDTH_G - 1 downto 0);

begin

    ----------------------------------------------------------------------------
    -- DUT
    ----------------------------------------------------------------------------
    dut : entity work.matrix_vector_product
        generic map (
            NUM_DOT_PRODUCTS_G    => NUM_DOT_PRODUCTS_G,
            MATRIX_ROW_WIDTH_G    => MATRIX_ROW_WIDTH_G,
            MATRIX_COLUMN_WIDTH_G => MATRIX_COLUMN_WIDTH_G,
            IN_ELEMENT_WIDTH_G    => IN_ELEMENT_WIDTH_G,
            OUT_ELEMENT_WIDTH_G   => OUT_ELEMENT_WIDTH_G
        )
        port map (
            clk_i => clk_i,
            rst_i => rst_i,

            in_valid_i  => in_valid_i,
            in_ready_o  => in_ready_o,
            in_matrix_i => in_matrix_i,
            in_vector_i => in_vector_i,

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
        in_valid_i  <= '0';
        in_matrix_i <= (others => (others => (others => 'X')));
        in_vector_i <= (others => (others => 'X'));


        tb_clk_period(clk_i, 10);

        if (TEST_CASE_G = "demo") then
            --------------------------------------------------------------------
            log_info("Test Case: demo");

            --------------------------------------------------------------------
            for i in 0 to MATRIX_ROW_WIDTH_G - 1 loop
                for j in 0 to MATRIX_COLUMN_WIDTH_G - 1 loop
                    in_matrix_i(i)(j) <= toUslv(j + i*MATRIX_ROW_WIDTH_G, IN_ELEMENT_WIDTH_G);
                end loop;
            end loop;

            for i in 0 to MATRIX_COLUMN_WIDTH_G - 1 loop
                in_vector_i(i) <= toUslv(i, IN_ELEMENT_WIDTH_G);
            end loop;

            in_valid_i <= '1';
            tb_clk_period(clk_i);
            in_valid_i <= '0';

            in_matrix_i <= (others => (others => (others => 'X')));
            in_vector_i <= (others => (others => 'X'));

            tb_clk_period(clk_i, 124);

            --------------------------------------------------------------------
            for i in 0 to MATRIX_ROW_WIDTH_G - 1 loop
                for j in 0 to MATRIX_COLUMN_WIDTH_G - 1 loop
                    in_matrix_i(i)(j) <= toUslv(MATRIX_COLUMN_WIDTH_G - j + i*MATRIX_ROW_WIDTH_G, IN_ELEMENT_WIDTH_G);
                end loop;
            end loop;

            for i in 0 to MATRIX_COLUMN_WIDTH_G - 1 loop
                in_vector_i(i) <= toUslv(i mod 8, IN_ELEMENT_WIDTH_G);
            end loop;

            in_valid_i <= '1';
            tb_clk_period(clk_i);
            in_valid_i <= '0';

            in_matrix_i <= (others => (others => (others => 'X')));
            in_vector_i <= (others => (others => 'X'));

            tb_clk_period(clk_i, 124);

            --------------------------------------------------------------------
            for i in 0 to MATRIX_ROW_WIDTH_G - 1 loop
                for j in 0 to MATRIX_COLUMN_WIDTH_G - 1 loop
                    in_matrix_i(i)(j) <= toUslv(j + i*MATRIX_ROW_WIDTH_G, IN_ELEMENT_WIDTH_G);
                end loop;
            end loop;

            for i in 0 to MATRIX_COLUMN_WIDTH_G - 1 loop
                in_vector_i(i) <= toUslv(i * i, IN_ELEMENT_WIDTH_G);
            end loop;

            in_valid_i <= '1';
            tb_clk_period(clk_i);
            in_valid_i <= '0';

            in_matrix_i <= (others => (others => (others => 'X')));
            in_vector_i <= (others => (others => 'X'));

            tb_clk_period(clk_i, 124);

            --------------------------------------------------------------------
            for i in 0 to MATRIX_ROW_WIDTH_G - 1 loop
                for j in 0 to MATRIX_COLUMN_WIDTH_G - 1 loop
                    in_matrix_i(i)(j) <= toUslv(MATRIX_COLUMN_WIDTH_G - j + i*MATRIX_ROW_WIDTH_G, IN_ELEMENT_WIDTH_G);
                end loop;
            end loop;

            for i in 0 to MATRIX_COLUMN_WIDTH_G - 1 loop
                in_vector_i(i) <= toUslv(i + 20, IN_ELEMENT_WIDTH_G);
            end loop;

            in_valid_i <= '1';
            tb_clk_period(clk_i);
            in_valid_i <= '0';

            in_matrix_i <= (others => (others => (others => 'X')));
            in_vector_i <= (others => (others => 'X'));

            tb_clk_period(clk_i, 124);


            tb_clk_period(clk_i, 100);

        end if;

        tb_finish;

    end process;

end architecture tb;