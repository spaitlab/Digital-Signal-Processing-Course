"""3.5 频域采样：[1..6] 只采 4 点 → [6,8,3,4]；补零不改变包络
课程站 ch3 页内 Python 片段的可运行文件版。2026-09-18 本机验证通过。
运行：python 本文件；需要 numpy、matplotlib（3.1）、scipy（3.7）。
"""
import numpy as np
xlong = np.arange(1, 7)
sampled = np.exp(-2j*np.pi*np.outer(np.arange(4), np.arange(6))/4) @ xlong
print("完整 DTFT 采 4 点后 IDFT:", np.round(np.fft.ifft(sampled).real, 6))   # [6 8 3 4]
print("fft(x,4) 再 ifft（截断）:", np.fft.ifft(np.fft.fft(xlong, 4)).real)    # [1 2 3 4]
fs, M = 8000, 512; n = np.arange(M); x = np.cos(2*np.pi*103*n/fs)
assert np.allclose(np.fft.fft(x, 4096)[::8], np.fft.fft(x))
print("补零到 4096 点后每隔 8 点就是原 512 点 DFT：通过")
