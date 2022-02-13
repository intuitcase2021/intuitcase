import unittest, calculator

class TestCalculator(unittest.TestCase):
    def test_add(self):
        self.assertEqual(calculator.add(7,5), 12)
        self.assertEqual(calculator.add(-1,1), 0)
        self.assertEqual(calculator.add(-1,-1), -2)

    def test_sub(self):
        self.assertEqual(calculator.subtract(7,5), 2)
        self.assertEqual(calculator.subtract(-1,1), -2)
        self.assertEqual(calculator.subtract(-1,-1), 0)

if __name__ == '__main__':
    unittest.main()
