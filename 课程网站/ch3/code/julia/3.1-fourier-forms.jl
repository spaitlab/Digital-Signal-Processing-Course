# 3.1 四种傅里叶变换：连续周期脉冲的 FS 系数、三点序列的 DTFT、周期序列的 DFS
# 课程站 ch3 的 MWORKS Syslab（Julia）对照版，与 demo_fourier_forms.m / 3.1-fourier-forms.py 同一算法。只用 Julia 标准库。
T = 8.0; width = 3.0                       # 连续周期矩形脉冲：周期 T，宽度 3
c0 = width / T                              # 直流系数 c0 = 宽度/T
ck(k) = k == 0 ? c0 : sin(pi * k * width / T) / (pi * k)   # FS 系数（幅度 1 的脉冲）
println("FS: c0 = ", round(c0, digits = 4), "  c1 = ", round(ck(1), digits = 4), "  c2 = ", round(ck(2), digits = 4))
x = Dict(-1 => 1.0, 0 => 1.0, 1 => 1.0)     # 三点序列 x[-1]=x[0]=x[1]=1
X(w) = sum(v * exp(-im * w * n) for (n, v) in x)          # DTFT：对连续 ω 定义，2π 周期
println("DTFT: X(0) = ", round(real(X(0.0)), digits = 4), "  X(π/2) = ", round(real(X(pi / 2)), digits = 4), "  X(π) = ", round(real(X(pi)), digits = 4), "  X(2π) = ", round(real(X(2pi)), digits = 4))
N = 8; xp = [1.0, 1.0, 0, 0, 0, 0, 0, 1.0]  # 一个周期：索引 0、1、7 处为 1
Xdfs(k) = sum(xp[n + 1] * exp(-2im * pi * k * n / N) for n in 0:N-1)   # DFS
vals = [round(real(Xdfs(k)), digits = 4) for k in (0, 2, 4)]
println("DFS: X~(0), X~(2), X~(4) = ", vals)
@assert abs(c0 - 0.375) < 1e-12 && abs(real(X(0.0)) - 3) < 1e-12 && abs(real(X(pi)) + 1) < 1e-12
@assert vals == [3.0, 1.0, -1.0] && abs(X(2pi) - X(0.0)) < 1e-12
println("FOURIER_FORMS_OK")
