--------------------------------------------------------------------------------
-- fix_dsp_mac
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Libraries
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library olo;
use olo.en_cl_fix_pkg.all;
use olo.olo_fix_pkg.all;

-- library work;
-- use work.fix_dsp_mac_formats_pkg.all;

--------------------------------------------------------------------------------
-- Entitity
--------------------------------------------------------------------------------
entity fix_dsp_mac is
    generic(
        FMT_MULT_A_G      : string := "(0, 2, 2)";
        FMT_MULT_B_G      : string := "(0, 2, 2)";
        FMT_ADD_G         : string := "(0, 4, 4)";
        FMT_RESULT_G      : string := "(0, 5, 4)"
    );
    port (
        clk_i    : in std_logic;
        rst_i    : in std_logic;
        mult_a_i : in std_logic_vector(fixFmtWidthFromString(FMT_MULT_A_G) - 1 downto 0);
        mult_b_i : in std_logic_vector(fixFmtWidthFromString(FMT_MULT_B_G) - 1 downto 0);
        add_i    : in  std_logic_vector(fixFmtWidthFromString(FMT_ADD_G) - 1 downto 0);
        result_o : out std_logic_vector(fixFmtWidthFromString(FMT_RESULT_G) - 1 downto 0)
    );
end entity fix_dsp_mac;

architecture rtl of fix_dsp_mac is

    -- attribute use_dsp : string;
    -- attribute use_dsp of p_o : signal is "yes";

    constant FMT_MULT_A_C      : FixFormat_t := (0, 2, 2);
    constant FMT_MULT_B_C      : FixFormat_t := (0, 2, 2);
    constant FMT_ADD_C         : FixFormat_t := (0, 4, 4);
    constant FMT_MULT_RESULT_C : FixFormat_t := cl_fix_mult_fmt(FMT_MULT_A_C, FMT_MULT_B_C);
    constant FMT_MAC_RESULT_C  : FixFormat_t := cl_fix_add_fmt(FMT_ADD_C, FMT_MULT_RESULT_C);

    signal mult_result : std_logic_vector(fixFmtWidthFromString(FMT_ADD_G) - 1 downto 0);
begin

    u_olo_fix_mult : entity olo.olo_fix_mult
        generic map (
            AFmt_g      => FMT_MULT_A_G,
            BFmt_g      => FMT_MULT_B_G,
            ResultFmt_g => FMT_ADD_G,
            Round_g     => "NonSymPos_s",
            Saturate_g  => "Sat_s",
            OpRegs_g    => 0,
            RoundReg_g  => "NO",
            SatReg_g    => "NO"
        )
        port map (
            Clk => clk_i,
            Rst => rst_i,

            In_A => mult_a_i,
            In_B => mult_b_i,

            Out_Result => mult_result
        );

    u_olo_fix_add : entity olo.olo_fix_add
        generic map (
            AFmt_g      => FMT_ADD_G,
            BFmt_g      => FMT_ADD_G,
            ResultFmt_g => FMT_RESULT_G,
            Round_g     => "Trunc_s",
            Saturate_g  => "Warn_s",
            OpRegs_g    => 1,
            RoundReg_g  => "NO",
            SatReg_g    => "NO"
        )
        port map (
            Clk => clk_i,
            Rst => rst_i,

            In_A => mult_result,
            In_B => add_i,

            Out_Result => result_o
        );

end architecture rtl;
