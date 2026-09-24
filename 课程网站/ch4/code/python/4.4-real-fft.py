"""4.4 实序列 FFT：一次 N 点 FFT 算两个 N 点实序列；一次 N 点 FFT 算一个 2N 点实序列
课程站 ch4 的 Python 对照版，与 demo_real_fft.m 同一算法。运行：python 本文件（numpy、matplotlib）。
"""
import numpy as np
import matplotlib.pyplot as plt
plt.rcParams['font.sans-serif'] = ['Microsoft YaHei', 'SimHei', 'DejaVu Sans']; plt.rcParams['axes.unicode_minus'] = False

N = 64; n = np.arange(N); rng = np.random.default_rng(20260918)
x1 = np.cos(2*np.pi*4*n/N) + 0.3*rng.normal(size=N)
x2 = 0.8*np.sin(2*np.pi*11*n/N) + 0.3*rng.normal(size=N)
Z = np.fft.fft(x1 + 1j*x2)
Zc = np.conj(Z[(-n) % N])                                  # Z*(N−k)
X1, X2 = (Z + Zc)/2, (Z - Zc)/(2j)
e1, e2 = np.max(np.abs(X1 - np.fft.fft(x1))), np.max(np.abs(X2 - np.fft.fft(x2)))
print("一次 64 点 FFT 分出两个实序列的谱：最大差 %.1e, %.1e" % (e1, e2)); assert e1 < 1e-11 and e2 < 1e-11

M = 128; m = np.arange(M)
x = np.cos(2*np.pi*7*m/M) + 0.5*np.cos(2*np.pi*30*m/M + 1) + 0.2*rng.normal(size=M)
ZZ = np.fft.fft(x[0::2] + 1j*x[1::2])                      # 64 点 FFT
ZZc = np.conj(ZZ[(-n) % N]); A, B = (ZZ + ZZc)/2, (ZZ - ZZc)/(2j)
Wk = np.exp(-2j*np.pi*n/M)
X_full = np.r_[A + Wk*B, A - Wk*B]
eL = np.max(np.abs(X_full - np.fft.fft(x)))
print("128 点实序列只用一次 64 点 FFT：最大差 %.1e" % eL); assert eL < 1e-11
mFFT = lambda N: N/2*np.log2(N)
print("复乘次数：两个 64 点实序列 硬算 %d vs 本法 %d；一个 128 点实序列 硬算 %d vs 本法 %d" % (2*mFFT(N), mFFT(N), mFFT(M), mFFT(N) + N))
print("REAL_FFT_OK")

fig, ax = plt.subplots(2, 2, figsize=(12, 9))
ax[0,0].stem(n, np.abs(np.fft.fft(x1)), linefmt="0.6", markerfmt="o", basefmt=" "); ax[0,0].stem(n, np.abs(X1), basefmt=" "); ax[0,0].set_title("① 由 Z 分出的 X₁ vs 直接")
ax[0,1].stem(n, Z.real, basefmt=" "); ax[0,1].stem(n, Z.imag, linefmt="C1-", markerfmt="C1o", basefmt=" "); ax[0,1].set_title("② Z(k) 无共轭对称")
ax[1,0].stem(m, np.abs(np.fft.fft(x)), linefmt="0.6", markerfmt="o", basefmt=" "); ax[1,0].stem(m, np.abs(X_full), basefmt=" "); ax[1,0].set_title("③ 128 点实序列用 64 点 FFT")
ax[1,1].bar([0, 1, 3, 4], [2*mFFT(N), mFFT(N), mFFT(M), mFFT(N)+N]); ax[1,1].set_title("④ 复乘次数")
for a_ in ax.flat: a_.grid(True)
plt.tight_layout(); plt.show()
