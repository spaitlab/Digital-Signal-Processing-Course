"""1.2 数字信号处理过程：模拟信号 → 采样 → 量化 → 数字处理 → D/A → 平滑
课程站 ch1 的 Python 对照版，与 demo_dsp_chain.m 同一算法。运行：python 本文件（需要 numpy、scipy、matplotlib）。
"""
import numpy as np
from scipy.signal import lfilter
import matplotlib.pyplot as plt
plt.rcParams['font.sans-serif'] = ['Microsoft YaHei', 'SimHei', 'DejaVu Sans']; plt.rcParams['axes.unicode_minus'] = False

fs, dur = 100, 2.0
xa = lambda t: np.sin(2*np.pi*2*t) + 0.5*np.sin(2*np.pi*15*t)      # 2 Hz 想要的 + 15 Hz 干扰
tc = np.arange(0, dur + 1e-9, 1e-4)                                # “连续”时间网格
n = np.arange(int(dur*fs) + 1); t = n/fs
x = xa(t)                                                          # 采样

full = 2.0   # 量化范围 ±2，信号峰值 1.5，不削顶
def quantize(v, bits):
    step = 2*full/2**bits
    return np.clip(np.round(v/step)*step, -full, full - step)
x3, x8 = quantize(x, 3), quantize(x, 8)
step3, step8 = 2*full/2**3, 2*full/2**8

M = 5; b = np.ones(M)/M
y = lfilter(b, [1.0], x8)                                          # 相邻 5 个数取平均

# D/A：零阶保持 + 20 ms 平滑
idx = np.minimum(np.searchsorted(t, tc, side="right") - 1, len(t) - 1)
yzoh = y[idx]
smooth = int(round(0.02/1e-4)); ysmooth = lfilter(np.ones(smooth)/smooth, [1.0], yzoh)

# 核验：量化误差界；5 点平均对 2 Hz、15 Hz 的增益 vs 稳态拟合
assert np.max(np.abs(x - x3)) <= step3/2 + 1e-12 and np.max(np.abs(x - x8)) <= step8/2 + 1e-12
gain = lambda f: abs(np.sin(M*np.pi*f/fs) / (M*np.sin(np.pi*f/fs)))
sel = n >= M - 1; tt = t[sel]
A = np.c_[np.sin(2*np.pi*2*tt), np.cos(2*np.pi*2*tt), np.sin(2*np.pi*15*tt), np.cos(2*np.pi*15*tt), np.ones(tt.size)]
c = np.linalg.lstsq(A, y[sel], rcond=None)[0]
amp2, amp15 = np.hypot(c[0], c[1]), np.hypot(c[2], c[3])
print(f"量化台阶：3 位 {step3:.4f}，8 位 {step8:.5f}；最大量化误差：3 位 {np.max(abs(x-x3)):.4f}，8 位 {np.max(abs(x-x8)):.5f}")
print(f"5 点平均增益：2 Hz {gain(2):.4f}（拟合 {amp2:.4f}），15 Hz {gain(15):.4f}（拟合幅值 {amp15:.4f}，输入 0.5）")
assert abs(amp2 - gain(2)) < 0.02 and abs(amp15 - 0.5*gain(15)) < 0.02
print("CHAIN_OK")

fig, ax = plt.subplots(2, 2, figsize=(12, 9))
ax[0,0].plot(tc, xa(tc), color="0.6"); ax[0,0].stem(t, x, basefmt=" "); ax[0,0].set_xlim(0, 1); ax[0,0].set_title("① 模拟信号与采样点")
ax[0,1].stem(t, x8, basefmt=" "); ax[0,1].stem(t, x3, linefmt="C1-", markerfmt="C1o", basefmt=" "); ax[0,1].set_xlim(0, 0.5); ax[0,1].set_title("② 量化：8 位 vs 3 位")
ax[1,0].stem(t, x8, linefmt="0.6", markerfmt="o", basefmt=" "); ax[1,0].stem(t, y, basefmt=" "); ax[1,0].set_xlim(0, 1); ax[1,0].set_title("③ 数字处理：5 点平均")
ax[1,1].step(tc, yzoh, where="post", color="0.6"); ax[1,1].plot(tc, ysmooth); ax[1,1].plot(tc, np.sin(2*np.pi*2*tc), "k:"); ax[1,1].set_xlim(0, 1); ax[1,1].set_title("④ D/A：零阶保持与平滑")
for a in ax.flat: a.grid(True)
plt.tight_layout(); plt.show()
