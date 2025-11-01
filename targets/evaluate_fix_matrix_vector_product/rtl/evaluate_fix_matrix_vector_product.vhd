--------------------------------------------------------------------------------
-- evaluate_fix_matrix_vector_product
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library olo;
use olo.olo_base_pkg_array.all;
use olo.olo_base_pkg_math.all;
use olo.en_cl_fix_pkg.all;
use olo.olo_fix_pkg.all;

library work;
use work.extend_pkg_array.all;
use work.support_matrix_generator_pkg.all;

entity evaluate_fix_matrix_vector_product is
    generic(
        NUM_DOT_PRODUCTS_G : positive := 11;

        MATRIX_ROW_WIDTH_G    : natural := 32;
        MATRIX_COLUMN_WIDTH_G : natural := 32;

        FMT_IN_MATRIX_ELEMENT_G : string := "(0, 8, 8)";
        FMT_IN_VECTOR_ELEMENT_G : string := "(0, 8, 8)";
        FMT_OUT_RESULT_G        : string := "(0, 21, 16)"
    );
    port(
        clk_125_i : in std_logic;
        rstn_i    : in std_logic;

        in_reduce_vector_data_i  : in std_logic;
        in_reduce_vector_latch_i : in std_logic;

        out_reduce_result_data_o  : out std_logic;
        out_reduce_result_latch_i : in  std_logic

    );
end entity evaluate_fix_matrix_vector_product;

architecture rtl of evaluate_fix_matrix_vector_product is

    signal rst_125 : std_logic;

    constant IN_MATRIX_C : StlvVectorArray_t(MATRIX_ROW_WIDTH_G - 1 downto 0)(MATRIX_COLUMN_WIDTH_G - 1 downto 0)(fixFmtWidthFromString(FMT_IN_MATRIX_ELEMENT_G) - 1 downto 0) :=
        descending_matrix(MATRIX_ROW_WIDTH_G, MATRIX_COLUMN_WIDTH_G, fixFmtWidthFromString(FMT_IN_MATRIX_ELEMENT_G));

    signal in_vector_flat : std_logic_vector(MATRIX_COLUMN_WIDTH_G * fixFmtWidthFromString(FMT_IN_VECTOR_ELEMENT_G) - 1 downto 0);
    signal in_vector      : StlvArray_t(MATRIX_COLUMN_WIDTH_G - 1 downto 0)(fixFmtWidthFromString(FMT_IN_VECTOR_ELEMENT_G) - 1 downto 0);

    signal out_result_flat : std_logic_vector(MATRIX_ROW_WIDTH_G * fixFmtWidthFromString(FMT_OUT_RESULT_G) - 1 downto 0);
    signal out_result      : StlvArray_t(MATRIX_ROW_WIDTH_G - 1 downto 0)(fixFmtWidthFromString(FMT_OUT_RESULT_G) - 1 downto 0);

begin

    ----------------------------------------------------------------------------
    -- Evaluation Module
    ----------------------------------------------------------------------------
    u_fix_matrix_vector_product : entity work.fix_matrix_vector_product
        generic map (
            NUM_DOT_PRODUCTS_G      => NUM_DOT_PRODUCTS_G,
            MATRIX_ROW_WIDTH_G      => MATRIX_ROW_WIDTH_G,
            MATRIX_COLUMN_WIDTH_G   => MATRIX_COLUMN_WIDTH_G,
            FMT_IN_MATRIX_ELEMENT_G => FMT_IN_MATRIX_ELEMENT_G,
            FMT_IN_VECTOR_ELEMENT_G => FMT_IN_VECTOR_ELEMENT_G,
            FMT_OUT_RESULT_G        => FMT_OUT_RESULT_G
        )
        port map (
            clk_i => clk_125_i,
            rst_i => rst_125,

            in_matrix_i => IN_MATRIX_C,
            in_vector_i => in_vector,

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
            Size_g => in_vector_flat'length
        )
        port map (
            Clk      => clk_125_i,
            Data     => in_reduce_vector_data_i,
            Latch    => in_reduce_vector_latch_i,
            DutPorts => in_vector_flat
        );

    in_vector <= unflattenStlvArray(in_vector_flat, fixFmtWidthFromString(FMT_IN_VECTOR_ELEMENT_G));

    u_out_reduce_result : entity work.out_reduce
        generic map (
            Size_g => out_result_flat'length
        )
        port map (
            Clk      => clk_125_i,
            Data     => out_reduce_result_data_o,
            Latch    => out_reduce_result_latch_i,
            DutPorts => out_result_flat
        );

    out_result_flat <= flattenStlvArray(out_result);

end architecture rtl;