import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ReadOnly
from cocotb.binary import BinaryValue
from cocotb.result import TestFailure


def should_equal(expected, actual):
	if expected != actual:
		raise TestFailure(f'Expected {expected} found {actual}')

@cocotb.test(timeout=None)
def test_00(dut):

	cocotb.fork(Clock(dut.clk, 5000).start())

	dut.in_data = 0b00

	for _ in range(0,10):
		yield RisingEdge(dut.clk)
	yield ReadOnly()

	should_equal('0', dut.out_data.value.binstr)

@cocotb.test(timeout=None)
def test_01(dut):

	cocotb.fork(Clock(dut.clk, 5000).start())

	dut.in_data = 0b01

	for _ in range(0,10):
		yield RisingEdge(dut.clk)
	yield ReadOnly()

	should_equal('1', dut.out_data.value.binstr)

@cocotb.test(timeout=None)
def test_10(dut):

	cocotb.fork(Clock(dut.clk, 5000).start())

	dut.in_data = 0b10

	for _ in range(0,10):
		yield RisingEdge(dut.clk)
	yield ReadOnly()

	should_equal('1', dut.out_data.value.binstr)

@cocotb.test(timeout=None)
def test_11(dut):

	cocotb.fork(Clock(dut.clk, 5000).start())

	dut.in_data = 0b11

	for _ in range(0,10):
		yield RisingEdge(dut.clk)
	yield ReadOnly()

	should_equal('0', dut.out_data.value.binstr)

