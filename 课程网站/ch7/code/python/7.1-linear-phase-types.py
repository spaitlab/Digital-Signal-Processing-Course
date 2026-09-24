"""7.1 线性相位 FIR 四型：教材例 7.1—7.4 的 a/b/c/d(n)、H(ω)，与 DTFT 对照
课程站 ch7 的 Python 对照版，与 demo_linear_phase_types.m 同一公式。运行：python 本文件（numpy）。
"""
import numpy as np

hs = [np.array([-3, 1, -1, -2, 5, 6, 5, -2, -1, 1, -3.]), np.array([1, 2, -1, 3, 4, 4, 3, -1, 2, 1.]),
      np.array([-1, 1, -2, 2, -3, 0, 3, -2, 2, -1, 1.]), np.array([-1, 1, -2, 2, -3, 3, -2, 2, -1, 1.])]
w = np.linspace(0, np.pi, 1024)
for t, h in enumerate(hs, 1):
    N = h.size; H = np.polyval(h[::-1], np.exp(-1j*w))
    if t == 1:
        L = (N-1)//2; a = np.r_[h[L], 2*h[L-1::-1]]; Hw = a @ np.cos(np.outer(np.arange(L+1), w)); ph = -(N-1)*w/2
    elif t == 2:
        L = N//2; b = 2*h[L-1::-1]; Hw = b @ np.cos(np.outer(np.arange(1, L+1) - 0.5, w)); ph = -(N-1)*w/2
    elif t == 3:
        L = (N-1)//2; c = 2*h[L-1::-1]; Hw = c @ np.sin(np.outer(np.arange(1, L+1), w)); ph = -(N-1)*w/2 + np.pi/2
    else:
        L = N//2; d = 2*h[L-1::-1]; Hw = d @ np.sin(np.outer(np.arange(1, L+1) - 0.5, w)); ph = -(N-1)*w/2 + np.pi/2
    err = np.max(np.abs(H - Hw*np.exp(1j*ph)))
    print("%d 型 N=%d：H(0)=%.0f H(π)=%.0f，群延迟 %.1f，H(ω)e^{jθ} 与 DTFT 差 %.1e" % (t, N, Hw[0], Hw[-1], (N-1)/2, err))
    assert err < 1e-10
    if t == 2: assert abs(Hw[-1]) < 1e-10
    if t == 3: assert abs(Hw[0]) < 1e-10 and abs(Hw[-1]) < 1e-10
    if t == 4: assert abs(Hw[0]) < 1e-10
print("LINEAR_PHASE_TYPES_OK")
