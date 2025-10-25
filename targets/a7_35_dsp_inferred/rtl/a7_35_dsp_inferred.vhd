--------------------------------------------------------------------------------
-- a7_35_dsp_inferred
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity a7_35_dsp_inferred is
    generic(
        WIDTH_A_G : natural := 18;
        WIDTH_B_G : natural := 24;
        WIDTH_C_G : natural := 43;
        WIDTH_P_G : natural := 43
    );
    port(
        clk_i : in std_logic;

        in_reduce_data_a_i  : in std_logic;
        in_reduce_latch_a_i : in std_logic;

        in_reduce_data_b_i  : in std_logic;
        in_reduce_latch_b_i : in std_logic;

        in_reduce_data_c_i  : in std_logic;
        in_reduce_latch_c_i : in std_logic;

        out_reduce_data_p_o  : out std_logic;
        out_reduce_latch_p_i : in  std_logic

    );
end entity a7_35_dsp_inferred;

architecture rtl of a7_35_dsp_inferred is


    signal dsp_a : std_logic_vector(WIDTH_A_G - 1 downto 0);
    signal dsp_b : std_logic_vector(WIDTH_B_G - 1 downto 0);
    signal dsp_c : std_logic_vector(WIDTH_C_G - 1 downto 0);
    signal dsp_p : std_logic_vector(WIDTH_P_G - 1 downto 0);

begin

    u_in_reduce_a : entity work.in_reduce
        generic map (
            Size_g => WIDTH_A_G
        )
        port map (
            Clk      => clk_i,
            Data     => in_reduce_data_a_i,
            Latch    => in_reduce_latch_a_i,
            DutPorts => dsp_a
        );

    u_in_reduce_b : entity work.in_reduce
        generic map (
            Size_g => WIDTH_B_G
        )
        port map (
            Clk      => clk_i,
            Data     => in_reduce_data_b_i,
            Latch    => in_reduce_latch_b_i,
            DutPorts => dsp_b
        );

    u_in_reduce_c : entity work.in_reduce
        generic map (
            Size_g => WIDTH_C_G
        )
        port map (
            Clk      => clk_i,
            Data     => in_reduce_data_c_i,
            Latch    => in_reduce_latch_c_i,
            DutPorts => dsp_c
        );

    u_dsp_inferred : entity work.dsp_infer
        generic map (
            WIDTH_A_G => WIDTH_A_G,
            WIDTH_B_G => WIDTH_B_G,
            WIDTH_C_G => WIDTH_C_G,
            WIDTH_P_G => WIDTH_P_G
        )
        port map (
            clk_i => clk_i,
            a_i   => dsp_a,
            b_i   => dsp_b,
            c_i   => dsp_c,
            p_o   => dsp_p
        );

    u_out_reduce_p : entity work.out_reduce
        generic map (
            Size_g => WIDTH_P_G
        )
        port map (
            Clk      => clk_i,
            Data     => out_reduce_data_p_o,
            Latch    => out_reduce_latch_p_i,
            DutPorts => dsp_p
        );

end architecture rtl;