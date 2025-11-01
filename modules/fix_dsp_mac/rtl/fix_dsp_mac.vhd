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

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity fix_dsp_mac is
    generic(
        FMT_MULT_A_G : string := "(0, 2, 2)";
        FMT_MULT_B_G : string := "(0, 2, 2)";
        FMT_ADD_G    : string := "(0, 4, 4)";
        FMT_RESULT_G : string := "(0, 5, 4)";

        MULT_ROUND_G     : string  := FixRound_Trunc_c;
        MULT_SATURATE_G  : string  := FixSaturate_Warn_c;
        MULT_OP_REGS_G   : natural := 0;
        MULT_ROUND_REG_G : string  := "NO";
        MULT_SAT_REG_G   : string  := "NO";

        ADD_ROUND_G     : string  := FixRound_Trunc_c;
        ADD_SATURATE_G  : string  := FixSaturate_Warn_c;
        ADD_OP_REGS_G   : natural := 1;
        ADD_ROUND_REG_G : string  := "NO";
        ADD_SAT_REG_G   : string  := "NO"
    );
    port (
        clk_i : in std_logic;
        rst_i : in std_logic;

        ------------------------------------------------------------------------
        -- Input Interface
        ------------------------------------------------------------------------
        in_valid_i  : in std_logic := '1';
        in_mult_a_i : in std_logic_vector(fixFmtWidthFromString(FMT_MULT_A_G) - 1 downto 0);
        in_mult_b_i : in std_logic_vector(fixFmtWidthFromString(FMT_MULT_B_G) - 1 downto 0);
        in_add_i    : in std_logic_vector(fixFmtWidthFromString(FMT_ADD_G) - 1 downto 0);

        ------------------------------------------------------------------------
        -- Output Interface
        ------------------------------------------------------------------------
        out_valid_o  : out std_logic;
        out_result_o : out std_logic_vector(fixFmtWidthFromString(FMT_RESULT_G) - 1 downto 0)
    );
end entity fix_dsp_mac;

architecture rtl of fix_dsp_mac is

    ----------------------------------------------------------------------------
    -- Constants
    ----------------------------------------------------------------------------
    constant FIX_FMT_MULT_A_C : FixFormat_t := cl_fix_format_from_string(FMT_MULT_A_G);
    constant FIX_FMT_MULT_B_C : FixFormat_t := cl_fix_format_from_string(FMT_MULT_B_G);

    constant FMT_MULT_RESULT_C : string := to_string(cl_fix_mult_fmt(FIX_FMT_MULT_A_C, FIX_FMT_MULT_B_C));

    ----------------------------------------------------------------------------
    -- Instantiation signals
    ----------------------------------------------------------------------------
    signal mult_valid  : std_logic;
    signal mult_result : std_logic_vector(fixFmtWidthFromString(FMT_MULT_RESULT_C) - 1 downto 0);

begin

    u_olo_fix_mult : entity olo.olo_fix_mult
        generic map (
            AFmt_g      => FMT_MULT_A_G,
            BFmt_g      => FMT_MULT_B_G,
            ResultFmt_g => FMT_MULT_RESULT_C,
            Round_g     => MULT_ROUND_G,
            Saturate_g  => MULT_SATURATE_G,
            OpRegs_g    => MULT_OP_REGS_G,
            RoundReg_g  => MULT_ROUND_REG_G,
            SatReg_g    => MULT_SAT_REG_G
        )
        port map (
            Clk => clk_i,
            Rst => rst_i,

            In_Valid => in_valid_i,
            In_A     => in_mult_a_i,
            In_B     => in_mult_b_i,

            Out_Valid  => mult_valid,
            Out_Result => mult_result
        );

    u_olo_fix_add : entity olo.olo_fix_add
        generic map (
            AFmt_g      => FMT_MULT_RESULT_C,
            BFmt_g      => FMT_ADD_G,
            ResultFmt_g => FMT_RESULT_G,
            Round_g     => ADD_ROUND_G,
            Saturate_g  => ADD_SATURATE_G,
            OpRegs_g    => ADD_OP_REGS_G,
            RoundReg_g  => ADD_ROUND_REG_G,
            SatReg_g    => ADD_SAT_REG_G
        )
        port map (
            Clk => clk_i,
            Rst => rst_i,

            In_Valid => mult_valid,
            In_A     => mult_result,
            In_B     => in_add_i,

            Out_Valid  => out_valid_o,
            Out_Result => out_result_o
        );

end architecture rtl;
