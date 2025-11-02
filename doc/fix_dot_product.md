# fix_dot_product

[Back to **Entity List**](./entity_list.md)

VHDL Source: [fix_dot_product](../modules/fix_dot_product/rtl/fix_dot_product.vhd)

## Description

This entity performs a fixed-point dot product operation using a single multiply and accumulate (MAC) unit.
The computation of the dot product requires DIMENSION_WIDTH_G + 1 clock cycles to complete.

For details about the fixed-point number format, refer to the
[fixed point principles](https://github.com/open-logic/open-logic/blob/main/doc/fix/olo_fix_principles.md).

## Generics

| Name               | Type    | Default | Description                                                                                             |
|:-------------------|:--------|:--------|:--------------------------------------------------------------------------------------------------------|
| DIMENSION_WIDTH_G  | natural | -       | Number of elements in *in_vector_a_i* and *in_vector_b_i*                                               |
| FMT_IN_ELEMENT_A_G | string  | -       | *in_vector_a_i* elements format<br />String representation of an *en_cl_fix Format_t* (e.g. "(1,1,15)") |
| FMT_IN_ELEMENT_B_G | string  | -       | *in_vector_b_i* elements format<br />String representation of an *en_cl_fix Format_t* (e.g. "(1,1,15)") |
| FMT_OUT_RESULT_G   | string  | -       | *out_result_o* format<br />String representation of an *en_cl_fix Format_t* (e.g. "(1,1,15)")           |

## Interfaces

### Control

| Name  | In/Out | Length | Default | Description                                       |
|:------|:-------|:-------|:--------|:--------------------------------------------------|
| clk_i | in     | 1      | -       | Clock                                             |
| rst_i | in     | 1      | -       | Reset input (high-active, synchronous to *clk_i*) |

### Input Interface

| Name          | In/Out | Length                                          | Default | Description                                        |
|:--------------|:-------|:------------------------------------------------|:--------|:---------------------------------------------------|
| in_valid_i    | in     | 1                                               | '1'     | AXI4-Stream handshaking signal for input interface |
| in_ready_o    | out    | 1                                               | N/A     | AXI4-Stream handshaking signal for input interface |
| in_vector_a_i | in     | *DIMENSION_WIDTH_G x width(FMT_IN_ELEMENT_A_G)* | -       | Input vector A for dot-product computation.        |
| in_vector_b_i | in     | *DIMENSION_WIDTH_G x width(FMT_IN_ELEMENT_B_G)* | -       | Input vector A for dot-product computation.        |

### Output Interface

| Name         | In/Out | Length                    | Default | Description                                |
|:-------------|:-------|:--------------------------|:--------|:-------------------------------------------|
| out_valid_o  | out    | 1                         | N/A     | AXI4-Stream handshaking signal for outputs |
| out_result_o | out    | *width(FMT_OUT_RESULT_G)* | N/A     | Dot product result output.                 |
