function [b, a, p] = dsp_butter_analog(N, Wc)
%DSP_BUTTER_ANALOG  N 阶巴特沃思模拟低通（教材式 (6.1.6)(6.1.7)）
%   [b, a, p] = dsp_butter_analog(N, Wc)
%   极点 s_k = Wc·exp(jπ[1/2 + (2k−1)/(2N)])，k=1..N，都在左半平面、半径 Wc 的圆上；
%   Ha(s) = Wc^N / ∏(s − s_k)，使 Ha(0)=1。b、a 按 s 的降幂排列（与 polyval、roots 一致）。
k = 1:N;
p = Wc*exp(1i*pi*(0.5 + (2*k - 1)/(2*N)));
a = real(poly(p));
b = Wc^N;
end
