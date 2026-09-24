# 3.4 圆周卷积与线性卷积（MWORKS Syslab，Julia 1.10，TyMath）
# 2026-09-18 在 Syslab 26.6 会话中执行通过，输出与 MATLAB、Python 逐点一致。
using TyMath
x = [1.0, 2.0, 3.0]; h = [2.0, 3.0, 1.0, 2.0]
pad(v, L) = vcat(v, zeros(L - length(v)))
circconv(x, h, L) = real.(ifft(fft(pad(x, L)) .* fft(pad(h, L))))   # L 点圆周卷积
lin = [sum(x[m+1] * (0 <= n-m < length(h) ? h[n-m+1] : 0.0) for m in 0:length(x)-1) for n in 0:length(x)+length(h)-2]
println("linear = ", lin)                              # [2, 7, 13, 13, 7, 6]
println("circ5  = ", round.(circconv(x, h, 5); digits=6))   # [8, 7, 13, 13, 7]
println("circ6  = ", round.(circconv(x, h, 6); digits=6))   # [2, 7, 13, 13, 7, 6]
println("circ8  = ", round.(circconv(x, h, 8); digits=6))   # 尾部两点为补零
