########################################################################################################################
# Imports
########################################################################################################################
from vunit import VUnit
from glob import glob
import os
import sys
from enum import Enum
from functools import partial

## TODO: create test configuration file

################################################################################
## utils.py
################################################################################

# ---------------------------------------------------------------------------------------------------
# Functionality
# ---------------------------------------------------------------------------------------------------
def named_config(tb, map : dict, pre_config = None, short_name = None):
    cfg_name = "-".join([f"{k}={v}" for k, v in map.items()])
    if short_name is not None:
        cfg_name = short_name
    if pre_config is not None:
        pre_config = partial(pre_config, generics=map)
    tb.add_config(name=cfg_name, generics = map, pre_config=pre_config)

def make_short_name(generics, generic_aliases):
    parts = []
    for k, v in generics.items():
        alias = generic_aliases.get(k, k)  # use alias if defined, else full key
        parts.append(f"{alias}={v}")
    return "_".join(parts)
################################################################################
## test_configs.py
################################################################################

# ---------------------------------------------------------------------------------------------------
# Imports
# ---------------------------------------------------------------------------------------------------
#from .utils import named_config
import sys
import os

# Import for fix cosimulations
sys.path.append(os.path.join(os.path.dirname(__file__), '..'))
from modules import *

# ---------------------------------------------------------------------------------------------------
# Functionality
# ---------------------------------------------------------------------------------------------------

def add_configs(lib):
    """
    Add all base testbench configurations to the VUnit Library
    :param lib: Testbench library
    """

    ### fix_dsp_mac ###
    tb = lib.test_bench('fix_dsp_mac_vunit_tb')
    default_generics = {
        'FMT_MULT_A_G' : '(0,4,4)',
        'FMT_MULT_B_G' : '(0,4,4)',
        'FMT_ADD_G'    : '(0,8,8)',
        'FMT_RESULT_G' : '(0,9,8)',
    }

    cosim = fix_dsp_mac.vunit_tb.cosim.cosim

    named_config(tb, default_generics, pre_config=cosim)

    ### fix_dot_product ###
    tb = lib.test_bench('fix_dot_product_vunit_tb')
    default_generics = {
        'DIMENSION_WIDTH_G' : 4,
        'FMT_IN_ELEMENT_A_G': '(0,4,4)',
        'FMT_IN_ELEMENT_B_G': '(0,4,4)',
        'FMT_OUT_RESULT_G'  : '(0,10,8)',
    }

    cosim = fix_dot_product.vunit_tb.cosim.cosim

    named_config(tb, default_generics, pre_config=cosim)

    ### fix_matrix_vector_product ###
    tb = lib.test_bench('fix_matrix_vector_product_vunit_tb')
    cosim = fix_matrix_vector_product.vunit_tb.cosim.cosim

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

    default_generics = {
        'COSIM_NUM_TEST_VECTORS_G' : 16,
        'COSIM_MATRIX_TYPE_G'      : 'DESCENDING',
        'NUM_DOT_PRODUCTS_G'       : 11,
        'MATRIX_ROW_WIDTH_G'       : 32,
        'MATRIX_COLUMN_WIDTH_G'    : 32,
        'FMT_IN_MATRIX_ELEMENT_G'  : '(0,8,8)',
        'FMT_IN_VECTOR_ELEMENT_G'  : '(0,8,8)',
        'FMT_OUT_RESULT_G'         : '(0,21,16)',
    }

    short_name = make_short_name(default_generics, generic_aliases)
    named_config(tb, default_generics, pre_config=cosim, short_name=short_name)

    default_generics = {
        'COSIM_NUM_TEST_VECTORS_G' : 8,
        'COSIM_MATRIX_TYPE_G'      : 'ASCENDING',
        'NUM_DOT_PRODUCTS_G'       : 2,
        'MATRIX_ROW_WIDTH_G'       : 4,
        'MATRIX_COLUMN_WIDTH_G'    : 4,
        'FMT_IN_MATRIX_ELEMENT_G'  : '(0,4,1)',
        'FMT_IN_VECTOR_ELEMENT_G'  : '(0,4,1)',
        'FMT_OUT_RESULT_G'         : '(0,10,2)',
    }

    # Build a compact short name
    short_name = make_short_name(default_generics, generic_aliases)
    named_config(tb, default_generics, pre_config=cosim, short_name=short_name)

########################################################################################################################
# Setup
########################################################################################################################

class Simulator(Enum):
    GHDL = 1
    MODELSIM = 2
    NVC = 3

#Execute from sim directory
os.chdir(os.path.dirname(os.path.realpath(__file__)))

#Argument handling
argv = sys.argv[1:]
SIMULATOR = Simulator.GHDL
USE_COVERAGE = False
GENERATE_VHDL_LS_TOML = False
GENERATE_COMPILE_LIST = False

#Simulator Selection
#.. The environment variable VUNIT_SIMULATOR has precedence over the commandline options.
if "--modelsim" in sys.argv:
    SIMULATOR = Simulator.MODELSIM
    argv.remove("--modelsim")
if "--nvc" in sys.argv:
    SIMULATOR = Simulator.NVC
    argv.remove("--nvc")
if "--ghdl" in sys.argv:
    SIMULATOR = Simulator.GHDL
    argv.remove("--ghdl")
if "--coverage" in sys.argv:
    USE_COVERAGE = True
    argv.remove("--coverage")
    if SIMULATOR != Simulator.MODELSIM:
        raise "Coverage is only allowed with --modelsim"
if "--vhdl_ls" in sys.argv:
    GENERATE_VHDL_LS_TOML = True
    argv.remove("--vhdl_ls")
if "--compile_list" in sys.argv:
    GENERATE_COMPILE_LIST = True
    argv.remove("--compile_list")


# Obviously the simulator must be chosen before sources are added
if 'VUNIT_SIMULATOR' not in os.environ:
    if SIMULATOR == Simulator.GHDL:
        os.environ['VUNIT_SIMULATOR'] = 'ghdl'
    elif SIMULATOR == Simulator.NVC:
        os.environ['VUNIT_SIMULATOR'] = 'nvc'
    else:
        os.environ['VUNIT_SIMULATOR'] = 'modelsim'

# Parse VUnit Arguments
vu = VUnit.from_argv(compile_builtins=False, argv=argv)
vu.add_vhdl_builtins()
vu.add_com()
vu.add_verification_components()

# Create a library
olo = vu.add_library('olo')
lib = vu.add_library('lib')

# Add all open-logic VHDL files
files  = glob('../submodules/open-logic/src/**/*.vhd', recursive=True)
files += glob('../submodules/open-logic/3rdParty/en_cl_fix/hdl/*.vhd', recursive=True)
olo.add_source_files(files)

# Add all source VHDL files
files = glob('../modules/**/rtl/*.vhd', recursive=True)
lib.add_source_files(files)

# Add test helpers
files = glob('../submodules/open-logic/test/tb/*.vhd', recursive=True)
lib.add_source_files(files)

# Add all vunit tb VHDL files
files  = glob('../modules/**/vunit_tb/*.vhd', recursive=True)
lib.add_source_files(files)

# Obviously flags must be set after files are imported
vu.add_compile_option('ghdl.a_flags', ['-frelaxed-rules', '-Wno-hide', '-Wno-shared'])
vu.add_compile_option('nvc.a_flags', ['--relaxed'])

########################################################################################################################
# Test bench configurations
########################################################################################################################

## Defined at the top of this file!
add_configs(lib)

########################################################################################################################
# Execution
########################################################################################################################

lib.set_sim_option('ghdl.elab_flags', ['-frelaxed'])
lib.set_sim_option('nvc.heap_size', '5000M')

# Run
vu.main()
