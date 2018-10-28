import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ReadOnly
from cocotb.binary import BinaryValue
from cocotb.result import TestFailure

import os
import struct
import math
import numpy as np
import sklearn as sk
import sklearn.neural_network

def should_equal(expected, actual, epsilon=0):
	if (expected - actual > epsilon):
		raise TestFailure(f'Expected {expected} found {actual}. Exceeds epsilon of {epsilon}')

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
def mnist_predict_1(dut):
	cocotb.fork(Clock(dut.clk, 2).start())
			
	nn = sk.neural_network.MLPRegressor(activation='relu', hidden_layer_sizes=(2,))
	
	with open("mnist/train-images.idx3-ubyte", "rb") as image_file:
		with open("mnist/train-labels.idx1-ubyte", "rb") as label_file:
			_, image_count, height, width = struct.unpack('>iiii',image_file.read(16))
			_, label_count = struct.unpack('>ii', label_file.read(8))
			image_data = np.array(struct.unpack(f"{width*height*image_count}B", image_file.read(width * height*image_count))).reshape(image_count, width*height)
			label_data = np.array(struct.unpack(f"{label_count}B", label_file.read(image_count))).reshape(-1,)
			nn.fit(image_data, label_data)
	
	weights = [
		np.insert(nn.coefs_[0], 0, nn.intercepts_[0], axis=0), 
		np.insert(nn.coefs_[1], 0, nn.intercepts_[1], axis=0)
	]
	print(weights)
	print(np.array(weights).shape)
	print(np.array(weights[0]).shape)
	print(np.array(weights[1]).shape)
			
	yield RisingEdge(dut.clk)
	yield RisingEdge(dut.clk)
	yield RisingEdge(dut.clk)
	yield RisingEdge(dut.clk)
	yield RisingEdge(dut.clk)
	yield RisingEdge(dut.clk)
	yield RisingEdge(dut.clk)
	yield RisingEdge(dut.clk)
			
	yield reset(dut)
		
	yield load_weights(dut, weights)
		
	yield RisingEdge(dut.clk)

