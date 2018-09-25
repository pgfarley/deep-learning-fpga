VERILOG_SOURCES = $(PWD)/xor_nn.v
TOPLEVEL=xor_nn
MODULE=test_xor_nn
include $(COCOTB)/makefiles/Makefile.inc
include $(COCOTB)/makefiles/Makefile.sim
