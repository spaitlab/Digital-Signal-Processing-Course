"""2.3 频域分析：频率响应、DTFT 对称性、z 变换收敛域、s–z 映射
课程站 ch2 的 Python 对照版，与 demo_frequency_domain.m 同一算法。运行：python 本文件（numpy、scipy、matplotlib）。
"""
import numpy as np
from scipy.signal import lfilter
import matplotlib.pyplot as plt
plt.rcParams['font.sans-serif'] = ['Microsoft YaHei', 'SimHei', 'DejaVu Sans']; plt.rcParams['axes.unicode_minus'] = False

M = 5; h = np.ones(M)/M
w = np.linspace(-2*np.pi, 2*np.pi, 2001)
H = lambda w: np.exp(-1j*np.outer(np.arange(M), np.atleast_1d(w))).T @ h        # Σ h(n) e^{-jωn}
w_test = np.array([0.2, 0.4, 0.8])*np.pi; n_test = np.arange(60)
amp_out = np.array([abs(lfilter(h, [1.0], np.exp(1j*wk*n_test))[-1]) for wk in w_test])
amp_formula = np.abs(H(w_test))
print("5 点平均：ω/π =", w_test/np.pi, "实测输出幅度", np.round(amp_out, 6), "公式", np.round(amp_formula, 6))
assert np.max(np.abs(amp_out - amp_formula)) < 1e-10 and amp_formula[1] < 1e-12
assert np.max(np.abs(np.abs(H(w)) - np.abs(H(w + 2*np.pi)))) < 1e-12               # 2π 周期

x = np.array([1, 2, 3, 2, 1]); nx = np.arange(5)
X = lambda w: np.exp(-1j*np.outer(nx, np.atleast_1d(w))).T @ x
Xw = X(w)
print("实序列对称性：|X| 偶 %.1e，Re 偶 %.1e，Im 奇 %.1e" % (np.max(np.abs(np.abs(X(w)) - np.abs(X(-w)))), np.max(np.abs(X(w).real - X(-w).real)), np.max(np.abs(X(w).imag + X(-w).imag))))
assert np.max(np.abs(np.abs(X(w)) - np.abs(X(-w)))) < 1e-12

a = 0.8; nz = np.arange(-40, 41)
x1 = a**nz*(nz >= 0); x2 = -(a**nz)*(nz <= -1)
wq = np.linspace(-np.pi, np.pi, 801)
X1_dtft = np.exp(-1j*np.outer(nz, wq)).T @ x1
X1_formula = 1/(1 - a*np.exp(-1j*wq))
err_roc = np.max(np.abs(X1_dtft - X1_formula))
print("右边序列 0.8^n u(n)：DTFT 直接求和 vs X(z)|z=e^jω 最大差 %.1e；左边序列 Σ|x| 部分和 = %.1f（发散）" % (err_roc, np.sum(np.abs(x2))))
assert err_roc < 1e-3 and np.sum(np.abs(x2)) > 100

T = 1/100; Ws = 2*np.pi/T
Omega = np.array([0, Ws/8, Ws/4, Ws/2, 3*Ws/4, Ws]); zmap = np.exp(1j*Omega*T)
print("z = e^{jΩT}：Ω = Ωs/2 →", np.round(zmap[3], 12), "；Ω = Ωs →", np.round(zmap[5], 12))
assert abs(zmap[5] - 1) < 1e-12 and abs(zmap[3] + 1) < 1e-12
print("FREQUENCY_OK")

fig, ax = plt.subplots(2, 2, figsize=(12, 9))
ax[0,0].plot(w/np.pi, np.abs(H(w))); ax[0,0].stem(w_test/np.pi, amp_out, linefmt="C1-", markerfmt="C1o", basefmt=" "); ax[0,0].set_title("① |H(e^jω)| 以 2π 为周期")
ax[0,1].plot(w/np.pi, Xw.real); ax[0,1].plot(w/np.pi, Xw.imag); ax[0,1].plot(w/np.pi, np.abs(Xw), "k--"); ax[0,1].set_xlim(-1, 1); ax[0,1].set_title("② 实序列 DTFT：实部偶、虚部奇")
th = np.linspace(0, 2*np.pi, 200)
ax[1,0].plot(np.cos(th), np.sin(th), "k"); ax[1,0].plot(a*np.cos(th), a*np.sin(th), "r--"); ax[1,0].plot(a, 0, "rx", ms=10); ax[1,0].set_aspect("equal"); ax[1,0].set_title("③ 极点 0.8，ROC |z|>0.8 含单位圆")
ax[1,1].plot(np.cos(th), np.sin(th), "k"); ax[1,1].plot(zmap.real, zmap.imag, "o"); ax[1,1].set_aspect("equal"); ax[1,1].set_title("④ z = e^{sT}：虚轴绕到单位圆")
for a_ in ax.flat: a_.grid(True)
plt.tight_layout(); plt.show()
