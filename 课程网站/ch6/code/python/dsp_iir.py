"""第6章公用：巴特沃思/切比雪夫模拟原型、脉冲响应不变法、双线性变换（与 MATLAB 的 dsp_*.m 同一公式）"""
import numpy as np
from scipy import signal

def butter_analog(N, Wc):
    k = np.arange(1, N+1); p = Wc*np.exp(1j*np.pi*(0.5 + (2*k-1)/(2*N)))       # 式 (6.1.7)
    return np.array([Wc**N]), np.real(np.poly(p)), p

def cheby1_analog(N, eps, Wc):
    beta = (np.sqrt(1 + 1/eps**2) + 1/eps)**(1/N)                                # 式 (6.1.22)
    a, b = (beta - 1/beta)/2, (beta + 1/beta)/2                                  # 式 (6.1.20)(6.1.21)
    th = (2*np.arange(1, N+1) - 1)*np.pi/(2*N)
    p = -a*Wc*np.sin(th) + 1j*b*Wc*np.cos(th)                                    # 式 (6.1.18)
    den = np.real(np.poly(p)); K = den[-1]/(np.sqrt(1 + eps**2) if N % 2 == 0 else 1)
    return np.array([K]), den, p, a, b

def impinvar(b, a, T, scaleT=False):
    r, p, k = signal.residue(b, a)                                               # 式 (6.2.6)
    az = np.array([1.]);
    for pj in p: az = np.convolve(az, [1, -np.exp(pj*T)])
    bz = np.zeros(len(p), complex)
    for i, (ri, pi_) in enumerate(zip(r, p)):
        q = np.array([ri])
        for j, pj in enumerate(p):
            if j != i: q = np.convolve(q, [1, -np.exp(pj*T)])
        bz[:len(q)] += q
    bz, az = bz.real, az.real
    return (T*bz if scaleT else bz), az

def bilinear(b, a, T):
    bz, az = signal.bilinear(b, a, fs=1/T)                                       # s=(2/T)(1−z⁻¹)/(1+z⁻¹)
    return bz, az

def freqs(b, a, W):
    return np.polyval(b, 1j*W) / np.polyval(a, 1j*W)

def freqz(bz, az, w):
    z = np.exp(-1j*w); return np.polyval(bz[::-1], z) / np.polyval(az[::-1], z)
