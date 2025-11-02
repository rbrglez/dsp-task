# DSP Task

[**Entity List**](./doc/entity_list.md)

##  Purpose

The goal of this repository is to design and implement an efficient matrix–vector multiplication architecture in HDL that is fully synthesizable and can be deployed on an FPGA.

The design aims to minimize the number of DSP slices required to compute a matrix–vector product within a specified number of clock cycles.

If there were no constraints on the number of clock cycles available for the computation, the matrix-vector multiplication could be performed using only a single DSP slice.

## How to Use

This repository uses FuseSoC to gather and manage the HDL sources and to generate a Vivado project for synthesis or simulation.

For self-checking testbenches, the repository uses VUnit, enabling automated simulation and verification of the designs.