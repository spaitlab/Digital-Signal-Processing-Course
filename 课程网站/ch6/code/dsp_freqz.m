function H = dsp_freqz(bz, az, w)
%DSP_FREQZ  数字系统的频率响应 H(e^{jω})，bz、az 按 z^{-1} 的升幂排列（filter 的约定）
z = exp(-1i*w);
H = polyval(fliplr(bz), z) ./ polyval(fliplr(az), z);
end
