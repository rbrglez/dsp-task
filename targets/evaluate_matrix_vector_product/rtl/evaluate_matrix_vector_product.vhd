--------------------------------------------------------------------------------
-- evaluate_matrix_vector_product
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library olo;
use olo.olo_base_pkg_array.all;
use olo.olo_base_pkg_math.all;

library work;
use work.extend_pkg_array.all;
use work.matrix_pkg.all;

entity evaluate_matrix_vector_product is
    generic(
        NUM_DOT_PRODUCTS_G : positive := 11;

        MATRIX_ROW_WIDTH_G    : natural := 32;
        MATRIX_COLUMN_WIDTH_G : natural := 32;
        IN_ELEMENT_WIDTH_G    : natural := 16
    );
    port(
        clk_125_i : in std_logic;
        rstn_i    : in std_logic;

        in_valid_i : in std_logic;

        in_reduce_vector_data_i  : in std_logic;
        in_reduce_vector_latch_i : in std_logic;

        out_reduce_result_data_o  : out std_logic;
        out_reduce_result_latch_i : in  std_logic

    );
end entity evaluate_matrix_vector_product;

architecture rtl of evaluate_matrix_vector_product is

    signal rst_125 : std_logic;

    constant OUT_ELEMENT_WIDTH_C : natural := log2ceil(MATRIX_COLUMN_WIDTH_G) + 2*IN_ELEMENT_WIDTH_G;

    constant IN_MATRIX_C : StlvVectorArray_t(MATRIX_ROW_WIDTH_G - 1 downto 0)(MATRIX_COLUMN_WIDTH_G - 1 downto 0)(IN_ELEMENT_WIDTH_G - 1 downto 0) :=
        generate_example_matrix(MATRIX_ROW_WIDTH_G, MATRIX_COLUMN_WIDTH_G, IN_ELEMENT_WIDTH_G);

    signal in_vector_flat : std_logic_vector(MATRIX_COLUMN_WIDTH_G * IN_ELEMENT_WIDTH_G - 1 downto 0);
    signal in_vector      : StlvArray_t(MATRIX_COLUMN_WIDTH_G - 1 downto 0)(IN_ELEMENT_WIDTH_G - 1 downto 0);

    signal out_result      : StlvArray_t(MATRIX_ROW_WIDTH_G - 1 downto 0)(OUT_ELEMENT_WIDTH_C - 1 downto 0);
    signal out_result_flat : std_logic_vector(MATRIX_ROW_WIDTH_G * OUT_ELEMENT_WIDTH_C - 1 downto 0);

begin

    ----------------------------------------------------------------------------
    -- Evaluation Module
    ----------------------------------------------------------------------------

    u_matrix_vector_product : entity work.matrix_vector_product
        generic map (
            NUM_DOT_PRODUCTS_G    => NUM_DOT_PRODUCTS_G,
            MATRIX_ROW_WIDTH_G    => MATRIX_ROW_WIDTH_G,
            MATRIX_COLUMN_WIDTH_G => MATRIX_COLUMN_WIDTH_G,
            IN_ELEMENT_WIDTH_G    => IN_ELEMENT_WIDTH_G,
            OUT_ELEMENT_WIDTH_G   => OUT_ELEMENT_WIDTH_C
        )
        port map (
            clk_i => clk_125_i,
            rst_i => rst_125,

            in_valid_i  => in_valid_i,
            in_ready_o  => open,
            in_matrix_i => IN_MATRIX_C,
            in_vector_i => in_vector,

            out_valid_o  => open,
            out_error_o  => open,
            out_result_o => out_result
        );

    ----------------------------------------------------------------------------
    -- Support Modules
    ----------------------------------------------------------------------------
    u_reset_gen : entity olo.olo_base_reset_gen
        generic map (
            RstInPolarity_g => '0' -- Active Low reset input
        )
        port map (
            Clk    => clk_125_i,
            RstOut => rst_125, -- Active High reset output
            RstIn  => rstn_i
        );

    u_in_reduce_vector : entity work.in_reduce
        generic map (
            Size_g => (MATRIX_COLUMN_WIDTH_G * IN_ELEMENT_WIDTH_G)
        )
        port map (
            Clk      => clk_125_i,
            Data     => in_reduce_vector_data_i,
            Latch    => in_reduce_vector_latch_i,
            DutPorts => in_vector_flat
        );

    in_vector <= unflattenStlvArray(in_vector_flat, IN_ELEMENT_WIDTH_G);

    u_out_reduce_result : entity work.out_reduce
        generic map (
            Size_g => (MATRIX_ROW_WIDTH_G * OUT_ELEMENT_WIDTH_C)
        )
        port map (
            Clk      => clk_125_i,
            Data     => out_reduce_result_data_o,
            Latch    => out_reduce_result_latch_i,
            DutPorts => out_result_flat
        );

    out_result_flat <= flattenStlvArray(out_result);

end architecture rtl;