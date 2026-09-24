"""5.2 IIR 直接型结构：直接 I 型、直接 II 型、转置型的逐样本实现，与 lfilter 对照
课程站 ch5 的 Python 对照版，与 demo_iir_direct.m 同一算法。运行：python 本文件（numpy、scipy）。
"""
import numpy as np
from scipy import signal

def direct1(br, ak, x):
    M, N = len(br)-1, len(ak); xd = np.zeros(M); yd = np.zeros(N); y = np.zeros(len(x))
    for n, xn in enumerate(x):
        y[n] = br[0]*xn + br[1:] @ xd + ak @ yd
        xd = np.r_[xn, xd[:-1]]; yd = np.r_[y[n], yd[:-1]]
    return y

def direct2(br, ak, x):
    M, N = len(br)-1, len(ak); K = max(M, N)
    brp = np.r_[br, np.zeros(K-M)]; akp = np.r_[ak, np.zeros(K-N)]; wd = np.zeros(K); y = np.zeros(len(x))
    for n, xn in enumerate(x):
        wn = xn + akp @ wd                      # w(n)=x(n)+Σ a_k w(n−k)
        y[n] = brp[0]*wn + brp[1:] @ wd         # y(n)=Σ b_r w(n−r)
        wd = np.r_[wn, wd[:-1]]
    return y

def transposed(br, ak, x):
    M, N = len(br)-1, len(ak); K = max(M, N)
    brp = np.r_[br, np.zeros(K-M)]; akp = np.r_[ak, np.zeros(K-N)]; s = np.zeros(K+1); y = np.zeros(len(x))
    for n, xn in enumerate(x):
        y[n] = brp[0]*xn + s[0]
        for i in range(K): s[i] = brp[i+1]*xn + akp[i]*y[n] + s[i+1]
    return y

b = np.array([1, -3, 11, 27, 18.])/16; a = np.array([16, 12, 2, -4, -2.])/16   # 例 5.1，a0 归一
br, ak = b, -a[1:]
delta = signal.unit_impulse(30); u = np.ones(30)
h_ref, s_ref = signal.lfilter(b, a, delta), signal.lfilter(b, a, u)
errs = [np.max(np.abs(f(br, ak, delta) - h_ref)) for f in (direct1, direct2, transposed)] + \
       [np.max(np.abs(f(br, ak, u) - s_ref)) for f in (direct1, direct2, transposed)]
print("h(n) 前 8 点:", np.round(h_ref[:8], 5))
print("直接 I / II / 转置 与 lfilter 最大差（脉冲、阶跃）:", ["%.1e" % e for e in errs])
assert max(errs) < 1e-12
poles = np.roots(a); print("极点模:", np.round(np.abs(poles), 4), " 延时单元：I 型 %d，II 型 %d" % (8, 4))
assert np.max(np.abs(poles)) < 1
print("IIR_DIRECT_OK")
