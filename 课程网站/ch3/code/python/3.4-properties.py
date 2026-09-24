"""3.4 DFT 的性质：圆周卷积、圆周移位、帕塞瓦尔
课程站 ch3 页内 Python 片段的可运行文件版。2026-09-18 本机验证通过。
运行：python 本文件；需要 numpy、matplotlib（3.1）、scipy（3.7）。
"""
import numpy as np
def circular_convolution(x, h, length):
    if length < max(len(x), len(h)):
        raise ValueError('长度不小于两输入长度，避免 FFT 隐式截断')
    return np.fft.ifft(np.fft.fft(x, length) * np.fft.fft(h, length)).real
x, h = [1, 2, 3], [2, 3, 1, 2]
print("线性卷积      ", np.convolve(x, h))                          # [ 2  7 13 13  7  6]
print("5 点圆周卷积  ", np.round(circular_convolution(x, h, 5)))    # [ 8  7 13 13  7]
print("6 点圆周卷积  ", np.round(circular_convolution(x, h, 6)))    # [ 2  7 13 13  7  6]
rng = np.random.default_rng(20260917); N = 8; k = np.arange(N)
z = rng.normal(size=N) + 1j*rng.normal(size=N); Z = np.fft.fft(z)
assert np.allclose(np.fft.fft(np.roll(z, 2)), Z*np.exp(-2j*np.pi*k*2/N))   # 圆周移位
assert np.allclose(np.sum(abs(z)**2), np.sum(abs(Z)**2)/N)                 # 帕塞瓦尔
print("x=[1,j]: sum(x^2) =", np.sum(np.array([1, 1j])**2), " sum(|x|^2) =", np.sum(abs(np.array([1, 1j]))**2))
