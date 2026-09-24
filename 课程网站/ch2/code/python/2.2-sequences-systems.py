"""2.2 时域分析：典型序列、周期性、卷积、稳定与因果
课程站 ch2 的 Python 对照版，与 demo_sequences_systems.m 同一算法。运行：python 本文件（numpy、scipy、matplotlib）。
"""
import numpy as np
from scipy.signal import lfilter
import matplotlib.pyplot as plt
plt.rcParams['font.sans-serif'] = ['Microsoft YaHei', 'SimHei', 'DejaVu Sans']; plt.rcParams['axes.unicode_minus'] = False

n = np.arange(60)
seqA, seqB = np.cos(0.3*np.pi*n), np.cos(0.3*n)
periodicA = np.max(np.abs(seqA[:40] - np.cos(0.3*np.pi*(n[:40] + 20)))) < 1e-12
periodicB = any(np.max(np.abs(np.cos(0.3*np.arange(40)) - np.cos(0.3*(np.arange(40) + N)))) < 1e-9 for N in range(1, 201))
print("cos(0.3πn) 周期 20:", periodicA, "; cos(0.3n) 在 N≤200 内周期:", periodicB)
assert periodicA and not periodicB

x, h = np.array([1, 2, 3, 4]), np.array([3, 2, 1])
y = np.convolve(x, h)
y_manual = np.array([sum(x[k]*h[nn-k] for k in range(4) if 0 <= nn-k <= 2) for nn in range(6)])
print("卷积:", y, "手算:", y_manual); assert np.array_equal(y, y_manual) and np.array_equal(y, [3, 8, 14, 20, 11, 4])

nn = np.arange(-40, 41)
hA = 0.8**nn*(nn >= 0); hB = 1.2**nn*(nn >= 0); hC = 0.8**np.abs(nn)
sA, sB, sC = np.cumsum(np.abs(hA))[-1], np.cumsum(np.abs(hB))[-1], np.cumsum(np.abs(hC))[-1]
print("Σ|h|：0.8^n u(n) = %.4f（→5）；0.8^|n| = %.4f（→9）；1.2^n u(n) 部分和 = %.0f（发散）" % (sA, sC, sB))
assert abs(sA - 5) < 0.01 and sB > 1000 and abs(sC - 9) < 0.05
step = (nn >= 0).astype(float)
yA, yB = lfilter([1], [1, -0.8], step), lfilter([1], [1, -1.2], step)
print("阶跃响应终值：稳定系统 %.4f，不稳定系统 %.3g" % (yA[-1], yB[-1])); assert abs(yA[-1] - 5) < 0.01 and yB[-1] > 1000
print("SEQUENCES_OK")

fig, ax = plt.subplots(2, 2, figsize=(12, 9))
ax[0,0].stem(n, seqA, basefmt=" "); ax[0,0].stem(n, seqB, linefmt="C1-", markerfmt="C1o", basefmt=" "); ax[0,0].set_title("① cos(0.3πn) 周期 20；cos(0.3n) 非周期")
for j, n0 in enumerate([0, 2, 4]):
    kk = np.arange(-3, 7); hf = np.array([h[n0-k] if 0 <= n0-k <= 2 else 0 for k in kk])
    ax[0,1].stem(kk + (j-1)*0.12, hf, linefmt=f"C{j}-", markerfmt=f"C{j}o", basefmt=" ")
ax[0,1].stem(np.arange(4), x, linefmt="k-", markerfmt="ko", basefmt=" "); ax[0,1].set_title("② 翻转平移的 h(n−k) 与 x(k)")
ax[1,0].stem(np.arange(6), y, basefmt=" "); ax[1,0].set_title("③ y = x*h = [3 8 14 20 11 4]")
ax[1,1].plot(nn, np.cumsum(np.abs(hA))); ax[1,1].plot(nn, np.cumsum(np.abs(hC)), "--"); ax[1,1].plot(nn, np.cumsum(np.abs(hB))); ax[1,1].set_ylim(0, 30); ax[1,1].set_title("④ Σ|h| 的部分和")
for a in ax.flat: a.grid(True)
plt.tight_layout(); plt.show()
