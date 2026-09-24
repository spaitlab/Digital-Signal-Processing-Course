"""3.6 用 DFT 逼近连续信号：混叠、栅栏与补零、泄漏
课程站 ch3 页内 Python 片段的可运行文件版。2026-09-18 本机验证通过。
运行：python 本文件；需要 numpy、matplotlib（3.1）、scipy（3.7）。
"""
import numpy as np
fs, M = 8000, 512; n = np.arange(M)
pair = np.cos(2*np.pi*1000*n/fs) + np.cos(2*np.pi*1008*n/fs)
A4096 = 2*np.abs(np.fft.fft(pair, 4096))/M
f = np.arange(4096)*fs/4096; sel = (f > 940) & (f < 1080); a = A4096[sel]
peaks = int(np.sum((a[1:-1] > a[:-2]) & (a[1:-1] >= a[2:]) & (a[1:-1] > 0.4)))
print("512 点补零到 4096：940-1080 Hz 内幅值>0.4 的峰个数 =", peaks)          # 1
n2 = np.arange(2048); pair2 = np.cos(2*np.pi*1000*n2/fs) + np.cos(2*np.pi*1008*n2/fs)
A2048 = 2*np.abs(np.fft.fft(pair2))/2048
f2 = np.arange(2048)*fs/2048; sel2 = (f2 > 990) & (f2 < 1016)
print("2048 点记录：990-1016 Hz 内幅值>0.5 的频点 =", f2[sel2][A2048[sel2] > 0.5])   # 1000, 1007.8
assert np.allclose(np.cos(2*np.pi*400*n/600), np.cos(2*np.pi*200*n/600))
print("混叠：400 Hz 与 200 Hz 在 fs=600 Hz 下样本逐点相同：通过")
S7 = np.fft.fft(np.cos(2*np.pi*7*n/M)); S73 = np.fft.fft(np.cos(2*np.pi*7.3*n/M))
print("7 周期：除 k=7,505 外最大 |X| = %.1e；7.3 周期：其余频点能量范数 = %.1f" % (
    np.max(np.abs(np.delete(S7, [7, M-7]))), np.linalg.norm(np.delete(S73, [7, M-7]))))
