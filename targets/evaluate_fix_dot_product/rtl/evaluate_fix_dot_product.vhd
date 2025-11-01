--------------------------------------------------------------------------------
-- evaluate_fix_dot_product
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library olo;
use olo.olo_base_pkg_array.all;
use olo.olo_base_pkg_math.all;
use olo.en_cl_fix_pkg.all;
use olo.olo_fix_pkg.all;

entity evaluate_fix_dot_product is
    generic(
        DIMENSION_WIDTH_G : natural := 32;

        FMT_IN_ELEMENT_A_G : string := "(0, 4, 12)";
        FMT_IN_ELEMENT_B_G : string := "(0, 4, 12)";
        FMT_OUT_RESULT_G   : string := "(0, 13, 24)"
    );
    port(
        clk_125_i : in std_logic;
        rstn_i    : in std_logic;

        in_reduce_vector_a_data_i  : in std_logic;
        in_reduce_vector_a_latch_i : in std_logic;

        in_reduce_vector_b_data_i  : in std_logic;
        in_reduce_vector_b_latch_i : in std_logic;

        out_reduce_result_data_o  : out std_logic;
        out_reduce_result_latch_i : in  std_logic

    );
end entity evaluate_fix_dot_product;

architecture rtl of evaluate_fix_dot_product is

    signal rst_125 : std_logic;

    signal in_vector_a : StlvArray_t(DIMENSION_WIDTH_G - 1 downto 0)(fixFmtWidthFromString(FMT_IN_ELEMENT_A_G) - 1 downto 0);
    signal in_vector_b : StlvArray_t(DIMENSION_WIDTH_G - 1 downto 0)(fixFmtWidthFromString(FMT_IN_ELEMENT_B_G) - 1 downto 0);

    signal out_result : std_logic_vector(fixFmtWidthFromString(FMT_OUT_RESULT_G) - 1 downto 0);

    signal in_vector_a_flat : std_logic_vector(DIMENSION_WIDTH_G * fixFmtWidthFromString(FMT_IN_ELEMENT_A_G) - 1 downto 0);
    signal in_vector_b_flat : std_logic_vector(DIMENSION_WIDTH_G * fixFmtWidthFromString(FMT_IN_ELEMENT_A_G) - 1 downto 0);

begin

    ----------------------------------------------------------------------------
    -- Evaluation Module
    ----------------------------------------------------------------------------
    u_fix_dot_product : entity work.fix_dot_product
        generic map (
            DIMENSION_WIDTH_G  => DIMENSION_WIDTH_G,
            FMT_IN_ELEMENT_A_G => FMT_IN_ELEMENT_A_G,
            FMT_IN_ELEMENT_B_G => FMT_IN_ELEMENT_B_G,
            FMT_OUT_RESULT_G   => FMT_OUT_RESULT_G
        )
        port map (
            clk_i => clk_125_i,
            rst_i => rst_125,

            in_vector_a_i => in_vector_a,
            in_vector_b_i => in_vector_b,

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

    u_in_reduce_vector_a : entity work.in_reduce
        generic map (
            Size_g => in_vector_a_flat'length
        )
        port map (
            Clk      => clk_125_i,
            Data     => in_reduce_vector_a_data_i,
            Latch    => in_reduce_vector_a_latch_i,
            DutPorts => in_vector_a_flat
        );

    in_vector_a <= unflattenStlvArray(in_vector_a_flat, fixFmtWidthFromString(FMT_IN_ELEMENT_A_G));

    u_in_reduce_vector_b : entity work.in_reduce
        generic map (
            Size_g => in_vector_b_flat'length
        )
        port map (
            Clk      => clk_125_i,
            Data     => in_reduce_vector_b_data_i,
            Latch    => in_reduce_vector_b_latch_i,
            DutPorts => in_vector_b_flat
        );

    in_vector_b <= unflattenStlvArray(in_vector_b_flat, fixFmtWidthFromString(FMT_IN_ELEMENT_B_G));

    u_out_reduce_result : entity work.out_reduce
        generic map (
            Size_g => out_result'length
        )
        port map (
            Clk      => clk_125_i,
            Data     => out_reduce_result_data_o,
            Latch    => out_reduce_result_latch_i,
            DutPorts => out_result
        );

end architecture rtl;