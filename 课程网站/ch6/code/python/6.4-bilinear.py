"""6.4 双线性变换：梯形积分、频率映射、例 6.7（T 的问题）、例 6.8 带预畸变的设计
课程站 ch6 的 Python 对照版，与 demo_bilinear.m 同一公式。运行：python 本文件（numpy、scipy）。
"""
import numpy as np
from scipy import signal
from dsp_iir import cheby1_analog, bilinear, freqs, freqz

errs = []
for T in (0.5, 0.1):
    bz1, az1 = bilinear(np.array([1.]), np.array([1, 1.]), T)
    t = np.arange(0, 12 + T/2, T); y = signal.lfilter(bz1, az1, np.sin(t))      # y'+y=sin t
    errs.append(np.max(np.abs(y - 0.5*(np.sin(t) - np.cos(t) + np.exp(-t)))))
print("梯形积分 y'+y=sin t 的误差：T=0.5 %.5f，T=0.1 %.6f（比值 %.1f ≈ 25）" % (errs[0], errs[1], errs[0]/errs[1]))
assert 15 < errs[0]/errs[1] < 35
Om = np.array([1., 3.]); w = 2*np.arctan(Om/2); print("ω=2arctan(Ω/2)：Ω=1,3 → ω=%s，与 ΩT 偏离 %s%%" % (np.round(w, 4), np.round(100*(Om - w)/w, 1)))
b, a = np.array([1, 1.]), np.array([1, 5, 6.])
bzA, azA = bilinear(b, a, 0.001); bzB, azB = bilinear(b, a, 0.01)
book_b, book_a = [4.90172170e-03, 4.87733502e-05, -4.85294835e-03], [1, -1.95064137, 0.95122665]
print("例 6.7：T=0.001 → bz=%s az=%s；T=0.01 → bz=%s az=%s" % (np.round(bzA, 6), np.round(azA, 5), np.round(bzB, 6), np.round(azB, 5)))
assert np.max(np.abs(np.r_[bzB - book_b, azB - book_a])) < 1e-6 and np.max(np.abs(azA - book_a)) > 1e-3
w = np.linspace(0, np.pi - 1e-3, 512)
assert np.max(np.abs(freqz(bzB, azB, w) - freqs(b, a, 200*np.tan(w/2)))) < 1e-9        # 式 (6.3.5)，无混叠
wp, ws, ap, as_ = 0.2*np.pi, 0.3*np.pi, 1, 15; eps = np.sqrt(10**(ap/10) - 1)
Wp, Ws = 2*np.tan(wp/2), 2*np.tan(ws/2)
N = int(np.ceil(np.arccosh(np.sqrt(10**(as_/10) - 1)/eps)/np.arccosh(Ws/Wp)))
bA, aA, *_ = cheby1_analog(N, eps, Wp); bz8, az8 = bilinear(bA, aA, 1)
book_az = np.convolve([1, -1.4996, 0.8482], [1, -1.5548, 0.6493]); book_bz = 0.001836*np.array([1, 4, 6, 4, 1])
att = -20*np.log10(np.abs(freqz(bz8, az8, np.array([wp, ws]))))
print("例 6.8：预畸变 Ωc=%.4f，N=%d；bz=%s；与教材差 %.1e；ωp/ωs 处 %.3f/%.2f dB" % (Wp, N, np.round(bz8, 6), np.max(np.abs(np.r_[bz8 - book_bz, az8 - book_az])), *att))
assert N == 4 and np.max(np.abs(np.r_[bz8 - book_bz, az8 - book_az])) < 2e-4 and att[0] <= ap + 1e-6 and att[1] >= as_
print("BILINEAR_OK")
