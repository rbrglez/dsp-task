################################################################################
# modules.py
################################################################################

################################################################################
# Imports
################################################################################
from .utils import named_config, make_short_name
import sys
import os

# Import for fix cosimulations
sys.path.append(os.path.join(os.path.dirname(__file__), '../..'))
from modules import *

################################################################################
# Functionality
################################################################################

def add_configs(lib):
    """
    Add all base testbench configurations to the VUnit Library
    :param lib: Testbench library
    """

    ############################################################################
    # fix_dsp_mac 
    ############################################################################
    tb = lib.test_bench('fix_dsp_mac_vunit_tb')
    cosim = fix_dsp_mac.vunit_tb.fix_dsp_mac.cosim

    generics = {
        'FMT_MULT_A_G' : '(0,4,4)',
        'FMT_MULT_B_G' : '(0,4,4)',
        'FMT_ADD_G'    : '(0,8,8)',
        'FMT_RESULT_G' : '(0,9,8)',
    }
    named_config(tb, generics, pre_config=cosim)

    generics = {
        'FMT_MULT_A_G' : '(1,5,8)',
        'FMT_MULT_B_G' : '(1,7,9)',
        'FMT_ADD_G'    : '(1,13,17)',
        'FMT_RESULT_G' : '(1,14,17)',
    }
    named_config(tb, generics, pre_config=cosim)

    generics = {
        'FMT_MULT_A_G' : '(0,11,-4)',
        'FMT_MULT_B_G' : '(1,6,2)',
        'FMT_ADD_G'    : '(0,4,5)',
        'FMT_RESULT_G' : '(1,17,5)',
    }
    named_config(tb, generics, pre_config=cosim)

    ############################################################################
    # fix_dot_product
    ############################################################################
    tb = lib.test_bench('fix_dot_product_vunit_tb')
    cosim = fix_dot_product.vunit_tb.fix_dot_product.cosim

    generics = {
        'DIMENSION_WIDTH_G' : 4,
        'FMT_IN_ELEMENT_A_G': '(0,4,4)',
        'FMT_IN_ELEMENT_B_G': '(0,4,4)',
        'FMT_OUT_RESULT_G'  : '(0,10,8)',
    }
    named_config(tb, generics, pre_config=cosim)

    generics = {
        'DIMENSION_WIDTH_G' : 32,
        'FMT_IN_ELEMENT_A_G': '(1,3,2)',
        'FMT_IN_ELEMENT_B_G': '(1,5,8)',
        'FMT_OUT_RESULT_G'  : '(1,13,10)',
    }
    named_config(tb, generics, pre_config=cosim)

    generics = {
        'DIMENSION_WIDTH_G' : 100,
        'FMT_IN_ELEMENT_A_G': '(1,7,-2)',
        'FMT_IN_ELEMENT_B_G': '(0,2,8)',
        'FMT_OUT_RESULT_G'  : '(0,16,6)',
    }
    named_config(tb, generics, pre_config=cosim)

    ############################################################################
    # fix_matrix_vector_product
    ############################################################################
    tb = lib.test_bench('fix_matrix_vector_product_vunit_tb')
    cosim = fix_matrix_vector_product.vunit_tb.fix_matrix_vector_product.cosim

    ## Need to shorten generics, because of file name limit
    generic_aliases = {
        'COSIM_NUM_TEST_VECTORS_G' : 'NUM_SAMPLES',
        'COSIM_MATRIX_TYPE_G'      : 'MATRIX_TYPE',
        'NUM_DOT_PRODUCTS_G'       : 'DSPs',
        'MATRIX_ROW_WIDTH_G'       : 'ROWs',
        'MATRIX_COLUMN_WIDTH_G'    : 'COLs',
        'FMT_IN_MATRIX_ELEMENT_G'  : 'FMT_MATRIX',
        'FMT_IN_VECTOR_ELEMENT_G'  : 'FMT_VECTOR',
        'FMT_OUT_RESULT_G'         : 'FMT_RESULT',
    }

    generics = {
        'COSIM_NUM_TEST_VECTORS_G' : 16,
        'COSIM_MATRIX_TYPE_G'      : 'DESCENDING',
        'NUM_DOT_PRODUCTS_G'       : 11,
        'MATRIX_ROW_WIDTH_G'       : 32,
        'MATRIX_COLUMN_WIDTH_G'    : 32,
        'FMT_IN_MATRIX_ELEMENT_G'  : '(0,4,12)',
        'FMT_IN_VECTOR_ELEMENT_G'  : '(0,4,12)',
        'FMT_OUT_RESULT_G'         : '(0,13,24)',
    }
    short_name = make_short_name(generics, generic_aliases)
    named_config(tb, generics, pre_config=cosim, short_name=short_name)

    generics = {
        'COSIM_NUM_TEST_VECTORS_G' : 8,
        'COSIM_MATRIX_TYPE_G'      : 'ASCENDING',
        'NUM_DOT_PRODUCTS_G'       : 2,
        'MATRIX_ROW_WIDTH_G'       : 4,
        'MATRIX_COLUMN_WIDTH_G'    : 4,
        'FMT_IN_MATRIX_ELEMENT_G'  : '(0,8,1)',
        'FMT_IN_VECTOR_ELEMENT_G'  : '(0,3,5)',
        'FMT_OUT_RESULT_G'         : '(0,13,6)',
    }
    short_name = make_short_name(generics, generic_aliases)
    named_config(tb, generics, pre_config=cosim, short_name=short_name)

    generics = {
        'COSIM_NUM_TEST_VECTORS_G' : 10,
        'COSIM_MATRIX_TYPE_G'      : 'DESCENDING',
        'NUM_DOT_PRODUCTS_G'       : 5,
        'MATRIX_ROW_WIDTH_G'       : 17,
        'MATRIX_COLUMN_WIDTH_G'    : 4,
        'FMT_IN_MATRIX_ELEMENT_G'  : '(0,3,8)',
        'FMT_IN_VECTOR_ELEMENT_G'  : '(0,8,4)',
        'FMT_OUT_RESULT_G'         : '(0,13,12)',
    }
    short_name = make_short_name(generics, generic_aliases)
    named_config(tb, generics, pre_config=cosim, short_name=short_name)