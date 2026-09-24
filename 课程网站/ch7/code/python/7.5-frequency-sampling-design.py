"""7.5 频率采样法设计：例 7.17（N=33）、例 7.19（一个过渡采样）、例 7.20（N=65，两个过渡采样）；内插公式核验
课程站 ch7 的 Python 对照版，与 demo_frequency_sampling_design.m 同一公式。运行：python 本文件（numpy）。
"""
import numpy as np

def fs_design_type1(N, wc, trans=()):
    k = np.arange(N); kc = int(np.floor(N*wc/(2*np.pi))); mag = (k <= kc).astype(float)
    for i, t in enumerate(trans): mag[kc + i + 1] = t
    mag = np.maximum(mag, np.r_[0, mag[1:][::-1]])                       # |H(N−k)|=|H(k)|
    L = (N-1)//2; theta = np.where(k <= L, -np.pi*k*(N-1)/N, np.pi*(N-k)*(N-1)/N)   # 式 (7.3.20)
    Hk = mag*np.exp(1j*theta); return np.fft.ifft(Hk).real, Hk, mag

def resp(h, w): return np.abs(np.polyval(h[::-1], np.exp(-1j*w)))
def stop_att(H, w, N, k_last): ws = 2*np.pi*(k_last + 1)/N; return -20*np.log10(H[w >= ws].max())

w = np.linspace(0, np.pi, 8192)
hA, HkA, magA = fs_design_type1(33, 0.5*np.pi); HA = resp(hA, w)
wk = 2*np.pi*np.arange(33)/33; err_samp = np.max(np.abs(resp(hA, wk) - magA)); sym = np.max(np.abs(hA - hA[::-1]))
attA = stop_att(HA, w, 33, 8)
hB, *_ = fs_design_type1(33, 0.5*np.pi, (0.5,)); attB = stop_att(resp(hB, w), w, 33, 9)
hC, *_ = fs_design_type1(65, 0.5*np.pi, (0.5886, 0.1065)); attC = stop_att(resp(hC, w), w, 65, 18)
z = np.exp(1j*w[1:]); Hint = sum(HkA[k]/(1 - np.exp(2j*np.pi*k/33)/z) for k in range(33))*(1 - z**-33)/33      # ω=0 处 0/0，跳过
err_interp = np.max(np.abs(Hint - np.polyval(hA[::-1], np.exp(-1j*w[1:]))))
T1s = np.arange(0.20, 0.601, 0.005); scan = [stop_att(resp(fs_design_type1(33, 0.5*np.pi, (t,))[0], w), w, 33, 9) for t in T1s]
T1opt, attBopt = T1s[int(np.argmax(scan))], max(scan); print("一个过渡采样扫描最优：T1=%.3f，阻带 %.1f dB" % (T1opt, attBopt))
print("例 7.17：穿过采样点差 %.1e，h 对称差 %.1e，阻带 %.1f dB；例 7.19 阻带 %.1f dB；例 7.20 阻带 %.1f dB；内插公式差 %.1e"
      % (err_samp, sym, attA, attB, attC, err_interp))
assert err_samp < 1e-10 and sym < 1e-12 and err_interp < 1e-9 and 15 < attA < 25 and attB > attA + 10 and attBopt > attB + 5 and attC > attBopt + 10
print("FREQUENCY_SAMPLING_DESIGN_OK")
