"""6.5 同一指标的四种设计（巴特沃思/切比雪夫 × 脉冲响应不变/双线性）与一道 Hz 指标的设计题
课程站 ch6 的 Python 对照版，与 demo_iir_design_compare.m 同一公式。运行：python 本文件（numpy、scipy）。
"""
import numpy as np
from scipy import signal
from dsp_iir import butter_analog, cheby1_analog, impinvar, bilinear, freqz

wp, ws, ap, as_, T = 0.2*np.pi, 0.3*np.pi, 1, 15, 1; eps = np.sqrt(10**(ap/10) - 1)
Wp2, Ws2 = 2*np.tan(wp/2), 2*np.tan(ws/2)
Nb = lambda P, S: int(np.ceil(np.log10((10**(as_/10) - 1)/(10**(ap/10) - 1))/(2*np.log10(S/P))))
Nc = lambda P, S: int(np.ceil(np.arccosh(np.sqrt(10**(as_/10) - 1)/eps)/np.arccosh(S/P)))
Wcb = lambda P, N: P/(10**(ap/10) - 1)**(1/(2*N))
designs = {}
N = Nb(wp, ws);   bA, aA, _ = butter_analog(N, Wcb(wp, N));   designs["巴特沃思+脉冲响应不变"] = (N, *impinvar(bA, aA, T))
N = Nb(Wp2, Ws2); bA, aA, _ = butter_analog(N, Wcb(Wp2, N)); designs["巴特沃思+双线性"] = (N, *bilinear(bA, aA, T))
N = Nc(wp, ws);   bA, aA, *_ = cheby1_analog(N, eps, wp);     designs["切比雪夫+脉冲响应不变"] = (N, *impinvar(bA, aA, T))
N = Nc(Wp2, Ws2); bA, aA, *_ = cheby1_analog(N, eps, Wp2);    designs["切比雪夫+双线性"] = (N, *bilinear(bA, aA, T))
w = np.linspace(0, np.pi, 2048)
for name, (N, bz, az) in designs.items():
    H = freqz(bz, az, w); Hmax = np.max(np.abs(H))
    att = -20*np.log10(np.abs(freqz(bz, az, np.array([wp, ws])))/Hmax)
    print("%-14s N=%d  ωp 处 %.3f dB  ωs 处 %.2f dB  极点最大模 %.4f" % (name, N, *att, np.max(np.abs(np.roots(az)))))
    assert att[0] <= ap + 0.05 and att[1] >= as_ - 0.5 and np.max(np.abs(np.roots(az))) < 1
assert [d[0] for d in designs.values()] == [6, 6, 4, 4]
n1, _ = signal.buttord(Wp2, Ws2, ap, as_, analog=True); n2, _ = signal.cheb1ord(Wp2, Ws2, ap, as_, analog=True)
assert n1 == 6 and n2 == 4
fs, fp, fst, apH, asH = 200, 25, 50, 3, 38; Th = 1/fs
wpH, wsH = 2*np.pi*fp/fs, 2*np.pi*fst/fs; WpH, WsH = 2/Th*np.tan(wpH/2), 2/Th*np.tan(wsH/2)
NH = int(np.ceil(np.log10((10**(asH/10) - 1)/(10**(apH/10) - 1))/(2*np.log10(WsH/WpH)))); WcH = WpH/(10**(apH/10) - 1)**(1/(2*NH))
bA, aA, _ = butter_analog(NH, WcH); bzH, azH = bilinear(bA, aA, Th)
attH = -20*np.log10(np.abs(freqz(bzH, azH, np.array([wpH, wsH]))))
print("习题 11 型：ωp=%.2fπ ωs=%.2fπ，N=%d，25 Hz 处 %.2f dB，50 Hz 处 %.1f dB" % (wpH/np.pi, wsH/np.pi, NH, *attH))
assert attH[0] <= apH + 1e-6 and attH[1] >= asH
print("IIR_DESIGN_COMPARE_OK")
