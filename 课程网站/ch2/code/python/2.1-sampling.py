"""2.1 采样定理：采样、频谱周期延拓与混叠、内插恢复
课程站 ch2 的 Python 对照版，与 demo_sampling.m 同一算法。运行：python 本文件（numpy、matplotlib）。
"""
import numpy as np
import matplotlib.pyplot as plt
plt.rcParams['font.sans-serif'] = ['Microsoft YaHei', 'SimHei', 'DejaVu Sans']; plt.rcParams['axes.unicode_minus'] = False

f0, dur = 5, 1.0
xa = lambda t: np.cos(2*np.pi*f0*t)
tc = np.arange(0, dur + 1e-9, 1e-4)
fs_high, fs_low = 50, 6
tH = np.arange(0, fs_high*dur + 1)/fs_high; xH = xa(tH)
tL = np.arange(0, fs_low*dur + 1)/fs_low;   xL = xa(tL)
f_alias = abs(f0 - fs_low)                                          # 1 Hz
assert np.max(np.abs(xL - np.cos(2*np.pi*f_alias*tL))) < 1e-12     # 6 Hz 样本与 1 Hz 正弦逐点重合

# 频谱周期延拓：2、5、8 Hz 三个分量，fs=20 不重叠，fs=12 时 8 Hz 折到 4 Hz
tones = np.array([2, 5, 8])
def lines(fs): return (np.arange(-3, 4)[:, None]*fs + np.r_[tones, -tones][None, :]).ravel()
slB = lines(12); folded = slB[(slB > 0) & (slB < 6) & ~np.isin(slB, tones)]
print("fs=12 Hz 时落入 (0,6) 的非原有谱线:", np.unique(folded))     # [4]

# 内插公式恢复：fs=12 Hz 的样本 → 5 Hz
fsR = 12; T = 1/fsR; nR = np.arange(-60, 61); tR = nR*T; xR = xa(tR)
sinc_u = lambda z: np.sinc(z/np.pi)                                 # sin(z)/z
tq = np.arange(0, dur + 1e-9, 1e-3)
x_rec = sum(xR[k]*sinc_u(np.pi*(tq - tR[k])/T) for k in range(nR.size))
idx = np.minimum(np.searchsorted(tR, tq, side="right") - 1, tR.size - 1)
x_zoh = xR[idx]; x_lin = np.interp(tq, tR, xR)
err = [np.max(np.abs(v - xa(tq))) for v in (x_rec, x_zoh, x_lin)]
print("恢复误差：sinc 内插 %.4f，零阶保持 %.3f，线性内插 %.3f" % tuple(err))
assert err[0] < 0.02 and err[1] > 0.5 and err[2] > 0.2
# 混叠情形：6 Hz 样本内插只能得到 1 Hz
T6 = 1/fs_low; n6 = np.arange(-30, 31); t6 = n6*T6; x6 = xa(t6)
x_rec6 = sum(x6[k]*sinc_u(np.pi*(tq - t6[k])/T6) for k in range(n6.size))
A = np.c_[np.cos(2*np.pi*f_alias*tq), np.sin(2*np.pi*f_alias*tq)]
c = np.linalg.lstsq(A, x_rec6, rcond=None)[0]; amp_alias = np.hypot(*c)
print("6 Hz 样本内插结果拟合为 1 Hz 正弦，幅度 %.4f" % amp_alias); assert abs(amp_alias - 1) < 0.05
print("SAMPLING_OK")

fig, ax = plt.subplots(2, 2, figsize=(12, 9))
ax[0,0].plot(tc, xa(tc), color="0.6"); ax[0,0].stem(tH, xH, basefmt=" "); ax[0,0].stem(tL, xL, linefmt="C1-", markerfmt="C1o", basefmt=" ")
ax[0,0].plot(tc, np.cos(2*np.pi*f_alias*tc), "r:"); ax[0,0].set_title("① 5 Hz：fs=50 够，fs=6 不够（像 1 Hz）")
ax[0,1].stem(lines(20), np.tile(np.r_[[1, .8, .6], [1, .8, .6]], 7), basefmt=" "); ax[0,1].stem(lines(12), np.tile(np.r_[[1, .8, .6], [1, .8, .6]], 7), linefmt="C1-", markerfmt="C1o", basefmt=" ")
ax[0,1].set_xlim(-30, 30); ax[0,1].set_title("② 频谱以 fs 重复：20 Hz 不重叠，12 Hz 混叠")
ax[1,0].plot(tq, xa(tq), "k:"); ax[1,0].plot(tq, x_rec); ax[1,0].plot(tq, x_zoh, color="0.6"); ax[1,0].plot(tq, x_lin, "--"); ax[1,0].set_title("③ 12 Hz 样本恢复 5 Hz")
ax[1,1].plot(tq, xa(tq), "k:"); ax[1,1].plot(tq, x_rec6); ax[1,1].set_title("④ 6 Hz 样本内插只能得到 1 Hz")
for a in ax.flat: a.grid(True)
plt.tight_layout(); plt.show()
