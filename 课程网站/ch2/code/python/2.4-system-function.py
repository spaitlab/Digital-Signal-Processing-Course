"""2.4 系统函数：差分方程 ↔ H(z)，几何法求频率响应，稳定性，IIR 与 FIR
课程站 ch2 的 Python 对照版，与 demo_system_function.m 同一算法。运行：python 本文件（numpy、scipy、matplotlib）。
"""
import numpy as np
from scipy.signal import lfilter
import matplotlib.pyplot as plt
plt.rcParams['font.sans-serif'] = ['Microsoft YaHei', 'SimHei', 'DejaVu Sans']; plt.rcParams['axes.unicode_minus'] = False

b, a = np.array([1.0, 1.0]), np.array([1.0, -1.2, 0.72])          # y − 1.2y(n−1) + 0.72y(n−2) = x + x(n−1)
zeros_, poles_ = np.roots(np.r_[b,0]), np.roots(a)
N = 40; imp = np.r_[1.0, np.zeros(N-1)]
h = lfilter(b, a, imp)
lhs = h - 1.2*np.r_[0, h[:-1]] + 0.72*np.r_[0, 0, h[:-2]]; rhs = imp + np.r_[0, imp[:-1]]
assert np.max(np.abs(lhs - rhs)) < 1e-12                          # h 满足差分方程
w = np.linspace(0, np.pi, 801); z = np.exp(1j*w)
Hw = np.polyval(b[::-1], 1/z)/np.polyval(a[::-1], 1/z)             # 用 z^{-1} 多项式求值
geo = np.array([abs(np.prod(np.exp(1j*wk) - zeros_))/abs(np.prod(np.exp(1j*wk) - poles_)) for wk in w])
Gfull = np.array([np.prod(q-zeros_)/np.prod(q-poles_) for q in z])
assert np.max(np.abs(Gfull-Hw))<1e-10
err_geo = np.max(np.abs(geo - np.abs(Hw)))
print("零点", zeros_, "极点", np.round(poles_, 4), "|p| = %.4f" % abs(poles_[0]))
print("几何法 vs 直接求值最大差 %.1e" % err_geo); assert err_geo < 1e-10

h_long = lfilter(b, a, np.r_[1.0, np.zeros(399)]); tail = np.sum(np.abs(h_long[200:]))
h_unstable = lfilter([1.0], [1.0, -1.2], imp)
print("稳定系统 Σ|h| = %.4f，n≥200 的尾部 = %.1e；不稳定系统 h(39)/h(38) = %.3f" % (np.sum(np.abs(h)), tail, h_unstable[-1]/h_unstable[-2]))
assert tail < 1e-6 and abs(h_unstable[-1]/h_unstable[-2] - 1.2) < 1e-9

a1, Mt = 0.9, 8; hT = a1**np.arange(Mt); zT = np.roots(hT)
hMA = np.ones(4)/4; zMA = np.roots(hMA)
HMA = np.abs(np.polyval(hMA[::-1], 1/z))
print("横向滤波器 a1^n 的零点模长 =", np.round(np.abs(zT), 6), "；四点平均零点角度/π =", np.round(np.sort(np.angle(zMA))/np.pi, 4))
assert np.max(np.abs(np.abs(zT) - a1)) < 1e-9 and HMA[0] == 1 and HMA[400] < 1e-12 and HMA[-1] < 1e-12
print("SYSTEM_OK")

th = np.linspace(0, 2*np.pi, 400)
fig, ax = plt.subplots(2, 2, figsize=(12, 9))
ax[0,0].plot(np.cos(th), np.sin(th), "k"); ax[0,0].plot(zeros_.real, zeros_.imag, "bo"); ax[0,0].plot(poles_.real, poles_.imag, "rx", ms=10); ax[0,0].set_aspect("equal"); ax[0,0].set_title("① 零极点")
ax[0,1].plot(w/np.pi, np.abs(Hw)); ax[0,1].plot(w/np.pi, geo, "r--"); ax[0,1].set_title("② |H| 直接求值 vs 几何法")
ax[1,0].stem(np.arange(N), h, basefmt=" "); ax[1,0].set_title("③ 稳定系统的 h(n)")
ax[1,1].plot(np.cos(th), np.sin(th), "k"); ax[1,1].plot(zT.real, zT.imag, "bo"); ax[1,1].plot(zMA.real, zMA.imag, "ms"); ax[1,1].set_aspect("equal"); ax[1,1].set_title("④ FIR 零点")
for a_ in ax.flat: a_.grid(True)
plt.tight_layout(); plt.show()
