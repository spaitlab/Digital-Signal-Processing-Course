"""5.5 FIR 频率采样型结构：梳状滤波器 × 谐振器，r=1 与 r<1，实系数二阶节，系数舍入后的残余
课程站 ch5 的 Python 对照版，与 demo_frequency_sampling.m 同一算法。运行：python 本文件（numpy、scipy）。
"""
import numpy as np
from scipy import signal

N = 16; Hk = np.zeros(N, complex); Hk[0] = 12; Hk[1] = -3-3j; Hk[2] = 1+1j; Hk[14] = 1-1j; Hk[15] = -3+3j   # 习题 8
h = np.fft.ifft(Hk); assert np.max(np.abs(h.imag)) < 1e-12; h = h.real
used = np.flatnonzero(Hk)

def freq_sampling(Hk, r, x):                      # 式 (5.3.6)/(5.3.7)：复数谐振器并联
    v = signal.lfilter(np.r_[1, np.zeros(N-1), -r**N], [1], x); y = np.zeros(len(x), complex)
    for k in used: y += signal.lfilter([Hk[k]], [1, -r*np.exp(2j*np.pi*k/N)], v)
    return y.real/N

def freq_sampling_real(Hk, r, x, Bq=None):        # 式 (5.3.10)—(5.3.12)：共轭对合并成实系数二阶节
    q = (lambda c: np.asarray(c, float)) if Bq is None else (lambda c: np.round(np.asarray(c, float)*2**Bq)/2**Bq)
    v = signal.lfilter(q(np.r_[1, np.zeros(N-1), -r**N]), [1], x)
    y = signal.lfilter(q([Hk[0].real]), q([1, -r]), v)
    if N % 2 == 0 and Hk[N//2] != 0: y += signal.lfilter(q([Hk[N//2].real]), q([1, r]), v)
    for k in range(1, (N+1)//2):
        if Hk[k] == 0: continue
        mag, th, wk = abs(Hk[k]), np.angle(Hk[k]), 2*np.pi*k/N
        y += signal.lfilter(q(2*mag*np.array([np.cos(th), -r*np.cos(th-wk)])), q([1, -2*r*np.cos(wk), r**2]), v)
    return y/N

L = 1000; delta = signal.unit_impulse(L)
y1 = freq_sampling(Hk, 1, delta); y99 = freq_sampling(Hk, 0.99, delta)
e1, t1 = np.max(np.abs(y1[:N]-h)), np.max(np.abs(y1[N:])); e99 = np.max(np.abs(y99[:N] - h*0.99**np.arange(N)))
print("h(n) =", np.round(h, 4))
print("频率采样型 r=1：与直接型差 %.1e，尾巴 %.1e；r=0.99 得 h(n)·r^n，差 %.1e" % (e1, t1, e99))
yR = freq_sampling_real(Hk, 1, delta); eR = np.max(np.abs(yR[:N]-h))
tq1 = np.abs(freq_sampling_real(Hk, 1, delta, 10)[N:]); tq99 = np.abs(freq_sampling_real(Hk, 0.99, delta, 10)[N:])
print("实系数二阶节 r=1 差 %.1e；系数舍入到 2^-10 后 n≥N 的残余：r=1 末段 %.1e，r=0.99 末段 %.1e" % (eR, tq1[-50:].max(), tq99[-50:].max()))
assert e1 < 1e-12 and e99 < 1e-12 and eR < 1e-12 and t1 < 1e-12 and tq99[-50:].max() < tq1[-50:].max()/100
print("FREQUENCY_SAMPLING_OK")
