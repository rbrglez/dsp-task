--------------------------------------------------------------------------------
-- evaluate_fix_dsp_mac
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library olo;
use olo.olo_base_pkg_array.all;
use olo.olo_base_pkg_math.all;
use olo.en_cl_fix_pkg.all;
use olo.olo_fix_pkg.all;

entity evaluate_fix_dsp_mac is
    generic(
        FMT_MULT_A_G : string := "(0, 8, 8)";
        FMT_MULT_B_G : string := "(0, 8, 8)";
        FMT_ADD_G    : string := "(0, 16, 16)";
        FMT_RESULT_G : string := "(0, 17, 16)"
    );
    port(
        clk_125_i : in std_logic;
        rstn_i    : in std_logic;

        in_reduce_mult_a_data_i  : in std_logic;
        in_reduce_mult_a_latch_i : in std_logic;

        in_reduce_mult_b_data_i  : in std_logic;
        in_reduce_mult_b_latch_i : in std_logic;

        in_reduce_add_data_i  : in std_logic;
        in_reduce_add_latch_i : in std_logic;

        out_reduce_result_data_o  : out std_logic;
        out_reduce_result_latch_i : in  std_logic

    );
end entity evaluate_fix_dsp_mac;

architecture rtl of evaluate_fix_dsp_mac is

    signal rst_125 : std_logic;

    signal in_mult_a : std_logic_vector(fixFmtWidthFromString(FMT_MULT_A_G) - 1 downto 0);
    signal in_mult_b : std_logic_vector(fixFmtWidthFromString(FMT_MULT_B_G) - 1 downto 0);
    signal in_add    : std_logic_vector(fixFmtWidthFromString(FMT_ADD_G) - 1 downto 0);
    signal out_result : std_logic_vector(fixFmtWidthFromString(FMT_RESULT_G) - 1 downto 0);

begin

    ----------------------------------------------------------------------------
    -- Evaluation Module
    ----------------------------------------------------------------------------
    u_fix_dsp_mac : entity work.fix_dsp_mac
        generic map (
            FMT_MULT_A_G => FMT_MULT_A_G,
            FMT_MULT_B_G => FMT_MULT_B_G,
            FMT_ADD_G    => FMT_ADD_G,
            FMT_RESULT_G => FMT_RESULT_G
        )
        port map (
            clk_i    => clk_125_i,
            rst_i    => rst_125,

            in_mult_a_i => in_mult_a,
            in_mult_b_i => in_mult_b,
            in_add_i    => in_add,

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

    u_in_reduce_mult_a : entity work.in_reduce
        generic map (
            Size_g => in_mult_a'length
        )
        port map (
            Clk      => clk_125_i,
            Data     => in_reduce_mult_a_data_i,
            Latch    => in_reduce_mult_a_latch_i,
            DutPorts => in_mult_a
        );

    u_in_reduce_mult_b : entity work.in_reduce
        generic map (
            Size_g => in_mult_b'length
        )
        port map (
            Clk      => clk_125_i,
            Data     => in_reduce_mult_b_data_i,
            Latch    => in_reduce_mult_b_latch_i,
            DutPorts => in_mult_b
        );

    u_in_reduce_add : entity work.in_reduce
        generic map (
            Size_g => in_add'length
        )
        port map (
            Clk      => clk_125_i,
            Data     => in_reduce_add_data_i,
            Latch    => in_reduce_add_latch_i,
            DutPorts => in_add
        );

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