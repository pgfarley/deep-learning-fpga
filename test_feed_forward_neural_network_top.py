import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ReadOnly
from cocotb.binary import BinaryValue
from cocotb.result import TestFailure


def should_equal(expected, actual):
	if expected != actual:
		raise TestFailure(f'Expected {expected} found {actual}')

STANDARD_XOR_WEIGHTS = [ 
	[
		[0, -1],
		[1, 1],
		[1, 1]
	],
	[
		[0],
		[1],
		[-2]
	]
]

@cocotb.coroutine
def reset(dut):
	dut.reset_n = 0
	yield RisingEdge(dut.clk)
	dut.reset_n = 1
	dut.in_en = 0
	yield RisingEdge(dut.clk)

@cocotb.coroutine
def load_weights(dut, weights):

	yield RisingEdge(dut.clk)

	dut.weights_en = 1
	for weights_idx, weights in enumerate(weights):
		dut.weights_layer_address = weights_idx
		for n_idx, n in enumerate(weights):
			dut.weights_n_address = n_idx
			for m_idx, m in enumerate(n):
				dut.weights_m_address = m_idx
				dut.weights_data = m
				yield RisingEdge(dut.clk)
	dut.weights_en = 0
	yield RisingEdge(dut.clk)

@cocotb.test()
def test_xor_00(dut):

	cocotb.fork(Clock(dut.clk, 5000).start())

	yield reset(dut)	
	yield load_weights(dut, STANDARD_XOR_WEIGHTS)	

	dut.in_data = 0b00
	dut.in_en = 1
	
	yield RisingEdge(dut.out_en)
	yield ReadOnly()

	should_equal('0', dut.out_data.value.binstr)

@cocotb.test()
def test_xor_01(dut):

	cocotb.fork(Clock(dut.clk, 5000).start())
	
	yield reset(dut)	
	yield load_weights(dut, STANDARD_XOR_WEIGHTS)	

	dut.in_data = 0b01
	dut.in_en = 1

	yield RisingEdge(dut.out_en)
	yield ReadOnly()

	should_equal('1', dut.out_data.value.binstr)

@cocotb.test()
def test_xor_10(dut):

	cocotb.fork(Clock(dut.clk, 5000).start())

	yield reset(dut)	
	yield load_weights(dut, STANDARD_XOR_WEIGHTS)	

	dut.in_data = 0b10
	dut.in_en = 1

	yield RisingEdge(dut.out_en)
	yield ReadOnly()

	should_equal('1', dut.out_data.value.binstr)

@cocotb.test()
def test_xor_11(dut):

	cocotb.fork(Clock(dut.clk, 5000).start())
	
	yield reset(dut)
	yield load_weights(dut, STANDARD_XOR_WEIGHTS)	

	dut.in_data = 0b11
	dut.in_en = 1

	yield RisingEdge(dut.out_en)
	yield ReadOnly()

	should_equal('0', dut.out_data.value.binstr)

@cocotb.test()
def test_xor_non_integral_11(dut):
	pass
