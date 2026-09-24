"""3.7 窗函数：弱音显现与幅值校正
课程站 ch3 页内 Python 片段的可运行文件版。2026-09-18 本机验证通过。
运行：python 本文件；需要 numpy、matplotlib（3.1）、scipy（3.7）。
"""
import numpy as np
from scipy.signal import windows
M = 512; n = np.arange(M)
two = np.cos(2*np.pi*7.3*n/M) + 0.005*np.cos(2*np.pi*20*n/M)
hannP = windows.hann(M, sym=False)                       # 周期 Hann
specRect = np.abs(np.fft.rfft(two))/M*2
specHann = np.abs(np.fft.rfft(two*hannP))/hannP.sum()*2
print("频点 20 处幅值：矩形窗 %.4f（泄漏淹没），Hann 窗 %.4f（真值 0.005）" % (specRect[20], specHann[20]))
sig = 2.4*np.cos(2*np.pi*19*n/M)
a = np.abs(np.fft.rfft(sig*hannP, 4096))/hannP.sum()*2
assert abs(a[19*8] - 2.4) < 1e-9
print("相干单音 + Hann + 补零，按窗和校正后幅值 = %.6f" % a[19*8])
for name, w in [("rect", np.ones(51)), ("hann", windows.hann(51)), ("hamming", windows.hamming(51)), ("blackman", windows.blackman(51))]:
    W = np.abs(np.fft.fft(w, 8192)); W = W/W[0]; half = W[:4096]
    first_null = np.argmax(np.diff(half) > 0)
    print("%-8s 首零点 %.1f 频点，最高旁瓣 %.1f dB" % (name, first_null/8192*51, 20*np.log10(half[first_null:].max())))
