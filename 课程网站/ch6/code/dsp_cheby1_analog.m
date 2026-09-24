function [b, a, p, aa, bb] = dsp_cheby1_analog(N, eps, Wc)
%DSP_CHEBY1_ANALOG  N 阶切比雪夫 I 型模拟低通（教材式 (6.1.18)—(6.1.23)）
%   [b, a, p, aa, bb] = dsp_cheby1_analog(N, eps, Wc)
%   eps：通带纹波参数，eps² = 10^(αp/10) − 1；Wc：通带截止频率（纹波区的边界）。
%   β = [√(1+1/ε²) + 1/ε]^(1/N)，a = (β − 1/β)/2，b = (β + 1/β)/2；
%   极点 s_i = −a·Wc·sin[(2i−1)π/(2N)] + j·b·Wc·cos[(2i−1)π/(2N)]，在长轴 b·Wc、短轴 a·Wc 的椭圆上。
%   增益取 Ha(0)=1（N 奇）或 1/√(1+ε²)（N 偶）。
beta = (sqrt(1 + 1/eps^2) + 1/eps)^(1/N);
aa = (beta - 1/beta)/2; bb = (beta + 1/beta)/2;
i = 1:N; th = (2*i - 1)*pi/(2*N);
p = -aa*Wc*sin(th) + 1i*bb*Wc*cos(th);
a = real(poly(p));
K = a(end); if mod(N, 2) == 0, K = K/sqrt(1 + eps^2); end
b = K;
end
