"""5.1 数字滤波器的基本概念：IIR/FIR 脉冲响应、幅频响应、技术指标（容限图）、一阶系统的正弦稳态响应
课程站 ch5 的 Python 对照版，与 demo_filter_concepts.m 同一算法。运行：python 本文件（numpy、scipy）。
"""
import numpy as np
from scipy import signal

def dtft_resp(b, a, w):
    z = np.exp(-1j*np.asarray(w))
    return np.polyval(b[::-1], z) / np.polyval(np.atleast_1d(a)[::-1], z)

bI = np.array([1, -3, 11, 27, 18.]); aI = np.array([16, 12, 2, -4, -2.])      # 例 5.1
delta = signal.unit_impulse(30); hI = signal.lfilter(bI, aI, delta)
hF = 0.9**np.arange(11)                                                         # 例 5.5
max_pole = np.max(np.abs(np.roots(aI)))
print("例 5.1 极点最大模 %.4f（稳定）；h(29)=%.2e；FIR 长度 %d" % (max_pole, hI[29], hF.size))
assert max_pole < 1

w = np.linspace(0, np.pi, 1024)
Nw, wc = 41, 0.4*np.pi; n = np.arange(Nw); alpha = (Nw-1)/2
hLP = (wc/np.pi)*np.sinc(wc*(n-alpha)/np.pi) * (0.54 - 0.46*np.cos(2*np.pi*n/(Nw-1)))
mag = np.abs(dtft_resp(hLP, 1, w)); wp, ws = 0.32*np.pi, 0.48*np.pi
d1 = np.max(np.abs(mag[w <= wp] - 1)); d2 = np.max(mag[w >= ws])
ap, as_ = -20*np.log10(1-d1), -20*np.log10(d2); w3 = w[np.argmax(mag <= 1/np.sqrt(2))]
print("容限：δ1=%.4f → αp=%.3f dB；δ2=%.4f → αs=%.1f dB；3 dB 点 %.3fπ" % (d1, ap, d2, as_, w3/np.pi))
assert d1 < 0.01 and as_ > 40

b5, a5 = np.array([1, 1.]), np.array([1, -0.5])                                # 习题 5：y(n)=0.5y(n−1)+x(n)+x(n−1)
fs, f0 = 1000, 100; t = np.arange(200)/fs; x5 = 10*np.sin(2*np.pi*f0*t)
y5 = signal.lfilter(b5, a5, x5); H5 = dtft_resp(b5, a5, 2*np.pi*f0/fs)
ys, ts = y5[100:], t[100:]; cs = np.linalg.lstsq(np.column_stack([np.cos(2*np.pi*f0*ts), np.sin(2*np.pi*f0*ts)]), ys, rcond=None)[0]
g_theory, g_meas = abs(H5), np.hypot(*cs)/10                                   # 稳态幅度用最小二乘拟合，峰值不一定正好被采到
print("100 Hz 正弦增益：理论 %.4f，实测 %.4f；相移 %.1f°" % (g_theory, g_meas, np.angle(H5)*180/np.pi))
assert abs(g_theory - g_meas) < 0.01
print("FILTER_CONCEPTS_OK")
