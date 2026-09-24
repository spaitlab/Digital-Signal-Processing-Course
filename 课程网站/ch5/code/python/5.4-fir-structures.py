"""5.4 FIR 结构：横截型、级联型、线性相位型的实现与对照；四类线性相位 FIR 的固有零点
课程站 ch5 的 Python 对照版，与 demo_fir_structures.m 同一算法。运行：python 本文件（numpy、scipy）。
"""
import numpy as np
from scipy import signal

def dtft_resp(b, a, w):
    z = np.exp(-1j*np.asarray(w)); return np.polyval(np.atleast_1d(b)[::-1], z) / np.polyval(np.atleast_1d(a)[::-1], z)

def transversal(h, x):
    xd = np.zeros(len(h)-1); y = np.zeros(len(x))
    for n, xn in enumerate(x):
        y[n] = h[0]*xn + h[1:] @ xd; xd = np.r_[xn, xd[:-1]]
    return y

def linear_phase_sym(h, x):
    N = len(h); L = N//2; xd = np.zeros(N-1); y = np.zeros(len(x))
    for n, xn in enumerate(x):
        xs = np.r_[xn, xd]                                       # xs[k]=x(n−k)
        acc = sum(h[k]*(xs[k] + xs[N-1-k]) for k in range(L))    # 对称样本先相加再乘
        if N % 2: acc += h[L]*xs[L]
        y[n] = acc; xd = xs[:-1]
    return y

h5 = 0.9**np.arange(11); delta = signal.unit_impulse(30); u = np.ones(30)          # 例 5.5
errT = max(np.max(np.abs(transversal(h5, delta) - signal.lfilter(h5, 1, delta))), np.max(np.abs(transversal(h5, u) - signal.lfilter(h5, 1, u))))
c1, c2 = np.array([1, 1.72, 0.81]), np.array([1, 1.17, 0.85]); hC = np.convolve(c1, c2)   # 例 5.6
errC = np.max(np.abs(signal.lfilter(c2, 1, signal.lfilter(c1, 1, delta)) - signal.lfilter(hC, 1, delta)))
print("横截型差 %.1e；级联型乘开 h=%s，差 %.1e；零点模 %s" % (errT, np.round(hC, 4), errC, np.round(np.abs(np.r_[np.roots(c1), np.roots(c2)]), 4)))

hL = np.array([1, 2, 3, 4, 4, 3, 2, 1])/20; N = len(hL); x = np.random.default_rng(0).normal(size=200)
errL = np.max(np.abs(linear_phase_sym(hL, x) - signal.lfilter(hL, 1, x)))
w = np.linspace(0, np.pi, 1024); ph = np.unwrap(np.angle(dtft_resp(hL, 1, w))); idx = w < 0.3*np.pi
slope = np.polyfit(w[idx], ph[idx], 1)[0]
print("线性相位型：乘法器 %d→%d，差 %.1e；相位斜率 %.4f（应为 −(N−1)/2=%.1f）" % (N, N//2, errL, slope, -(N-1)/2))
assert errT < 1e-12 and errC < 1e-12 and errL < 1e-12 and abs(slope + (N-1)/2) < 1e-6

types = {"I 对称 N=5": np.array([1, 2, 3, 2, 1])/9, "II 对称 N=6": np.array([1, 2, 3, 3, 2, 1])/12,
         "III 反对称 N=5": np.array([1, 2, 0, -2, -1])/6, "IV 反对称 N=6": np.array([1, 2, 3, -3, -2, -1])/12}
for name, h in types.items():
    n = np.arange(len(h)); print("  %-14s |H(0)|=%.3f  |H(π)|=%.3f" % (name, abs(h.sum()), abs((h*(-1)**n).sum())))
assert abs(types["II 对称 N=6"].sum() * 0 + (types["II 对称 N=6"]*(-1)**np.arange(6)).sum()) < 1e-12
assert abs(types["IV 反对称 N=6"].sum()) < 1e-12 and abs(types["III 反对称 N=5"].sum()) < 1e-12
print("FIR_STRUCTURES_OK")
