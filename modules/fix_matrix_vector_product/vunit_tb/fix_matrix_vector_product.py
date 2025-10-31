################################################################################
# fix_matrix_vector_product.py
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
# Classes
################################################################################
class FixDotProduct:
    """
    Fixed Point Dot Product
    """

    # --------------------------------------------------------------------------
    # Constructor
    # --------------------------------------------------------------------------
    def __init__(self,
                 fmt_a      : FixFormat,
                 fmt_b      : FixFormat,
                 fmt_result : FixFormat,
                 round      : FixRound    = FixRound.Trunc_s,
                 saturate   : FixSaturate = FixSaturate.Warn_s
        ):
        """
        Constructor of the FixDotProduct class
        :param fmt_a:      Format of the a input
        :param fmt_b:      Format of the b input
        :param fmt_result: Format of the result
        :param round:      Rounding mode
        :param saturate:   Saturation mode
        """
        self._fmt_a = fmt_a
        self._fmt_b = fmt_b
        self._fmt_result = fmt_result
        self._round = round
        self._saturate = saturate

        # Initialize fixed point multiplier and adder
        self._fix_mult = olo_fix_mult(self._fmt_a, self._fmt_b, self._fmt_result, self._round, self._saturate)
        self._fix_add = olo_fix_add(self._fmt_result, self._fmt_result, self._fmt_result, self._round, self._saturate)

    def calc(self, vector_a, vector_b):
        """
        Calculate dot product
        :param vector_a: Input a
        :param vector_b: Input b
        :return:         Result
        """    

        # Basic validation
        if len(vector_a) == 0 or len(vector_b) == 0:
            raise ValueError("Input vectors cannot be empty.")
        if len(vector_a) != len(vector_b):
            raise ValueError(f"Input vectors must have the same length (got {len(vector_a)} and {len(vector_b)}).")
    
        # Multiply element-wise
        mult_result = [self._fix_mult.process(a, b) for a, b in zip(vector_a, vector_b)]
    
        # Accumulate the sum
        result = mult_result[0]
        for val in mult_result[1:]:
            result = self._fix_add.process(result, val)
    
        return result

class MatrixVectorProduct:
    """
    Fixed Point Matrix Vector Product
    """
    # --------------------------------------------------------------------------
    # Constructor
    # --------------------------------------------------------------------------
    def __init__(self,
                 fmt_matrix : FixFormat,
                 fmt_vector : FixFormat,
                 fmt_result : FixFormat,
                 round      : FixRound    = FixRound.Trunc_s,
                 saturate   : FixSaturate = FixSaturate.Warn_s
        ):
        """
        Constructor of the MatrixVectorProduct class
        :param fmt_matrix: Format of the matrix input
        :param fmt_vector: Format of the vector input
        :param fmt_result: Format of the result
        :param round:      Rounding mode
        :param saturate:   Saturation mode
        """
        self._fmt_matrix = fmt_matrix
        self._fmt_vector = fmt_vector
        self._fmt_result = fmt_result
        self._round = round
        self._saturate = saturate

        # Initialize fixed point dot product
        self._fix_dot_product = FixDotProduct(self._fmt_matrix, self._fmt_vector, self._fmt_result, self._round, self._saturate)
    
    def calc(self, matrix, vector):
        # Basic validation
        if len(matrix[0]) != len(vector):
            raise ValueError(
                f"Matrix column count ({len(matrix[0])}) must match vector length ({len(vector)})."
            )

        # Compute dot product for each row
        result = []
        for row in matrix:
            dot_val = self._fix_dot_product.calc(row, vector)
            result.append(dot_val)
    
        return result

################################################################################
# Functions
################################################################################
def cosim(output_path : str = None, 
          generics : dict = None, 
          cosim_mode : bool = True):

    #Parse Generics

    COSIM_NUM_TEST_VECTORS_G = generics["COSIM_NUM_TEST_VECTORS_G"]
    COSIM_MATRIX_TYPE_G = generics["COSIM_MATRIX_TYPE_G"]

    MATRIX_ROW_WIDTH_G =    generics["MATRIX_ROW_WIDTH_G"]
    MATRIX_COLUMN_WIDTH_G = generics["MATRIX_COLUMN_WIDTH_G"]

    FMT_IN_MATRIX_ELEMENT_G = olo_fix_utils.fix_format_from_string(generics["FMT_IN_MATRIX_ELEMENT_G"])
    FMT_IN_VECTOR_ELEMENT_G = olo_fix_utils.fix_format_from_string(generics["FMT_IN_VECTOR_ELEMENT_G"])
    FMT_OUT_RESULT_G =        olo_fix_utils.fix_format_from_string(generics["FMT_OUT_RESULT_G"])

    print(f"MATRIX_ROW_WIDTH_G:      {MATRIX_ROW_WIDTH_G}");
    print(f"MATRIX_COLUMN_WIDTH_G:   {MATRIX_COLUMN_WIDTH_G}");
    print(f"FMT_IN_MATRIX_ELEMENT_G: {FMT_IN_MATRIX_ELEMENT_G}");
    print(f"FMT_IN_VECTOR_ELEMENT_G: {FMT_IN_VECTOR_ELEMENT_G}");
    print(f"FMT_OUT_RESULT_G:        {FMT_OUT_RESULT_G}");
    
    Round = FixRound.Trunc_s
    Saturate = FixSaturate.Warn_s

    np.random.seed(42)  # Set the seed for reproducibility

    # Generate test vectors
    if COSIM_NUM_TEST_VECTORS_G > 2:
        NUM_RANDOM_VECTOR = COSIM_NUM_TEST_VECTORS_G - 2
    else:
        NUM_RANDOM_VECTOR = 0
    in_vector = []
    in_vector.append(np.full(MATRIX_COLUMN_WIDTH_G ,cl_fix_max_value(FMT_IN_VECTOR_ELEMENT_G)))
    in_vector.append(np.full(MATRIX_COLUMN_WIDTH_G ,cl_fix_min_value(FMT_IN_VECTOR_ELEMENT_G)))
    for i in range(NUM_RANDOM_VECTOR):
        in_vector.append(np.random.uniform(cl_fix_min_value(FMT_IN_VECTOR_ELEMENT_G), cl_fix_max_value(FMT_IN_VECTOR_ELEMENT_G), MATRIX_COLUMN_WIDTH_G))

    in_vector = np.stack(in_vector)
    in_vector = cl_fix_from_real(in_vector, FMT_IN_VECTOR_ELEMENT_G)

    matrix_bit_step = 2**(-FMT_IN_MATRIX_ELEMENT_G.F)
    if COSIM_MATRIX_TYPE_G == "ASCENDING":
        in_matrix = [[cl_fix_min_value(FMT_IN_MATRIX_ELEMENT_G) + (col + row*MATRIX_COLUMN_WIDTH_G) * matrix_bit_step for col in range(MATRIX_COLUMN_WIDTH_G)] for row in range(MATRIX_ROW_WIDTH_G)]
        in_matrix = np.stack(in_matrix)
    elif COSIM_MATRIX_TYPE_G == "DESCENDING":
        in_matrix = [[cl_fix_max_value(FMT_IN_MATRIX_ELEMENT_G) - (col + row*MATRIX_COLUMN_WIDTH_G) * matrix_bit_step for col in range(MATRIX_COLUMN_WIDTH_G)] for row in range(MATRIX_ROW_WIDTH_G)]
        in_matrix = np.stack(in_matrix)
    else:
        raise ValueError(
            f"Invalid COSIM_MATRIX_TYPE_G='{COSIM_MATRIX_TYPE_G}'. "
            f"Expected one of: ['ASCENDING', 'DESCENDING']."
        )

    matrix_vector_product = MatrixVectorProduct(FMT_IN_MATRIX_ELEMENT_G, FMT_IN_VECTOR_ELEMENT_G, FMT_OUT_RESULT_G);

    result = []
    for v in in_vector:
        result.append(matrix_vector_product.calc(in_matrix, v))

    result = np.stack(result)

    if not cosim_mode:
        print()
        print(f"in_vector\n {in_vector}\n")
        print()
        print(f"in_matrix\n {in_matrix}\n")

    #Write Files
    if cosim_mode:
        writer = olo_fix_cosim(output_path)
        writer.write_cosim_file(in_vector, FMT_IN_VECTOR_ELEMENT_G, "in_vector.fix", dim=MATRIX_COLUMN_WIDTH_G)
        writer.write_cosim_file(result, FMT_OUT_RESULT_G, "result.fix", dim=MATRIX_ROW_WIDTH_G)
    return True

################################################################################
# Main
################################################################################
if __name__ == "__main__":
    # Example usage
    generics = {
        "COSIM_NUM_TEST_VECTORS_G"  : 5,
        "COSIM_MATRIX_TYPE_G"       : "ASCENDING",
        "MATRIX_ROW_WIDTH_G"        : 4,
        "MATRIX_COLUMN_WIDTH_G"     : 4,
        "FMT_IN_MATRIX_ELEMENT_G"   : "(0,  4, 1)",
        "FMT_IN_VECTOR_ELEMENT_G"   : "(0,  4, 1)",
        "FMT_OUT_RESULT_G"          : "(0, 10, 2)"
    }
    try:
        cosim(generics=generics, cosim_mode=False)
    except NotImplementedError as e:
        print(f"Caught: {e}")