"""5.3 IIR 级联型与并联型：例 5.3 的两种拆法；六阶系统系数舍入时直接型与级联型的极点位移
课程站 ch5 的 Python 对照版，与 demo_iir_cascade_parallel.m 同一算法。运行：python 本文件（numpy、scipy）。
"""
import numpy as np
from scipy import signal

def dtft_resp(b, a, w):
    z = np.exp(-1j*np.asarray(w)); return np.polyval(np.atleast_1d(b)[::-1], z) / np.polyval(np.atleast_1d(a)[::-1], z)

A = 3; b1, a1 = np.array([1, 1.]), np.array([1, -0.6]); b2, a2 = np.array([1, -3.14, 1]), np.array([1, 0.7, 0.72])   # 例 5.3
B, Aa = A*np.convolve(b1, b2), np.convolve(a1, a2)
delta = signal.unit_impulse(30)
h_dir = signal.lfilter(B, Aa, delta)
h_cas = A*signal.lfilter(b2, a2, signal.lfilter(b1, a1, delta))
print("级联 vs 直接型最大差 %.1e" % np.max(np.abs(h_cas - h_dir))); assert np.max(np.abs(h_cas - h_dir)) < 1e-12

col = lambda p: np.r_[p, np.zeros(4-len(p))]
Mtx = np.column_stack([col(Aa), col(a2), col(np.convolve([1, 0], a1)), col(np.convolve([0, 1], a1))])
G0, A1, r0, r1 = np.linalg.solve(Mtx, col(B))
h_par = G0*delta + signal.lfilter([A1], a1, delta) + signal.lfilter([r0, r1], a2, delta)
print("并联型系数：G0=%.4f A1=%.4f r0=%.4f r1=%.4f；与直接型差 %.1e" % (G0, A1, r0, r1, np.max(np.abs(h_par - h_dir))))
assert np.max(np.abs(h_par - h_dir)) < 1e-9
print("教材例 5.4 第一节分母 1−2.95z⁻¹+3.14z⁻² 的极点模 %.3f（在单位圆外）" % np.max(np.abs(np.roots([1, -2.95, 3.14]))))

rp, th = 0.98, np.array([0.10, 0.12, 0.14])*np.pi
secs = [np.array([1, -2*rp*np.cos(t), rp**2]) for t in th]
Ad = np.array([1.]);
for s in secs: Ad = np.convolve(Ad, s)
Bits = 8; q = lambda c: np.round(np.asarray(c)*2**Bits)/2**Bits
p_ex, p_dq = np.roots(Ad), np.roots(q(Ad)); p_cq = np.concatenate([np.roots(q(s)) for s in secs])
d_dir = max(np.min(np.abs(p_dq - p)) for p in p_ex); d_cas = max(np.min(np.abs(p_cq - p)) for p in p_ex)
print("系数舍入到 2^-%d：极点最大位移 直接型 %.4f（最大模 %.3f），级联型 %.4f（最大模 %.3f）"
      % (Bits, d_dir, np.max(np.abs(p_dq)), d_cas, np.max(np.abs(p_cq))))
assert d_cas < 0.02 and d_dir > 5*d_cas
print("IIR_CASCADE_PARALLEL_OK")
