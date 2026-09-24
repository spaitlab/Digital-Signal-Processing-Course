"""4.1—4.2 DFT 效率问题与按时间抽取 FFT：运算量、实测时间、位反转、自写 DIT
课程站 ch4 的 Python 对照版，与 demo_fft_cost.m 同一算法。运行：python 本文件（numpy、matplotlib）。
"""
import time
import numpy as np
import matplotlib.pyplot as plt
plt.rcParams['font.sans-serif'] = ['Microsoft YaHei', 'SimHei', 'DejaVu Sans']; plt.rcParams['axes.unicode_minus'] = False

N_list = 2**np.arange(3, 15)
md, mF = N_list**2, N_list/2*np.log2(N_list)
print("N=2048：直接 %d 次复乘，FFT %d 次，%.1f 倍" % (md[8], mF[8], md[8]/mF[8]))
assert abs(md[8]/mF[8] - 2048**2/(1024*11)) < 1e-9

def bitrev_order(N):
    v = int(np.log2(N)); out = []
    for n in range(N):
        r, m = 0, n
        for _ in range(v): r, m = r*2 + (m & 1), m >> 1
        out.append(r)
    return np.array(out)

def fft_dit(x):
    x = np.asarray(x, dtype=complex); N = x.size; v = int(np.log2(N))
    X = x[bitrev_order(N)].copy(); stages = [X.copy()]
    for s in range(1, v+1):
        L = 2**s; half = L//2; W = np.exp(-2j*np.pi*np.arange(half)/L)
        for start in range(0, N, L):
            for k in range(half):
                a, b = X[start+k], W[k]*X[start+k+half]        # DIT：先乘旋转因子
                X[start+k], X[start+k+half] = a+b, a-b
        stages.append(X.copy())
    return X, np.array(stages)

X8, stages8 = fft_dit(np.arange(1, 9))
print("N=8 位反转顺序:", bitrev_order(8), "; |X8| =", np.round(np.abs(X8), 3))
assert np.array_equal(bitrev_order(8), [0, 4, 2, 6, 1, 5, 3, 7]) and np.max(np.abs(X8 - np.fft.fft(np.arange(1, 9)))) < 1e-12
xt = np.random.default_rng(1).normal(size=1024) + 1j*np.random.default_rng(2).normal(size=1024)
print("自写 DIT vs numpy fft（N=1024）最大差 %.1e" % np.max(np.abs(fft_dit(xt)[0] - np.fft.fft(xt))))

Nt = 2**np.arange(6, 13); t_direct = []; t_fft = []
for N in Nt:
    x = np.random.default_rng(0).normal(size=N) + 0j; n = np.arange(N); W = np.exp(-2j*np.pi*np.outer(n, n)/N)
    reps = max(1, int(2e7/N**2)); t0 = time.perf_counter(); [W @ x for _ in range(reps)]; t_direct.append((time.perf_counter()-t0)/reps)
    t0 = time.perf_counter(); [np.fft.fft(x) for _ in range(200)]; t_fft.append((time.perf_counter()-t0)/200)
print("N=%d：矩阵法 %.2f ms，fft %.4f ms" % (Nt[-1], t_direct[-1]*1e3, t_fft[-1]*1e3))
print("FFT_COST_OK")

fig, ax = plt.subplots(2, 2, figsize=(12, 9))
ax[0,0].loglog(N_list, md, "-o"); ax[0,0].loglog(N_list, mF, "-s"); ax[0,0].set_title("① 复乘次数 N² vs (N/2)log₂N")
ax[0,1].loglog(Nt, np.array(t_direct)*1e3, "-o"); ax[0,1].loglog(Nt, np.array(t_fft)*1e3, "-s"); ax[0,1].set_title("② 实测用时 (ms)")
ax[1,0].stem(np.arange(8), bitrev_order(8), basefmt=" "); ax[1,0].set_title("③ N=8 位反转顺序")
for s in range(stages8.shape[0]): ax[1,1].stem(np.arange(8) + (s-1.5)*0.15, np.abs(stages8[s]), linefmt=f"C{s}-", markerfmt=f"C{s}o", basefmt=" ")
ax[1,1].set_title("④ 三级蝶形每级后的幅值")
for a in ax.flat: a.grid(True)
plt.tight_layout(); plt.show()
