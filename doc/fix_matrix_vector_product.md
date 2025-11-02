# fix_matrix_vector_product

[Back to **Entity List**](./entity_list.md)

VHDL Source: [fix_matrix_vector_product](../modules/fix_matrix_vector_product/rtl/fix_matrix_vector_product.vhd)

## Description

This entity performs a fixed point matrix vector product operation using NUM_DOT_PRODUCTS_G dot-product units.

For details about the fixed-point number format, refer to the
[fixed point principles](https://github.com/open-logic/open-logic/blob/main/doc/fix/olo_fix_principles.md).

## Generics

| Name                    | Type     | Default | Description                                                                                           |
|:------------------------|:---------|:--------|:------------------------------------------------------------------------------------------------------|
| NUM_DOT_PRODUCTS_G      | positive | -       | Number of dot product units availible to compute matrix vector product                                |
| MATRIX_ROW_WIDTH_G      | natural  | -       | Number of rows in *in_matrix_i* and the dimension of vector *out_result_o*                            |
| MATRIX_COLUMN_WIDTH_G   | natural  | -       | Number of columns in *in_matrix_i* and the dimension of vector *in_vector_i*                          |
| FMT_IN_MATRIX_ELEMENT_G | string   | -       | *in_matrix_i* elements format<br />String representation of an *en_cl_fix Format_t* (e.g. "(1,1,15)") |
| FMT_IN_VECTOR_ELEMENT_G | string   | -       | *in_vector_i* elements format<br />String representation of an *en_cl_fix Format_t* (e.g. "(1,1,15)") |
| FMT_OUT_RESULT_G        | string   | -       | *out_result_o* format<br />String representation of an *en_cl_fix Format_t* (e.g. "(1,1,15)")         |

## Interfaces

### Control

| Name  | In/Out | Length | Default | Description                                       |
|:------|:-------|:-------|:--------|:--------------------------------------------------|
| clk_i | in     | 1      | -       | Clock                                             |
| rst_i | in     | 1      | -       | Reset input (high-active, synchronous to *clk_i*) |

### Input Interface

| Name        | In/Out | Length                                                                        | Default | Description                                        |
|:------------|:-------|:------------------------------------------------------------------------------|:--------|:---------------------------------------------------|
| in_valid_i  | in     | 1                                                                             | '1'     | AXI4-Stream handshaking signal for input interface |
| in_ready_o  | out    | 1                                                                             | N/A     | AXI4-Stream handshaking signal for input interface |
| in_matrix_i | in     | *MATRIX_ROW_WIDTH_G x MATRIX_COLUMN_WIDTH_G x width(FMT_IN_MATRIX_ELEMENT_G)* | -       | Input matrix for matrix-vector computation.        |
| in_vectori  | in     | *MATRIX_COLUMN_WIDTH_G x width(FMT_IN_VECTOR_ELEMENT_G)*                      | -       | Input vector for matrix-vector computation.        |

### Output Interface

| Name         | In/Out | Length                                         | Default | Description                                                                                          |
|:-------------|:-------|:-----------------------------------------------|:--------|:-----------------------------------------------------------------------------------------------------|
| out_valid_o  | out    | 1                                              | N/A     | AXI4-Stream handshaking signal for outputs                                                           |
| out_error_o  | out    | 1                                              | N/A     | Error indicator. If asserted, *out_valid_o* will not be asserted for the corresponding input values. |
| out_result_o | out    | *MATRIX_ROW_WIDTH_G x width(FMT_OUT_RESULT_G)* | N/A     | Dot product result output.                                                                           |
