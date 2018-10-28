import numpy as np


class Xor:

    def __init__(self):
        self.w1 = [[0, -1], [1, 1], [1, 1]]
        self.w2 = [[0], [1], [-2]]

    def predict(self, X):
        h1 = self.append_bias(X) @ self.w1
        a1 = self.relu(h1)
        o1 = self.append_bias(a1) @ self.w2

        return o1

    def relu(self, X):
        return np.maximum(0, X)

    def append_bias(self, X):
        return np.hstack((np.ones(len(X)).reshape(-1, 1), X))

if __name__ == "__main__":
    import unittest

    class Test(unittest.TestCase):

        def test_minimal_case(self):
            np.testing.assert_array_equal([[1]], Xor().predict([[0, 1]]))

        def test_minimal_exhaustive(self):
            actual = Xor().predict([[0, 0], [0, 1], [1, 0], [1, 1]])
            expected = [[0], [1], [1], [0]]
            np.testing.assert_array_equal(expected, actual)

    unittest.main()
