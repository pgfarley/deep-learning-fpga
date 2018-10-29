MKFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
CURRENT_DIR := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))

SRC_DIR = $(CURRENT_DIR)../../src/rtl
VERILOG_SOURCES = $(SRC_DIR)/feed_forward_neural_network_top.v
TOPLEVEL=feed_forward_neural_network_top
MODULE=test_mnist

#28w * 28h * 8 bits
COMPILE_ARGS+=-Pfeed_forward_neural_network_top.INPUT_VECTOR_SIZE=6272
COMPILE_ARGS+=-Pfeed_forward_neural_network_top.INPUT_WORD_SIZE=8
COMPILE_ARGS+=-Pfeed_forward_neural_network_top.CLOG2_MAX_WEIGHTS_N=10

include $(COCOTB)/makefiles/Makefile.inc
include $(COCOTB)/makefiles/Makefile.sim
