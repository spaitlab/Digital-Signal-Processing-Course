"""7.2 线性相位 FIR 的零点特性；M 点滑动平均与 FIR-01 实验（fs=1000 Hz，50 Hz + 0.8×250 Hz，M=4）
课程站 ch7 的 Python 对照版，与 demo_fir_zeros_moving_average.m 同一公式。运行：python 本文件（numpy、scipy）。
"""
import numpy as np
from scipy import signal

h1 = np.array([-3, 1, -1, -2, 5, 6, 5, -2, -1, 1, -3.]); z1 = np.roots(h1)
recip = max(np.min(np.abs(z1 - 1/np.conj(z))) for z in z1)
print("例 7.1 零点模:", np.round(np.sort(np.abs(z1)), 4), " 倒数配对差 %.1e" % recip); assert recip < 1e-8
fs, M = 1000, 4; hM = np.ones(M)/M; f = np.linspace(0, fs/2, 4001); w = 2*np.pi*f/fs
H = np.polyval(hM[::-1], np.exp(-1j*w)); closed = np.where(w == 0, 1, np.sin(M*w/2)/(M*np.where(w == 0, 1, np.sin(w/2))))*np.exp(-1j*(M-1)*w/2)
assert np.max(np.abs(H - closed)) < 1e-12
t = np.arange(2001)/fs; x = np.sin(2*np.pi*50*t) + 0.8*np.sin(2*np.pi*250*t); y = signal.lfilter(hM, [1], x)
H50, H250 = [np.polyval(hM[::-1], np.exp(-2j*np.pi*fq/fs)) for fq in (50, 250)]
ts, ys = t[199:], y[199:]
A = np.column_stack([np.cos(2*np.pi*50*ts), np.sin(2*np.pi*50*ts), np.cos(2*np.pi*250*ts), np.sin(2*np.pi*250*ts)])
c = np.linalg.lstsq(A, ys, rcond=None)[0]; m50, m250 = np.hypot(c[0], c[1]), np.hypot(c[2], c[3])
delay_ms = -np.arctan2(c[0], c[1])/(2*np.pi*50)*1e3
print("FIR-01：50 Hz 增益 预测 %.4f 实测 %.4f；250 Hz 预测 %.1e 实测 %.1e；延迟 预测 %.1f ms 实测 %.2f ms" % (abs(H50), m50, abs(H250), m250, (M-1)/2/fs*1e3, delay_ms))
assert abs(m50 - abs(H50)) < 1e-9 and m250 < 1e-9 and abs(delay_ms - 1.5) < 1e-6
for Mi in (4, 8, 10):
    g = np.abs(np.polyval((np.ones(Mi)/Mi)[::-1], np.exp(-2j*np.pi*np.array([50, 200, 250])/fs)))
    print("M=%2d：50/200/250 Hz 增益 %.3f/%.3f/%.3f" % (Mi, *g))
print("FIR_ZEROS_MOVING_AVERAGE_OK")
