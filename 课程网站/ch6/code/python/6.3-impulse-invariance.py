"""6.3 脉冲响应不变法：例 6.4 的变换、频率响应的周期延拓、例 6.5 的完整设计
课程站 ch6 的 Python 对照版，与 demo_impulse_invariance.m 同一公式。运行：python 本文件（numpy、scipy）。
"""
import numpy as np
from scipy import signal
from dsp_iir import butter_analog, impinvar, freqs, freqz

b, a = np.array([1, 1.]), np.array([1, 5, 6.])
bz, az = impinvar(b, a, 1)
print("例 6.4：bz=%s az=%s" % (np.round(bz, 7), np.round(az, 8)))
assert np.max(np.abs(bz - [1, -0.2208835])) < 1e-6 and np.max(np.abs(az - [1, -0.18512235, 0.00673795])) < 1e-6
n = np.arange(25); ha = -np.exp(-2*n) + 2*np.exp(-3*n); hd = signal.lfilter(bz, az, signal.unit_impulse(25))
assert np.max(np.abs(hd - ha)) < 1e-12
w = np.linspace(0, np.pi, 512)
# 例 6.4 的 h_a(t) 在 t=0 有跳变：周期延拓之和对应 h(0)=h_a(0+)/2，与 residue 做法差常数 0.5
Hsum64 = sum(freqs(b, a, w + 2*np.pi*m) for m in range(-2000, 2001))
print("例 6.4：H(e^jω) − ΣHa(j(ω+2πm)) ≈ %.4f（= h_a(0+)/2）" % np.mean((freqz(bz, az, w) - Hsum64).real))
assert np.max(np.abs(freqz(bz, az, w) - Hsum64 - 0.5)) < 2e-3
b3, a3 = np.array([6.]), np.array([1, 5, 6.])                    # 混叠演示改用 t=0 处连续的 h_a
for T in (1, 0.2):
    bt, at = impinvar(b3, a3, T); Hd = freqz(bt, at, w)
    Hsum = sum(freqs(b3, a3, (w + 2*np.pi*m)/T) for m in range(-2000, 2001))/T
    Hone = freqs(b3, a3, w/T)/T
    print("T=%g：H(e^jω) 与周期延拓之和差 %.1e；与单项 (1/T)Ha(jω/T) 的相对差 %.1f%%" % (T, np.max(np.abs(Hd - Hsum)), 100*np.max(np.abs(Hd - Hone))/np.max(np.abs(Hd))))
    assert np.max(np.abs(Hd - Hsum)) < 2e-3
Wp, Ws, ap, as_ = 0.2*np.pi, 0.3*np.pi, 1, 15; N = 6; Wc = Wp/(10**(ap/10) - 1)**(1/(2*N))
bA, aA, _ = butter_analog(N, Wc); bz5, az5 = impinvar(bA, aA, 1)
H0 = abs(freqz(bz5, az5, np.array([0.])))[0]
att = -20*np.log10(np.abs(freqz(bz5, az5, np.array([Wp, Ws])))/H0)
poles = np.roots(az5); print("例 6.5：Ωc=%.4f，数字极点模 %s，ωp/ωs 处 %.3f/%.2f dB" % (Wc, np.round(np.sort(np.abs(poles))[::2], 4), *att))
assert att[0] <= ap + 0.05 and att[1] >= as_
print("IMPULSE_INVARIANCE_OK")
