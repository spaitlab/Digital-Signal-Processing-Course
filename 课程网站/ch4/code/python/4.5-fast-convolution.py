"""4.5 FFT 的应用：快速卷积、重叠相加、快速相关找时延
课程站 ch4 的 Python 对照版，与 demo_fast_convolution.m 同一算法。运行：python 本文件（numpy、scipy、matplotlib）。
"""
import time
import numpy as np
from scipy.signal import windows
import matplotlib.pyplot as plt
plt.rcParams['font.sans-serif'] = ['Microsoft YaHei', 'SimHei', 'DejaVu Sans']; plt.rcParams['axes.unicode_minus'] = False
rng = np.random.default_rng(20260918)

def sinc_lowpass(L, fc):
    k = np.arange(L); z = 2*np.pi*fc*(k - (L-1)/2)
    hd = 2*fc*np.where(z == 0, 1.0, np.sin(z)/np.where(z == 0, 1, z)); h = hd*windows.hann(L, sym=True); return h/h.sum()

N1, N2 = 1000, 101; x = rng.normal(size=N1); h = sinc_lowpass(N2, 0.1)
y_direct = np.convolve(x, h)
Nfft = 1 << int(np.ceil(np.log2(N1 + N2 - 1)))
y_fast = np.fft.ifft(np.fft.fft(x, Nfft)*np.fft.fft(h, Nfft)).real[:N1+N2-1]
e_fast = np.max(np.abs(y_fast - y_direct)); print("快速卷积（补零到 %d）与 convolve 最大差 %.1e" % (Nfft, e_fast)); assert e_fast < 1e-10

for L in 2**np.arange(10, 15):
    a, b = rng.normal(size=L), rng.normal(size=L); Nf = 1 << int(np.ceil(np.log2(2*L - 1)))
    t0 = time.perf_counter(); c1 = np.convolve(a, b); t_conv = time.perf_counter() - t0
    t0 = time.perf_counter(); c2 = np.fft.ifft(np.fft.fft(a, Nf)*np.fft.fft(b, Nf)).real[:2*L-1]; t_fft = time.perf_counter() - t0
    assert np.max(np.abs(c1 - c2)) < 1e-6*L
print("N=%d：convolve %.0f ms，FFT 法 %.1f ms" % (L, t_conv*1e3, t_fft*1e3))

Nlong, B = 20000, 1024; x_long = rng.normal(size=Nlong); y_oa = np.zeros(Nlong + N2 - 1)
NfB = 1 << int(np.ceil(np.log2(B + N2 - 1))); H = np.fft.fft(h, NfB)
for start in range(0, Nlong, B):
    seg = x_long[start:start+B]; yseg = np.fft.ifft(np.fft.fft(seg, NfB)*H).real[:seg.size+N2-1]
    y_oa[start:start+yseg.size] += yseg                                      # 重叠相加
e_oa = np.max(np.abs(y_oa - np.convolve(x_long, h))); print("重叠相加与整段 convolve 最大差 %.1e" % e_oa); assert e_oa < 1e-9

Ns, delay = 4096, 37; s = rng.normal(size=Ns)
r = 0.6*np.r_[np.zeros(delay), s[:-delay]] + 0.5*rng.normal(size=Ns)
Nc = 1 << int(np.ceil(np.log2(2*Ns - 1)))
rxy = np.fft.ifft(np.fft.fft(r, Nc)*np.conj(np.fft.fft(s, Nc))).real[:Ns]   # 互相关
found = int(np.argmax(rxy)); print("快速相关找回声时延：峰在 %d（真值 %d）" % (found, delay)); assert found == delay
print("FAST_CONV_OK")

fig, ax = plt.subplots(2, 2, figsize=(12, 9))
ax[0,0].plot(y_direct[:300], color="0.6", lw=2); ax[0,0].plot(y_fast[:300]); ax[0,0].set_title("① 快速卷积 vs convolve")
ax[0,1].axis("off"); ax[0,1].set_title("② 用时见终端输出")
ax[1,0].plot(y_oa[:2500]); ax[1,0].set_title("③ 重叠相加")
ax[1,1].plot(rxy[:200]); ax[1,1].axvline(delay, color="r", ls="--"); ax[1,1].set_title("④ 互相关峰 = 时延")
for a_ in ax.flat: a_.grid(True)
plt.tight_layout(); plt.show()
