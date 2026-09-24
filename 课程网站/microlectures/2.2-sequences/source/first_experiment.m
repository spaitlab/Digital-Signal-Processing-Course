% 修改mode为pi/rad，shift为7/20/21/40。有限数值检查不替代理论证明。
mode='pi';shift=20;n=0:119;
if strcmp(mode,'pi'),omega=.3*pi;else,omega=.3;end
x=cos(omega*n);y=cos(omega*(n+shift));
fprintf('shift=%d max_difference=%.12g\n',shift,max(abs(y-x)));
figure('Visible','off');stem(n(1:41),x(1:41));hold on;stem(n(1:41),y(1:41));xlabel('n');ylabel('amplitude');legend('x[n]','x[n+N]');grid on;
exportgraphics(gcf,fullfile(fileparts(mfilename('fullpath')),'first-matlab.png'));close(gcf);
