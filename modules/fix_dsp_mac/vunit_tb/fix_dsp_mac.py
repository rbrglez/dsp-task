################################################################################
# fix_dsp_mac.py
################################################################################

################################################################################
# Imports
################################################################################
# Import python packages
import sys
import os
import numpy as np

#Import olo_fix
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "../../../submodules/open-logic/src/fix/python")))
from olo_fix import olo_fix_cosim, olo_fix_utils, olo_fix_plots
from olo_fix import olo_fix_mult, olo_fix_add
from en_cl_fix_pkg import *

################################################################################
# Functions
################################################################################
def cosim(output_path : str = None, 
          generics : dict = None, 
          cosim_mode : bool = True):

    #Parse Generics
    FMT_MULT_A_G = olo_fix_utils.fix_format_from_string(generics["FMT_MULT_A_G"])
    FMT_MULT_B_G = olo_fix_utils.fix_format_from_string(generics["FMT_MULT_B_G"])
    FMT_ADD_G = olo_fix_utils.fix_format_from_string(generics["FMT_ADD_G"])
    FMT_RESULT_G = olo_fix_utils.fix_format_from_string(generics["FMT_RESULT_G"])

    FMT_MULT_RESULT = cl_fix_mult_fmt(FMT_MULT_A_G, FMT_MULT_B_G)

    Round = FixRound.Trunc_s
    Saturate = FixSaturate.Warn_s

    #Calculation
    np.random.seed(42)  # Set the seed for reproducibility
    in_mult_a_i = np.linspace(cl_fix_min_value(FMT_MULT_A_G), cl_fix_max_value(FMT_MULT_A_G), 100)
    in_mult_a_i = np.concatenate([
        np.linspace(cl_fix_min_value(FMT_MULT_A_G), cl_fix_max_value(FMT_MULT_A_G), 100, endpoint=False),
        np.random.uniform(low=cl_fix_min_value(FMT_MULT_A_G), high=cl_fix_max_value(FMT_MULT_A_G), size = 100)
    ])
    in_mult_a_i = cl_fix_from_real(in_mult_a_i, FMT_MULT_A_G)

    in_mult_b_i = np.concatenate([
        np.linspace(cl_fix_min_value(FMT_MULT_B_G), cl_fix_max_value(FMT_MULT_B_G), 50, endpoint=False),
        np.linspace(cl_fix_max_value(FMT_MULT_B_G), cl_fix_min_value(FMT_MULT_B_G), 50),
        np.random.uniform(low=cl_fix_min_value(FMT_MULT_B_G), high=cl_fix_max_value(FMT_MULT_B_G), size = 100)
    ])
    in_mult_b_i = cl_fix_from_real(in_mult_b_i, FMT_MULT_B_G)

    in_add_i = np.concatenate([
        np.linspace(cl_fix_min_value(FMT_ADD_G), cl_fix_max_value(FMT_ADD_G), 50, endpoint=False),
        np.linspace(cl_fix_max_value(FMT_ADD_G), cl_fix_min_value(FMT_ADD_G), 50),
        np.random.uniform(low=cl_fix_min_value(FMT_ADD_G), high=cl_fix_max_value(FMT_ADD_G), size = 100)
    ])

    in_add_i = cl_fix_from_real(in_add_i, FMT_ADD_G)

    MultClass = olo_fix_mult(FMT_MULT_A_G, FMT_MULT_B_G, FMT_MULT_RESULT, Round, Saturate)
    mult_result = MultClass.process(in_mult_a_i, in_mult_b_i)

    AddClass = olo_fix_add(FMT_MULT_RESULT, FMT_ADD_G, FMT_RESULT_G, Round, Saturate)
    out_result_o = AddClass.process(mult_result, in_add_i)

    # Plot if enabled
    if not cosim_mode:
        py_out = in_mult_a_i * in_mult_b_i + in_add_i
        olo_fix_plots.plot_subplots({
                                    "Multiplication Stage" : {"in_mult_a_i" : in_mult_a_i, "in_mult_b_i" : in_mult_b_i},
                                    "Addition Stage" : {"mult_result" : mult_result, "in_add_i" : in_add_i},
                                    "Python vs. Fix" : {"Fix" : out_result_o, "Python" : py_out}
        })

    #Write Files
    if cosim_mode:
        writer = olo_fix_cosim(output_path)
        writer.write_cosim_file(in_mult_a_i, FMT_MULT_A_G, "in_mult_a_i.fix")
        writer.write_cosim_file(in_mult_b_i, FMT_MULT_B_G, "in_mult_b_i.fix")
        writer.write_cosim_file(in_add_i, FMT_ADD_G, "in_add_i.fix")
        writer.write_cosim_file(out_result_o, FMT_RESULT_G, "out_result_o.fix")
    return True

################################################################################
# Main
################################################################################
if __name__ == "__main__":
    # Example usage
    generics = {
        "FMT_MULT_A_G": "(0, 4, 4)",
        "FMT_MULT_B_G": "(0, 4, 4)",
        "FMT_ADD_G": "(0, 8, 8)",
        "FMT_RESULT_G": "(0, 9, 8)"
    }
    try:
        cosim(generics=generics, cosim_mode=False)
    except NotImplementedError as e:
        print(f"Caught: {e}")
