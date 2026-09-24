"""4.3 按频率抽取 FFT 与 IFFT：自写 DIF、共轭法 IFFT、往返误差
课程站 ch4 的 Python 对照版，与 demo_dif_ifft.m 同一算法。运行：python 本文件（numpy、matplotlib）。
"""
import numpy as np
import matplotlib.pyplot as plt
plt.rcParams['font.sans-serif'] = ['Microsoft YaHei', 'SimHei', 'DejaVu Sans']; plt.rcParams['axes.unicode_minus'] = False

def bitrev_order(N):
    v = int(np.log2(N)); out = []
    for n in range(N):
        r, m = 0, n
        for _ in range(v): r, m = r*2 + (m & 1), m >> 1
        out.append(r)
    return np.array(out)

def fft_dif(x):
    X = np.asarray(x, dtype=complex).copy(); N = X.size; v = int(np.log2(N)); stages = [X.copy()]
    for s in range(v, 0, -1):
        L = 2**s; half = L//2; W = np.exp(-2j*np.pi*np.arange(half)/L)
        for start in range(0, N, L):
            for k in range(half):
                a, b = X[start+k], X[start+k+half]
                X[start+k], X[start+k+half] = a+b, (a-b)*W[k]      # DIF：后乘旋转因子
        stages.append(X.copy())
    out = np.empty_like(X); out[bitrev_order(N)] = X                  # 输出位反转，整理回自然顺序
    return out, np.array(stages)

a, b, W = 1+0.5j, 0.3-0.8j, np.exp(-2j*np.pi/8)
print("DIT 蝶形:", np.round([a+W*b, a-W*b], 4), "  DIF 蝶形:", np.round([a+b, (a-b)*W], 4))
X8, stages8 = fft_dif(np.arange(1, 9)); assert np.max(np.abs(X8 - np.fft.fft(np.arange(1, 9)))) < 1e-12
xt = np.random.default_rng(3).normal(size=1024) + 1j*np.random.default_rng(4).normal(size=1024)
print("自写 DIF vs numpy fft（N=1024）最大差 %.1e" % np.max(np.abs(fft_dif(xt)[0] - np.fft.fft(xt))))

n = np.arange(64); xr = np.cos(2*np.pi*5*n/64) + 0.5*np.sin(2*np.pi*13*n/64) + 0.1*(n == 10)
X = np.fft.fft(xr); x_back = np.conj(np.fft.fft(np.conj(X)))/64        # 共轭法 IFFT
print("共轭法 IFFT 与原序列最大差 %.1e；numpy ifft %.1e" % (np.max(np.abs(x_back - xr)), np.max(np.abs(np.fft.ifft(X) - xr))))
assert np.max(np.abs(x_back - xr)) < 1e-12
Nr = 2**np.arange(4, 13); rt = [np.max(np.abs(np.conj(np.fft.fft(np.conj(np.fft.fft(x))))/N - x)) for N in Nr for x in [np.random.default_rng(N).normal(size=N)]]
print("往返误差:", ["%.1e" % e for e in rt]); assert all(e < 1e-12 for e in rt)
print("DIF_IFFT_OK")

fig, ax = plt.subplots(2, 2, figsize=(12, 9))
for s in range(stages8.shape[0]): ax[0,1].stem(np.arange(8) + (s-1.5)*0.15, np.abs(stages8[s]), linefmt=f"C{s}-", markerfmt=f"C{s}o", basefmt=" ")
ax[0,1].set_title("② DIF 每级后的幅值（末级为位反转顺序）"); ax[0,0].axis("off"); ax[0,0].set_title("① DIT 先乘 W；DIF 后乘 W")
ax[1,0].stem(n, xr, linefmt="0.6", markerfmt="o", basefmt=" "); ax[1,0].stem(n, x_back.real, basefmt=" "); ax[1,0].set_title("③ 共轭法 IFFT 恢复")
ax[1,1].semilogy(Nr, rt, "-o"); ax[1,1].set_title("④ FFT→IFFT 往返误差")
for a_ in ax.flat: a_.grid(True)
plt.tight_layout(); plt.show()
