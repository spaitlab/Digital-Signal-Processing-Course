"""7.3 窗函数法思想：理想低通截断、吉布斯过冲、矩形窗主瓣/旁瓣、−21 dB 与 4π/N
课程站 ch7 的 Python 对照版，与 demo_window_method.m 同一公式。运行：python 本文件（numpy）。
"""
import numpy as np

def ideal_lp(wc, alpha, n):
    n = np.asarray(n, float); h = np.full(n.shape, wc/np.pi); i = np.abs(n - alpha) > 1e-12
    h[i] = np.sin(wc*(n[i] - alpha))/(np.pi*(n[i] - alpha)); return h

def local_maxima(x):
    return np.flatnonzero((x[1:-1] > x[:-2]) & (x[1:-1] >= x[2:])) + 1

wc = 0.5*np.pi; w = np.linspace(0, np.pi, 8192)
for N in (21, 51, 101):
    h = ideal_lp(wc, (N-1)/2, np.arange(N)); H = np.abs(np.polyval(h[::-1], np.exp(-1j*w)))
    ov = H[w < wc].max() - 1; atwc = np.interp(wc, w, H)
    print("N=%d：通带过冲 %.2f%%，ω_c 处 %.3f" % (N, 100*ov, atwc)); assert abs(ov - 0.0895) < 0.004 and abs(atwc - 0.5) < 0.01
    if N == 51:
        dB = 20*np.log10(H); iwc = np.argmax(w >= wc)
        lmax = local_maxima(H); lmin = local_maxima(-H)
        w_pass_peak = w[lmax[lmax < iwc][-1]]; w_stop_min = w[lmin[lmin > iwc][0]]
        att = -20*np.log10(H[w > w_stop_min].max())
        print("N=51 矩形窗低通：阻带最小衰减 %.1f dB，过渡带 %.4fπ（4π/N=%.4fπ）" % (att, (w_stop_min - w_pass_peak)/np.pi, 4/N))
        assert abs(att - 21) < 1 and abs(w_stop_min - w_pass_peak - 4*np.pi/N) < np.pi/N      # 实测约 3.2π/N，教材近似 4π/N
N = 51; WR = np.where(w == 0, N, np.sin(N*w/2)/np.where(w == 0, 1, np.sin(w/2)))
pk = np.abs(WR)[local_maxima(np.abs(WR))]; print("矩形窗第一旁瓣 %.1f dB，主瓣宽 4π/N=%.4fπ" % (20*np.log10(pk[0]/N), 4/N))
assert abs(20*np.log10(pk[0]/N) + 13.3) < 0.5
print("WINDOW_METHOD_OK")
