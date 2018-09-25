import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ReadOnly
from cocotb.binary import BinaryValue
from cocotb.result import TestFailure

@cocotb.test(timeout=None)
def test_example(dut):

	cocotb.fork(Clock(dut.clk, 5000).start())

	yield RisingEdge(dut.clk)

	yield ReadOnly()
	if(dut.rdy.value.binstr != "1"):
		raise TestFailure("Even the most baic thing is broken")

