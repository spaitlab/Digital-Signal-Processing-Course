"""6.2 切比雪夫 I 型模拟低通：多项式、等纹波、极点在椭圆上（例 6.8 数值）、与巴特沃思比阶数
课程站 ch6 的 Python 对照版，与 demo_chebyshev.m 同一公式。运行：python 本文件（numpy、scipy）。
"""
import numpy as np
from dsp_iir import butter_analog, cheby1_analog, freqs

def C(N, x):
    x = np.asarray(x, float); return np.where(x <= 1, np.cos(N*np.arccos(np.minimum(x, 1))), np.cosh(N*np.arccosh(np.maximum(x, 1))))
x = np.linspace(0, 3, 600); Crec = [np.ones_like(x), x]
for N in range(2, 5): Crec.append(2*x*Crec[-1] - Crec[-2])
assert max(np.max(np.abs(Crec[N] - C(N, x))) for N in range(5)) < 1e-9
ap, as_ = 1, 15; eps = np.sqrt(10**(ap/10) - 1); print("ε(1 dB)=%.5f" % eps); assert abs(eps - 0.50885) < 1e-4
A2at0 = [1/(1 + eps**2*C(N, 0)**2) for N in range(1, 7)]
print("Ω=0 处 |Ha|²，N=1..6:", np.round(A2at0, 4), "（奇 1，偶 1/(1+ε²)）")
Wc8 = 2*np.tan(0.1*np.pi)
b4, a4, p4, a_, b_ = cheby1_analog(4, eps, Wc8)
pBook = np.array([-0.0906699+0.6389997j, -0.0906699-0.6389997j, -0.2188969+0.2646819j, -0.2188969-0.2646819j])
errP = max(np.min(np.abs(p4 - q)) for q in pBook)
print("例 6.8：a=%.7f b=%.7f，极点 %s，与教材差 %.1e，增益 K=%.5f" % (a_, b_, np.round(p4, 4), errP, b4[0]))
assert abs(a_ - 0.3646235) < 1e-4 and abs(b_ - 1.0644015) < 1e-4 and errP < 1e-4 and abs(b4[0] - 0.04381) < 2e-5
Wp, Ws = 0.2*np.pi, 0.3*np.pi
Nc = np.arccosh(np.sqrt(10**(as_/10) - 1)/eps)/np.arccosh(Ws/Wp)
Nb = np.log10((10**(as_/10) - 1)/(10**(ap/10) - 1))/(2*np.log10(Ws/Wp))
bc, ac, *_ = cheby1_analog(int(np.ceil(Nc)), eps, Wp)
attC = -20*np.log10(np.abs(freqs(bc, ac, np.array([Wp, Ws]))))
print("同一指标：切比雪夫 N=%.3f→%d，巴特沃思 N=%.3f→%d；切比雪夫 4 阶在 Ωp/Ωs 处 %.3f/%.2f dB" % (Nc, np.ceil(Nc), Nb, np.ceil(Nb), *attC))
assert np.ceil(Nc) == 4 and np.ceil(Nb) == 6 and attC[0] <= ap + 1e-9 and attC[1] >= as_
print("CHEBYSHEV_OK")
