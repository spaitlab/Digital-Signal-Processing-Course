%% 3.3 离散傅里叶变换：例 3.2 六点序列 n/6 的三种算法
% 课程站 3.3 页内 MATLAB 片段的可运行文件版。基础 MATLAB。
N = 6; n = 0:N-1; k = n';
x = n/6;
Xdef  = exp(-1i*2*pi*k*n/N) * x.';          % 定义式：N×N 复指数矩阵
Xfft  = fft(x).';                            % 与 fft 对照
Xform = [sum(x), -1./(1-exp(-1i*2*pi*(1:N-1)/N))].';   % 等差序列闭式
xback = exp(1i*2*pi*n'*k'/N) * Xdef / N;     % 往返重构 idft(dft(x))
disp('X(k) ='); disp(round(Xdef.', 3));
fprintf('定义式 vs fft 最大差 = %.2e；定义式 vs 闭式 = %.2e；往返重构误差 = %.2e\n', ...
    max(abs(Xdef-Xfft)), max(abs(Xdef-Xform)), max(abs(xback - x.')));
fprintf('4 点 DFT of [1 0 -1 0] = '); fprintf('%g ', real(fft([1 0 -1 0]))); fprintf('\n');
assert(max(abs(Xdef-Xfft)) < 1e-12 && max(abs(Xdef-Xform)) < 1e-12 && max(abs(xback - x.')) < 1e-12);
disp('DFT_3_3_PASSED');
