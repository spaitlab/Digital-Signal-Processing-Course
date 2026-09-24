"""6.1 巴特沃思模拟低通：幅度平方函数、极点、分母多项式表、按指标定阶
课程站 ch6 的 Python 对照版，与 demo_butterworth.m 同一公式。运行：python 本文件（numpy、scipy）。
"""
import numpy as np
from dsp_iir import butter_analog, freqs

W = np.linspace(0, 3, 1500)
A2 = np.array([1/(1 + W**(2*N)) for N in range(1, 7)])
assert np.allclose(A2[:, 0], 1) and np.allclose([np.interp(1, W, r) for r in A2], 0.5, atol=1e-6)
b3, a3, p3 = butter_analog(3, 1)
print("N=3 极点角度:", np.sort(np.mod(np.angle(p3, deg=True), 360)))                          # 120 180 240
tab = {4: [1, 2.6131, 3.4142, 2.6131, 1], 5: [1, 3.2361, 5.2361, 5.2361, 3.2361, 1], 6: [1, 3.8637, 7.4641, 9.1416, 7.4641, 3.8637, 1]}
for N, row in tab.items():
    _, a, _ = butter_analog(N, 1); print("N=%d 分母系数 %s  与表 6.1.1 差 %.1e" % (N, np.round(a, 4), np.max(np.abs(a - row))))
    assert np.max(np.abs(a - row)) < 6e-5
Wp, Ws, ap, as_ = 0.2*np.pi, 0.3*np.pi, 1, 15
Nexact = np.log10((10**(as_/10) - 1)/(10**(ap/10) - 1))/(2*np.log10(Ws/Wp)); N = int(np.ceil(Nexact))
Wc = Wp/(10**(ap/10) - 1)**(1/(2*N))
b, a, _ = butter_analog(N, Wc)
att = -20*np.log10(np.abs(freqs(b, a, np.array([Wp, Ws]))))
print("定阶：N=%.4f → %d，Ωc=%.4f；Ωp 处 %.3f dB，Ωs 处 %.2f dB" % (Nexact, N, Wc, *att))
assert abs(Nexact - 5.8858) < 1e-3 and N == 6 and abs(Wc - 0.7032) < 1e-3 and att[0] <= ap + 1e-9 and att[1] >= as_
print("BUTTERWORTH_OK")
