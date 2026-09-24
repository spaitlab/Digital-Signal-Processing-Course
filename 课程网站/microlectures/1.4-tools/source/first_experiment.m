% 1.4 第一次实验：先预测长度、端点和平方和，再运行。
fs=100; f=2; N=200; A=1; start=0;
n=start+(0:N-1); t=n/fs; x=A*sin(2*pi*f*t);
E=sum(x.^2);
fprintf('N=%d first=%.12g last_t=%.12g sum_squares=%.12g\n',numel(x),x(1),t(end),E);
figure('Visible','off');stem(n,x,'.');xlabel('n');ylabel('x[n]');grid on;
exportgraphics(gcf,fullfile(fileparts(mfilename('fullpath')),'first-matlab.png'));close(gcf);
