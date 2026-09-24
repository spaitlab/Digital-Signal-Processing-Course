function H = dsp_freqs(b, a, W)
%DSP_FREQS  模拟系统的频率响应 Ha(jΩ)，b、a 按 s 的降幂排列
H = polyval(b, 1i*W) ./ polyval(a, 1i*W);
end
