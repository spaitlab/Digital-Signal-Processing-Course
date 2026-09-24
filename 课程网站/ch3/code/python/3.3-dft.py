"""3.3 离散傅里叶变换：例 3.2 六点序列 n/6 的三种算法
课程站 ch3 页内 Python 片段的可运行文件版。2026-09-18 本机验证通过。
运行：python 本文件；需要 numpy、matplotlib（3.1）、scipy（3.7）。
"""
import numpy as np
N = 6; n = np.arange(N)
x = n/6
W = np.exp(-2j*np.pi*np.outer(n, n)/N)      # 定义式矩阵
X = W @ x
assert np.allclose(X, np.fft.fft(x))
X_form = np.r_[x.sum(), -1/(1-np.exp(-2j*np.pi*np.arange(1, N)/N))]   # 等差序列闭式
assert np.allclose(X, X_form)
x_back = W.conj() @ X / N                     # idft(dft(x))：往返重构
assert np.allclose(x_back, x)
print("X(k) =", np.round(X, 3))
print("4 点 DFT of [1,0,-1,0] =", np.fft.fft([1, 0, -1, 0]).real)
