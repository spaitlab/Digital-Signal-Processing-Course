"""3.2 离散傅里叶级数：N=8，一个周期 [1,1,0,0,0,0,0,1]
课程站 ch3 页内 Python 片段的可运行文件版。2026-09-18 本机验证通过。
运行：python 本文件；需要 numpy、matplotlib（3.1）、scipy（3.7）。
"""
import numpy as np
N = 8; n = np.arange(N); k = n[:, None]
x = np.isin(n, [0, 1, N-1]).astype(float)            # [1 1 0 0 0 0 0 1]
X = np.exp(-2j*np.pi*k*n/N) @ x                      # 按定义直接求和
assert np.allclose(X, np.fft.fft(x))                 # 与 fft 一致
x_back = np.exp(2j*np.pi*n[:, None]*n/N) @ X / N     # 逆变换，1/N 在这里
assert np.allclose(x_back, x)
print("X~(k) =", np.round(X.real, 4))                # [3 2.4142 1 -0.4142 -1 -0.4142 1 2.4142]
print("X~(0)=%.0f  X~(4)=%.0f" % (X[0].real, X[4].real))
