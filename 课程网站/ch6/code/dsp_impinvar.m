function [bz, az, r, p] = dsp_impinvar(b, a, T, scaleT)
%DSP_IMPINVAR  脉冲响应不变法（教材式 (6.2.5)(6.2.6)）
%   [bz, az, r, p] = dsp_impinvar(b, a, T, scaleT)
%   Ha(s) = Σ A_i/(s − s_i)  →  H(z) = Σ A_i/(1 − e^{s_i T} z^{-1})，再通分成 bz(z^{-1})/az(z^{-1})。
%   要求分子阶数低于分母且极点互异。scaleT=true 时按 h(n)=T·ha(nT) 取（教材式 (6.2.8)）。
if nargin < 4, scaleT = false; end
[r, p, k] = residue(b, a);
assert(isempty(k) || all(abs(k) < 1e-12), '脉冲响应不变法要求分子阶数低于分母');
n = numel(p);
az = 1; for j = 1:n, az = conv(az, [1 -exp(p(j)*T)]); end
bz = zeros(1, n);
for i = 1:n
    q = r(i);
    for j = 1:n, if j ~= i, q = conv(q, [1 -exp(p(j)*T)]); end, end
    bz = bz + [q, zeros(1, n - numel(q))];
end
bz = real(bz); az = real(az);
if scaleT, bz = T*bz; end
end
