"""3.1 四种傅里叶变换：同一类脉冲的四种表示
课程站 ch3 页内 Python 片段的可运行文件版。2026-09-18 本机验证通过。
运行：python 本文件；需要 numpy、matplotlib（3.1）、scipy（3.7）。
"""
import numpy as np, matplotlib.pyplot as plt
width, T, N = 3, 8, 8
t = np.linspace(-16, 16, 6401); Om = np.linspace(-4*np.pi, 4*np.pi, 3201)
w = Om.copy(); n = np.arange(-16, 17)
m = np.arange(-int(4*np.pi/(2*np.pi/T)), int(4*np.pi/(2*np.pi/T))+1); k = np.arange(-2*N, 2*N+1)
sinc_u = lambda z: np.sinc(z/np.pi)            # np.sinc 是 sin(pi z)/(pi z)，换算成 sin(z)/z
p = (np.abs(t) < width/2).astype(float)
P = width*sinc_u(Om*width/2)
c = (width/T)*sinc_u(m*(2*np.pi/T)*width/2)
x = (np.abs(n) <= 1).astype(float); X = 1+2*np.cos(w)
Xdfs = 1+2*np.cos(2*np.pi*k/N)
print("P(0)=%.3f  c0=%.4f  X(pi)=%.3f" % (P[np.argmin(abs(Om))], c[m == 0][0], 1+2*np.cos(np.pi)))
fig, ax = plt.subplots(4, 2, figsize=(12, 10))
ax[0,0].plot(t, p); ax[0,1].plot(Om/np.pi, np.abs(P))
ax[1,0].plot(t, (np.abs(np.mod(t+T/2, T)-T/2) < width/2).astype(float)); ax[1,1].stem(m*(2*np.pi/T)/np.pi, np.abs(c))
ax[2,0].stem(n, x); ax[2,1].plot(w/np.pi, np.abs(X))
ax[3,0].stem(n, np.isin(np.mod(n, N), [0, 1, N-1]).astype(float)); ax[3,1].stem(2*k/N, np.abs(Xdfs))
for a, ttl in zip(ax.flat, ["CTFT: p(t)", "|P(jΩ)|", "FS: p_T(t), T=8", "|c_m|", "DTFT: x[n]", "|X(e^jω)|", "DFS: N=8", "|X_DFS[k]|"]):
    a.set_title(ttl); a.grid(True)
plt.tight_layout(); plt.show()
