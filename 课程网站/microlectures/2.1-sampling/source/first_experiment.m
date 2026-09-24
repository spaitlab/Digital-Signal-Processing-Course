% 更改fs为20/12/6/10；mode选cos或sin，先预测再运行。
f0=5;fs=6;mode='cos';n=0:fs;t=n/fs;tc=linspace(0,1,1001);
fold=f0-floor(f0/fs+.5)*fs;
if strcmp(mode,'cos'),fn=@cos;else,fn=@sin;end
x=fn(2*pi*f0*t);candidate=fn(2*pi*fold*t);
fprintf('fs=%g samples=%d folded=%g max_difference=%.4g\n',fs,numel(x),fold,max(abs(x-candidate)));
figure('Visible','off');plot(tc,fn(2*pi*f0*tc),tc,fn(2*pi*fold*tc));hold on;stem(t,x);xlabel('t (s)');ylabel('amplitude');legend('original','candidate','samples');grid on;
exportgraphics(gcf,fullfile(fileparts(mfilename('fullpath')),'first-matlab.png'));close(gcf);
