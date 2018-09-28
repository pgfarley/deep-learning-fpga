VERILOG_SOURCES = $(PWD)/feed_forward_neural_network_top.v
TOPLEVEL=feed_forward_neural_network_top
MODULE=test_feed_forward_neural_network_top
include $(COCOTB)/makefiles/Makefile.inc
include $(COCOTB)/makefiles/Makefile.sim
