# DSP Task

[**Entity List**](./doc/entity_list.md)

##  Purpose

The goal of this repository is to design and implement an efficient matrix–vector multiplication architecture in HDL that is fully synthesizable and can be deployed on an FPGA.

The design aims to minimize the number of DSP slices required to compute a matrix–vector product within a specified number of clock cycles.

If there were no constraints on the number of clock cycles available for the computation, the matrix-vector multiplication could be performed using only a single DSP slice.


### Problem Description

The task is to compute the matrix–vector product:

$$
\mathbf{y} = \mathbf{M} \mathbf{x},
$$

where

- $\mathbf{M} = [m_{ij}]$ is a matrix of size $ROW \times COL$
- $\mathbf{x} = [x_0, x_1, \dots, x_{\text{COL-1}}]^T$ is a column vector
- $\mathbf{y} = [y_0, y_1, \dots, y_{\text{ROW-1}}]^T$ is a column vector

Each element of the output vector $\mathbf{y}$ is obtained by taking the **dot product** of one row of $\mathbf{M}$ with the vector $\mathbf{x}$.

$$
y_i = \sum_{j=0}^{\text{COL-1}} m_{ij} \cdot x_j \quad \text{for } i = 0, 1, \dots, \text{ROW-1}.
$$

### Hardware Implementation

because matrix vector multiplication is just ROW independent calculation of dot product between matrix M row and vector x, we can first focus on implementing efficient dot product module, which will use just one MAC (Multiply and Accumulate) module.

To calculate 

$$
y_i = \sum_{j=0}^{\text{COL-1}} a_{ij} \cdot x_j
$$

we have COL multiplications. while we have Multiply and Accumulate module, we can multiply aij and xj each clock cycle and add the result of multiplication for previous clock cycle (accumulation)

