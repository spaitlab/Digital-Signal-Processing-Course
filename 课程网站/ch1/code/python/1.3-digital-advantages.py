"""1.3 数字系统的优点：精度、灵活性、可靠性（可重复）、时分复用
课程站 ch1 的 Python 对照版，与 demo_digital_advantages.m 同一算法。运行：python 本文件（需要 numpy、scipy、matplotlib）。
"""
import numpy as np
from scipy.signal import lfilter
import matplotlib.pyplot as plt
plt.rcParams['font.sans-serif'] = ['Microsoft YaHei', 'SimHei', 'DejaVu Sans']; plt.rcParams['axes.unicode_minus'] = False

fs = 100; n = np.arange(200); t = n/fs
x = np.sin(2*np.pi*2*t) + 0.5*np.sin(2*np.pi*15*t)
fgrid = np.linspace(0, fs/2, 501)
def dtft(h, f):
    f = np.atleast_1d(f); k = np.arange(len(h))
    return np.abs(np.exp(-2j*np.pi*np.outer(f, k)/fs) @ h)

# ① 精度：21 点低通（截止 6 Hz，Hann 窗），系数 16 位 / 4 位定点
L, fc = 21, 6; k = np.arange(L)
z = 2*np.pi*fc/fs*(k - (L-1)/2)
hd = 2*fc/fs * np.where(z == 0, 1.0, np.sin(z)/np.where(z == 0, 1, z))
h = hd*(0.5 - 0.5*np.cos(2*np.pi*k/(L-1))); h /= h.sum()
qcoef = lambda v, bits: np.round(v*2**(bits-1))/2**(bits-1)
h16, h4 = qcoef(h, 16), qcoef(h, 4)
H, H16, H4 = dtft(h, fgrid), dtft(h16, fgrid), dtft(h4, fgrid)
db = lambda v: 20*np.log10(np.maximum(v, 1e-6))

# ② 灵活性：同一条 lfilter，换系数
hlp = h.copy(); hhp = -h.copy(); hhp[(L-1)//2] += 1
ylp, yhp = lfilter(hlp, [1.0], x), lfilter(hhp, [1.0], x)

# ③ 可靠性：数字两次完全相同；模拟元件 ±5% 漂移 100 次
y1, y2 = lfilter(hlp, [1.0], x), lfilter(hlp, [1.0], x)
repeat_diff = np.max(np.abs(y1 - y2))
rng = np.random.default_rng(20260918); runs = 100
ya = np.empty((runs, x.size))
for r in range(runs):
    fcr = 6*(1 + 0.05*(2*rng.random() - 1)); a = np.exp(-2*np.pi*fcr/fs)
    ya[r] = lfilter([1 - a], [1, -a], x)
analog_spread = np.max(ya.max(0) - ya.min(0))

# ④ 时分复用：一套乘加器轮流处理 4 路
ch = np.array([np.sin(2*np.pi*2*t), 0.8*np.sin(2*np.pi*3*t), 0.6*np.sin(2*np.pi*4*t + 1), 0.5*np.sin(2*np.pi*1*t)]) + 0.5*np.sin(2*np.pi*15*t)
C = ch.shape[0]
stream = ch.T.reshape(-1)                      # 按时刻交织
out = np.zeros_like(stream); state = np.zeros((C, L-1))
for i, s in enumerate(stream):
    c = i % C
    o, state[c] = lfilter(hlp, [1.0], [s], zi=state[c]); out[i] = o[0]
out_ch = out.reshape(-1, C).T
sep_ch = lfilter(hlp, [1.0], ch, axis=1)
tdm_diff = np.max(np.abs(out_ch - sep_ch))

print(f"系数量化误差：16 位 {np.max(abs(h-h16)):.2e}，4 位 {np.max(abs(h-h4)):.2e}")
print(f"阻带(≥12 Hz)最差衰减：理想 {db(H[fgrid>=12]).max():.1f} dB，16 位 {db(H16[fgrid>=12]).max():.1f} dB，4 位 {db(H4[fgrid>=12]).max():.1f} dB")
print(f"低通增益：2 Hz {dtft(hlp, 2)[0]:.4f}，15 Hz {dtft(hlp, 15)[0]:.4f}；高通增益：2 Hz {dtft(hhp, 2)[0]:.4f}，15 Hz {dtft(hhp, 15)[0]:.4f}")
print(f"数字两次运行差 = {repeat_diff}；模拟漂移输出带最大宽度 = {analog_spread:.4f}；时分复用与单独处理差 = {tdm_diff}")
assert repeat_diff == 0 and tdm_diff < 1e-12 and analog_spread > 0.01
print("ADVANTAGES_OK")

fig, ax = plt.subplots(2, 2, figsize=(12, 9))
ax[0,0].plot(fgrid, db(H), "k"); ax[0,0].plot(fgrid, db(H16), "--"); ax[0,0].plot(fgrid, db(H4)); ax[0,0].set_ylim(-80, 5); ax[0,0].set_title("① 精度：系数 16 位 vs 4 位")
ax[0,1].plot(t, x, color="0.7"); ax[0,1].plot(t, ylp); ax[0,1].plot(t, yhp); ax[0,1].set_xlim(0.3, 1.3); ax[0,1].set_title("② 灵活性：换系数，低通变高通")
ax[1,0].fill_between(t, ya.min(0), ya.max(0), color="#ffccb3"); ax[1,0].plot(t, y1); ax[1,0].set_xlim(0.3, 1.3); ax[1,0].set_title("③ 可靠性：模拟漂移带 vs 数字")
ax[1,1].plot(t, out_ch.T); ax[1,1].set_xlim(0, 1.2); ax[1,1].set_title("④ 时分复用：一套设备处理 4 路")
for a in ax.flat: a.grid(True)
plt.tight_layout(); plt.show()
