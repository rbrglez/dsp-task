# fix_dsp_mac

[Back to **Entity List**](./entity_list.md)

VHDL Source: [fix_dsp_mac](../modules/fix_dsp_mac/rtl/fix_dsp_mac.vhd)

## Description

This entity performs a fixed-point multiply-accumulate (MAC) operation. 
It multiplies two fixed-point numbers and adds the result to an accumulated value.

With the default values of the MULT_* and ADD_* generics, the module has a latency of 1 clock cycle

> **Warning:**
> This module has been verified only with the default values of the *MULT\_\** and *ADD\_\** generics.
> If you modify these generics, you must thoroughly test the design to ensure correct functionality and timing.

For details about the fixed-point number format, refer to the
[fixed point principles](../submodules/open-logic/doc/fix/olo_fix_principles.md).

![Waveform](./fix_dsp_mac/fix_dsp_mac_tb.png)

## Generics

### Format

| Name         | Type   | Default | Description                                                                                   |
|:-------------|:-------|:--------|:----------------------------------------------------------------------------------------------|
| FMT_MULT_A_G | string | -       | *in_mult_a_i* format<br />String representation of an *en_cl_fix Format_t* (e.g. "(1,1,15)")  |
| FMT_MULT_B_G | string | -       | *in_mult_b_i* format<br />String representation of an *en_cl_fix Format_t* (e.g. "(1,1,15)")  |
| FMT_ADD_G    | string | -       | *in_add_i* format<br />String representation of an *en_cl_fix Format_t* (e.g. "(1,1,15)")     |
| FMT_RESULT_G | string | -       | *out_result_o* format<br />String representation of an *en_cl_fix Format_t* (e.g. "(1,1,15)") |

### Multiplication

| Name             | Type    | Default   | Description                                                                                                                                                                                             |
|:-----------------|:--------|:----------|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| MULT_ROUND_G     | string  | "Trunc_s" | Rounding mode<br />String representation of an _en_cl_fix FixRound_t_.                                                                                                                                  |
| MULT_SATURATE_G  | string  | "Warn_s"  | Saturation mode<br />String representation of an _en_cl_fix FixSaturate_t_.                                                                                                                             |
| MULT_OP_REGS_G   | natural | 0         | Number of pipeline stages for the operation                                                                                                                                                             |
| MULT_ROUND_REG_G | string  | "NO"      | Presence of rounding pipeline stage<br />"YES": Always implement register<br />"NO": Never implement register<br />"AUTO": Implement register if rounding is needed according to the formats chosen     |
| MULT_SAT_REG_G   | string  | "NO"      | Presence of saturation pipeline stage<br />"YES": Always implement register<br />"NO": Never implement register<br />"AUTO": Implement register if saturation is needed according to the formats chosen |

### Addition

| Name            | Type    | Default   | Description                                                                                                                                                                                             |
|:----------------|:--------|:----------|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| ADD_ROUND_G     | string  | "Trunc_s" | Rounding mode<br />String representation of an _en_cl_fix FixRound_t_.                                                                                                                                  |
| ADD_SATURATE_G  | string  | "Warn_s"  | Saturation mode<br />String representation of an _en_cl_fix FixSaturate_t_.                                                                                                                             |
| ADD_OP_REGS_G   | natural | 1         | Number of pipeline stages for the operation                                                                                                                                                             |
| ADD_ROUND_REG_G | string  | "NO"      | Presence of rounding pipeline stage<br />"YES": Always implement register<br />"NO": Never implement register<br />"AUTO": Implement register if rounding is needed according to the formats chosen     |
| ADD_SAT_REG_G   | string  | "NO"      | Presence of saturation pipeline stage<br />"YES": Always implement register<br />"NO": Never implement register<br />"AUTO": Implement register if saturation is needed according to the formats chosen |

## Interfaces

### Control

| Name  | In/Out | Length | Default | Description                                       |
|:------|:-------|:-------|:--------|:--------------------------------------------------|
| clk_i | in     | 1      | -       | Clock                                             |
| rst_i | in     | 1      | -       | Reset input (high-active, synchronous to *clk_i*) |

### Input Interface

| Name        | In/Out | Length                | Default | Description                                                                      |
|:------------|:-------|:----------------------|:--------|:---------------------------------------------------------------------------------|
| in_valid_i  | in     | 1                     | '1'     | AXI4-Stream handshaking signal for inputs                                        |
| in_mult_a_i | in     | *width(FMT_MULT_A_G)* | -       | First input operand for multiplication.<br />Format: *FMT_MULT_A_G*              |
| in_mult_b_i | in     | *width(FMT_MULT_B_G)* | -       | Second input operand for multiplication.<br />Format: *FMT_MULT_B_G*             |
| in_add_i    | in     | *width(FMT_ADD_G)*    | -       | Input operand to be added to the multiplication result.<br />Format: *FMT_ADD_G* |

### Output Interface

| Name         | In/Out | Length                | Default | Description                                             |
|:-------------|:-------|:----------------------|:--------|:--------------------------------------------------------|
| out_valid_o  | out    | 1                     | N/A     | AXI4-Stream handshaking signal for outputs              |
| out_result_o | out    | *width(FMT_RESULT_G)* | N/A     | Output of the computation (multiplication and addition) |
