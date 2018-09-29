import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ReadOnly
from cocotb.binary import BinaryValue
from cocotb.result import TestFailure

import math
import numpy as np
import sklearn as sk
import sklearn.neural_network

def should_equal(expected, actual, epsilon=0):
	if (expected - actual > epsilon):
		raise TestFailure(f'Expected {expected} found {actual}. Exceeds epsilon of {epsilon}')

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
				dut.weights_data = int(m * math.pow(2,16))
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

	should_equal(0, dut.out_data.value.signed_integer / math.pow(2,16))

@cocotb.test()
def test_xor_01(dut):

	cocotb.fork(Clock(dut.clk, 5000).start())
	
	yield reset(dut)	
	yield load_weights(dut, STANDARD_XOR_WEIGHTS)	

	dut.in_data = 0b01
	dut.in_en = 1

	yield RisingEdge(dut.out_en)
	yield ReadOnly()

	should_equal(1, dut.out_data.value.signed_integer / math.pow(2,16))

@cocotb.test()
def test_xor_10(dut):

	cocotb.fork(Clock(dut.clk, 5000).start())

	yield reset(dut)	
	yield load_weights(dut, STANDARD_XOR_WEIGHTS)	

	dut.in_data = 0b10
	dut.in_en = 1

	yield RisingEdge(dut.out_en)
	yield ReadOnly()

	should_equal(1, dut.out_data.value.signed_integer / math.pow(2,16))

@cocotb.test()
def test_xor_11(dut):

	cocotb.fork(Clock(dut.clk, 5000).start())
	
	yield reset(dut)
	yield load_weights(dut, STANDARD_XOR_WEIGHTS)	

	dut.in_data = 0b11
	dut.in_en = 1

	yield RisingEdge(dut.out_en)
	yield ReadOnly()

	should_equal(0, dut.out_data.value.signed_integer / math.pow(2,16))

@cocotb.test()
def test_xor_non_integral_10(dut):

	cocotb.fork(Clock(dut.clk, 5000).start())
	
	yield reset(dut)

	weights = [
			[ 
				[ 0.0025461, -0.87047196],
				[1.29770841,  0.87153556],
        			[1.29751803,  0.87187085]
		],
		[
			[0.03747975],
			[0.71871144],
			[-2.14291662]
		]
	]

	yield load_weights(dut, weights)	

	dut.in_data = 0b10
	dut.in_en = 1

	yield RisingEdge(dut.out_en)
	yield ReadOnly()

	should_equal(0.9697, dut.out_data.value.signed_integer / math.pow(2,16), epsilon = 0.01)


@cocotb.test()
def validate_against_sklearn(dut):
	cocotb.fork(Clock(dut.clk, 5000).start())
	for function_to_learn in [
		[0,0,0,0],
		[0,0,0,1],
		[0,0,1,0],
		[0,0,1,1],
		[0,1,0,0],
		[0,1,0,1],
		[0,1,1,0],
		[0,1,1,1],
		[1,0,0,0],
		[1,0,0,1],
		[1,0,1,0],
		[1,0,1,1],
		[1,1,0,0],
		[1,1,0,1],
		[1,1,1,0],
		[1,1,1,1]]:
		
		for inputs in [
			[0b00, [0,0]],
			[0b01, [1,0]],
			[0b10, [0,1]],
			[0b11, [1,1]]
		]:

			train_x = np.array([
				0, 0,
				0, 1,
				1, 0,
				1, 1]).reshape(4, 2)
		
			train_y = np.array(function_to_learn).reshape(4,)
		
			nn = sk.neural_network.MLPRegressor(activation='relu', max_iter=10000, hidden_layer_sizes=(2,))
			nn.fit(train_x, train_y)
			weights = [
					np.insert(nn.coefs_[0], 0, nn.intercepts_[0], axis=0), 
					np.insert(nn.coefs_[1], 0, nn.intercepts_[1], axis=0)
			]
			
			yield RisingEdge(dut.clk)
			
			yield reset(dut)
		
			yield load_weights(dut, weights)
		
			dut.in_data = inputs[0]
			dut.in_en = 1
			
			yield RisingEdge(dut.out_en)
			yield ReadOnly()
			should_equal(
				nn.predict([inputs[1]])[0], 
				dut.out_data.value.signed_integer / math.pow(2,16), 
				epsilon = 0.01)
	
