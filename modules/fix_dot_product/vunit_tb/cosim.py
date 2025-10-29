# ---------------------------------------------------------------------------------------------------
# cosim
# ---------------------------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------------------------
# Imports
# ---------------------------------------------------------------------------------------------------
# Import python packages
import sys
import os
import numpy as np

#Import olo_fix
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "../../../submodules/open-logic/src/fix/python")))
from olo_fix import olo_fix_cosim, olo_fix_utils, olo_fix_plots
from olo_fix import olo_fix_mult, olo_fix_add
from en_cl_fix_pkg import *

def cosim(output_path : str = None, 
          generics : dict = None, 
          cosim_mode : bool = True):

    #Parse Generics
    DIMENSION_WIDTH_G = generics["DIMENSION_WIDTH_G"]

    FMT_IN_ELEMENT_A_G = olo_fix_utils.fix_format_from_string(generics["FMT_IN_ELEMENT_A_G"])
    FMT_IN_ELEMENT_B_G = olo_fix_utils.fix_format_from_string(generics["FMT_IN_ELEMENT_B_G"])
    FMT_OUT_RESULT_G = olo_fix_utils.fix_format_from_string(generics["FMT_OUT_RESULT_G"])

    print(f"DIMENSION_WIDTH_G:  {DIMENSION_WIDTH_G}");
    print(f"FMT_IN_ELEMENT_A_G: {FMT_IN_ELEMENT_A_G}");
    print(f"FMT_IN_ELEMENT_B_G: {FMT_IN_ELEMENT_B_G}");
    print(f"FMT_OUT_RESULT_G:   {FMT_OUT_RESULT_G}");
    

    Round = FixRound.Trunc_s
    Saturate = FixSaturate.Warn_s

    np.random.seed(42)  # Set the seed for reproducibility


    # Generate N vectors
    NUM_RANDOM_A = 3
    #in_vector_a_i = np.array()
    vector_a_seed = []
    vector_a_seed.append(np.full(DIMENSION_WIDTH_G ,cl_fix_max_value(FMT_IN_ELEMENT_A_G)))
    vector_a_seed.append(np.full(DIMENSION_WIDTH_G ,cl_fix_min_value(FMT_IN_ELEMENT_A_G)))
    for i in range(NUM_RANDOM_A):
        vector_a_seed.append(np.random.uniform(cl_fix_min_value(FMT_IN_ELEMENT_A_G), cl_fix_max_value(FMT_IN_ELEMENT_A_G), DIMENSION_WIDTH_G))

    vector_a_seed = np.stack(vector_a_seed)
    vector_a_seed = cl_fix_from_real(vector_a_seed, FMT_IN_ELEMENT_A_G)

    NUM_RANDOM_B = 3
    vector_b_seed = []
    vector_b_seed.append(np.full(DIMENSION_WIDTH_G ,cl_fix_max_value(FMT_IN_ELEMENT_B_G)))
    vector_b_seed.append(np.full(DIMENSION_WIDTH_G ,cl_fix_min_value(FMT_IN_ELEMENT_B_G)))
    for i in range(NUM_RANDOM_B):
        vector_b_seed.append(np.random.uniform(cl_fix_min_value(FMT_IN_ELEMENT_B_G), cl_fix_max_value(FMT_IN_ELEMENT_B_G), DIMENSION_WIDTH_G))

    vector_b_seed = np.stack(vector_b_seed)
    vector_b_seed = cl_fix_from_real(vector_b_seed, FMT_IN_ELEMENT_B_G)

    #print()
    #print(f"vector_a_seed\n {vector_a_seed}\n")
    #print(f"vector_b_seed\n {vector_b_seed}\n")

    vector_a = []
    vector_b = []
    n_a = len(vector_a_seed)
    n_b = len(vector_b_seed)
    for a_i in range(n_a):
        for b_i in range(n_b):
            vector_a.append(vector_a_seed[a_i])
            vector_b.append(vector_b_seed[b_i])

    vector_a = np.stack(vector_a)
    vector_b = np.stack(vector_b)

    #print()
    #print(f"vector_a\n {vector_a}\n")
    #print(f"vector_b\n {vector_b}\n")


    #Calculation

    MultClass = olo_fix_mult(FMT_IN_ELEMENT_A_G, FMT_IN_ELEMENT_B_G, FMT_OUT_RESULT_G, Round, Saturate)

    mult_result = []

    for a,b in zip(vector_a, vector_b):
        mult_result.append(MultClass.process(a, b))
    
    mult_result = np.stack(mult_result)

    #print(f"mult_result: {mult_result}")

    # for i in range(len(vector_a)):
    #     mult_result = MultClass.process(vector_a[i], vector_b[i])
    #     print(f"mult_result: {mult_result}")

    AddClass = olo_fix_add(FMT_OUT_RESULT_G, FMT_OUT_RESULT_G, FMT_OUT_RESULT_G, Round, Saturate)


    from functools import reduce

    result = []
    for mr in mult_result:
        result.append(reduce(AddClass.process, mr))

    result = np.stack(result)

    #print(f"result: {result}")

    #raise NotImplementedError("Work in Progress")


#    # Plot if enabled
#    if not cosim_mode:
#        py_out = in_mult_a_i * in_mult_b_i + in_add_i
#        olo_fix_plots.plot_subplots({
#                                    "Multiplication Stage" : {"in_mult_a_i" : in_mult_a_i, "in_mult_b_i" : in_mult_b_i},
#                                    "Addition Stage" : {"mult_result" : mult_result, "in_add_i" : in_add_i},
#                                    "Python vs. Fix" : {"Fix" : out_result_o, "Python" : py_out}
#        })

    #Write Files
    if cosim_mode:
        writer = olo_fix_cosim(output_path)
        writer.write_cosim_file(vector_a, FMT_IN_ELEMENT_A_G, "vector_a.fix", dim=DIMENSION_WIDTH_G)
        writer.write_cosim_file(vector_b, FMT_IN_ELEMENT_B_G, "vector_b.fix", dim=DIMENSION_WIDTH_G)
        writer.write_cosim_file(result, FMT_OUT_RESULT_G, "result.fix")
    return True

if __name__ == "__main__":
    # Example usage
    generics = {
        "DIMENSION_WIDTH_G":  4,
        "FMT_IN_ELEMENT_A_G": "(0,  4, 4)",
        "FMT_IN_ELEMENT_B_G": "(0,  4, 4)",
        "FMT_OUT_RESULT_G":   "(0, 10, 8)"
    }
    try:
        #cosim(generics=generics, cosim_mode=False)
        cosim(generics=generics, cosim_mode=True, output_path = '.')
    except NotImplementedError as e:
        print(f"Caught: {e}")
