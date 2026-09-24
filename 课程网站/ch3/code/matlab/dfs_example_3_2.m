%% 3.2 离散傅里叶级数：N=8，一个周期 [1 1 0 0 0 0 0 1]
% 课程站 3.2 页内 MATLAB 片段的可运行文件版。基础 MATLAB。
N = 8; nn = 0:N-1; kk = (0:N-1)';
onePeriod = double(ismember(nn,[0,1,N-1]));          % [1 1 0 0 0 0 0 1]
directDFS = exp(-1i*2*pi*kk*nn/N)*onePeriod.';       % 按定义直接求和
fftDFS    = fft(onePeriod).';                        % 与 fft 对照
inverse   = exp(1i*2*pi*nn'*kk'/N)*directDFS/N;      % 逆变换，1/N 在这里
fprintf('X~(k) = '); fprintf('%.4f ', real(directDFS)); fprintf('\n');
fprintf('与 fft 的最大差 = %.2e\n', max(abs(directDFS - fftDFS)));
fprintf('逆变换重构误差 = %.2e\n', max(abs(inverse - onePeriod.')));
fprintf('X~(0)=%g, X~(4)=%g；解析式 1+2cos(2*pi*k/8) 在 k=4 处 = %g\n', ...
    real(directDFS(1)), real(directDFS(5)), 1+2*cos(2*pi*4/8));
assert(max(abs(directDFS - fftDFS)) < 1e-12 && max(abs(inverse - onePeriod.')) < 1e-12);
disp('DFS_3_2_PASSED');
