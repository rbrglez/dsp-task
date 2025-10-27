---------------------------------------------------------------------------------------------------
-- fix_dsp_mac_formats_pkg
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- Libraries
---------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library olo;
use olo.en_cl_fix_pkg.all;

---------------------------------------------------------------------------------------------------
-- Package Header
---------------------------------------------------------------------------------------------------
package fix_dsp_mac_formats_pkg is

    constant FMT_MULT_A_C      : FixFormat_t := (0, 2, 2);
    constant FMT_MULT_B_C      : FixFormat_t := (0, 2, 2);
    constant FMT_ADD_C         : FixFormat_t := (0, 4, 4);
    constant FMT_MULT_RESULT_C : FixFormat_t := cl_fix_mult_fmt(FMT_MULT_A_C, FMT_MULT_B_C);
    constant FMT_MAC_RESULT_C  : FixFormat_t := cl_fix_add_fmt(FMT_ADD_C, FMT_MULT_RESULT_C);

end package;

---------------------------------------------------------------------------------------------------
-- Package Body
---------------------------------------------------------------------------------------------------
package body fix_dsp_mac_formats_pkg is

end package body;