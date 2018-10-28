#assumes local MNIST data. Can be found at: http://yann.lecun.com/exdb/mnist/
import os
import struct
from PIL import Image
import PIL.ImageOps


import numpy as np
import sklearn as sk
import sklearn.neural_network


def show_image(index=0, image_set='train'):
	with open(f"mnist/{image_set}-images.idx3-ubyte", "rb") as f:
		_, image_count, height, width = struct.unpack('>iiii',f.read(16))
		f.seek(index * width * height, os.SEEK_CUR)
		image_data = f.read(width * height)
		image = Image.frombytes("L", (width, height), image_data)
		display_image = PIL.ImageOps.invert(image).resize((256, 256))
		display_image.show()

#sklearn.datasets.load_digits
def train_nn():
	nn = sk.neural_network.MLPClassifier(activation='relu', hidden_layer_sizes=(1,))
	
	with open("mnist/train-images.idx3-ubyte", "rb") as image_file:
		with open("mnist/train-labels.idx1-ubyte", "rb") as label_file:
			_, image_count, height, width = struct.unpack('>iiii',image_file.read(16))
			_, label_count = struct.unpack('>ii', label_file.read(8))
			image_data = np.array(struct.unpack(f"{width*height*image_count}B", image_file.read(width * height*image_count))).reshape(image_count, width*height)
			label_data = np.array(struct.unpack(f"{label_count}B", label_file.read(image_count))).reshape(-1,)
			nn.fit(image_data, label_data)
			
	with open("mnist/t10k-images.idx3-ubyte", "rb") as image_file:
		with open("mnist/t10k-labels.idx1-ubyte", "rb") as label_file:
			_, image_count, height, width = struct.unpack('>iiii',image_file.read(16))
			_, label_count = struct.unpack('>ii', label_file.read(8))
			
			image_data = np.array(struct.unpack(f"{width*height*image_count}B", image_file.read(width * height*image_count))).reshape(image_count, width*height)
			label_data = np.array(struct.unpack(f"{label_count}B", label_file.read(image_count))).reshape(-1,)
			print(100 - sum([1 if a != b else 0 for a,b in (zip(label_data, nn.predict(image_data)))]) / label_count)
if __name__ == "__main__":

	train_nn()
