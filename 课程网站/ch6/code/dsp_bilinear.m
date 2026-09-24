function [bz, az] = dsp_bilinear(b, a, T)
%DSP_BILINEAR  双线性变换（教材式 (6.3.2)(6.3.4)）：s = (2/T)·(1 − z^{-1})/(1 + z^{-1})
%   [bz, az] = dsp_bilinear(b, a, T)
%   b、a 按 s 的降幂排列；把 s^m 换成 (2/T)^m (1−z^{-1})^m (1+z^{-1})^{N−m}，按 z^{-1} 的升幂整理，
%   输出 bz、az 可直接用于 filter(bz, az, x)。
M = numel(b) - 1; Nn = numel(a) - 1; N = max(M, Nn); c = 2/T;
bz = zeros(1, N + 1); az = zeros(1, N + 1);
for m = 0:M,  bz = bz + b(M + 1 - m)*c^m*conv(polypow([1 -1], m), polypow([1 1], N - m)); end
for m = 0:Nn, az = az + a(Nn + 1 - m)*c^m*conv(polypow([1 -1], m), polypow([1 1], N - m)); end
bz = bz/az(1); az = az/az(1);
end

function p = polypow(q, m)
p = 1; for i = 1:m, p = conv(p, q); end
end
