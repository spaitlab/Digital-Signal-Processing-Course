"""7.4 典型窗与窗函数法设计：六种窗的旁瓣与阻带衰减（表 7.2.2）、例 7.13—7.16 四种滤波器
课程站 ch7 的 Python 对照版，与 demo_windows_design.m 同一公式（scipy.signal.windows 只作对照）。运行：python 本文件（numpy、scipy）。
"""
import numpy as np
from scipy import signal
from scipy.special import i0

def win(kind, N, beta=7.865):
    n = np.arange(N); M = N - 1
    return {'rect': np.ones(N), 'triang': 1 - np.abs(2*n - M)/M, 'hann': 0.5 - 0.5*np.cos(2*np.pi*n/M),
            'hamming': 0.54 - 0.46*np.cos(2*np.pi*n/M), 'blackman': 0.42 - 0.5*np.cos(2*np.pi*n/M) + 0.08*np.cos(4*np.pi*n/M),
            'kaiser': i0(beta*np.sqrt(1 - (2*n/M - 1)**2))/i0(beta)}[kind]

def ideal_lp(wc, alpha, n):
    n = np.asarray(n, float); h = np.full(n.shape, wc/np.pi); i = np.abs(n - alpha) > 1e-12
    h[i] = np.sin(wc*(n[i] - alpha))/(np.pi*(n[i] - alpha)); return h

def local_minima(x): return np.flatnonzero((x[1:-1] < x[:-2]) & (x[1:-1] <= x[2:])) + 1
def resp(h, w): return np.abs(np.polyval(h[::-1], np.exp(-1j*w)))

w = np.linspace(0, np.pi, 16384); N = 51; wc = 0.5*np.pi; hd = ideal_lp(wc, 25, np.arange(N))
table = {'rect': 21, 'triang': 25, 'hann': 44, 'hamming': 53, 'blackman': 74, 'kaiser': 80}
for kind, ref in table.items():
    H = resp(hd*win(kind, N), w); H /= H.max(); i1 = local_minima(H); i1 = i1[w[i1] > wc][0]
    att = -20*np.log10(H[w > w[i1]].max()); print("%-9s 低通阻带衰减 %.1f dB（表 7.2.2：%d）" % (kind, att, ref)); assert abs(att - ref) < 4
assert np.max(np.abs(win('hamming', N) - signal.windows.hamming(N))) < 1e-12 and np.max(np.abs(win('kaiser', N) - signal.windows.kaiser(N, 7.865))) < 1e-12

def choose_N(Bt, factor):
    N = int(np.ceil(factor*np.pi/Bt)) + 1; return N + (N % 2 == 0)
def att_lp(h, ws): return -20*np.log10(resp(h, w)[w >= ws].max())
# 例 7.13 低通：ωp=0.3π ωs=0.5π As=40 → 汉宁
N13 = choose_N(0.2*np.pi, 6.6); h13 = ideal_lp(0.4*np.pi, (N13-1)/2, np.arange(N13))*win('hann', N13)
# 例 7.14 高通：ωp=0.4π ωs=0.2π As=50 → 汉明；hd = δ(n−α) − 低通
N14 = choose_N(0.2*np.pi, 6.6); n = np.arange(N14); a = (N14-1)/2; hd14 = -ideal_lp(0.3*np.pi, a, n); hd14[n == a] = 1 - 0.3; h14 = hd14*win('hamming', N14)
# 例 7.15 带通：fs=20 kHz，通 3—5 k，阻 ≤2 k、≥6 k，As=55 → 布莱克曼
fs = 20000; wp1, wp2, ws1, ws2 = [2*np.pi*f/fs for f in (3000, 5000, 2000, 6000)]
N15 = choose_N(min(wp1 - ws1, ws2 - wp2), 11); n = np.arange(N15); a = (N15-1)/2
h15 = (ideal_lp((wp2 + ws2)/2, a, n) - ideal_lp((wp1 + ws1)/2, a, n))*win('blackman', N15)
# 例 7.16 带阻：fs=250，通 ≤15、≥80，阻 40—60，As=50 → 汉明
fs = 250; vp1, vp2, vs1, vs2 = [2*np.pi*f/fs for f in (15, 80, 40, 60)]
N16 = choose_N(min(vs1 - vp1, vp2 - vs2), 6.6); n = np.arange(N16); a = (N16-1)/2; w1, w2 = (vp1 + vs1)/2, (vp2 + vs2)/2
hd16 = -(ideal_lp(w2, a, n) - ideal_lp(w1, a, n)); hd16[n == a] = 1 - (w2 - w1)/np.pi; h16 = hd16*win('hamming', N16)
H15 = resp(h15, w); H16 = resp(h16, w)
att15 = -20*np.log10(H15[(w <= ws1) | (w >= ws2)].max()); att16 = -20*np.log10(H16[(w >= vs1) & (w <= vs2)].max())
print("例 7.13 N=%d ωs 处 %.1f dB；例 7.14 N=%d ωs 处 %.1f dB；例 7.15 N=%d 阻带 %.1f dB；例 7.16 N=%d 阻带 %.1f dB"
      % (N13, att_lp(h13, 0.5*np.pi), N14, -20*np.log10(resp(h14, w)[w <= 0.2*np.pi].max()), N15, att15, N16, att16))
assert (N13, N14, N15, N16) == (35, 35, 111, 43) and att_lp(h13, 0.5*np.pi) >= 40 and att15 >= 55 and att16 < 50   # 例 7.16 按教材参数不达标
Nf, af = N16, att16
while af < 50:
    Nf += 2; n = np.arange(Nf); a = (Nf-1)/2; hd = -(ideal_lp(w2, a, n) - ideal_lp(w1, a, n)); hd[n == a] = 1 - (w2 - w1)/np.pi
    af = -20*np.log10(resp(hd*win('hamming', Nf), w)[(w >= vs1) & (w <= vs2)].max())
print("例 7.16 汉明窗要达到 50 dB 需 N=%d（实测 %.1f dB）" % (Nf, af))
print("WINDOWS_DESIGN_OK")
