%% 第3章独立课堂动画；基础 MATLAB，核验先于 VideoWriter
clearvars;
x = [1 2 3]; h = [2 3 1 2];
linearConv = conv(x, h);                 % 长度 3+4-1 = 6
circ5 = circular_convolution(x, h, 5);   % 长度 5：第6项折回到 n=0
circ6 = circular_convolution(x, h, 6);   % 长度 6：等于线性卷积
circ8 = circular_convolution(x, h, 8);   % 长度 8：尾部两点为补零


checks=struct('linear_by_hand',max(abs(linearConv-[2 7 13 13 7 6])), ...
'circular_5_folded',max(abs(circ5-[8 7 13 13 7])), ...
'linear_via_fft_6',max(abs(circ6-linearConv)), ...
'linear_via_fft_8',max(abs(circ8-[linearConv 0 0])));
metrics=struct('linear',linearConv,'circular_5',circ5,'circular_6',circ6,'circular_8',circ8,'checks_max_abs_error',checks);

codeDir=fileparts(mfilename('fullpath'));mediaDir=fullfile(codeDir,'..','media');if ~exist(mediaDir,'dir'),mkdir(mediaDir);end
checkValues(metrics,codeDir);
moviePath=fullfile(mediaDir,'3.4-circular-convolution.mp4');
f=figure('Color','w','Position',[30 30 1280 720],'MenuBar','none','ToolBar','none','Visible','off');
cleanup=onCleanup(@() delete(f(isgraphics(f))));
blue=[0 .36 .62];red=[.85 .25 .1];gray=[.65 .65 .65];
for quality=[90 75]
writer=VideoWriter(moviePath,'MPEG-4');writer.FrameRate=30;writer.Quality=quality;open(writer);frames=0;
try

[ax,cap,info]=scene(f,'① 线性卷积怎么算','翻转 h，再滑动；相同位置相乘并求和。');
ax.Position=[.09 .49 .86 .23];setupAxes(ax,[-3.5 6.5],[0 4],'样本位置 m','输入幅度');
p=stem(ax,0:2,x,'filled','Color',blue);t=stem(ax,-1-(0:3),h,'Color',red,'LineWidth',1.4);
legend(ax,[p t],{'x[m]','翻转平移模板 h[n-m]'},'Location','northwest','Orientation','horizontal','AutoUpdate','off');
a2=axes(f,'Position',[.09 .17 .86 .21]);setupAxes(a2,[-.5 7.5],[0 15],'输出索引 n','y[n]');y=stem(a2,NaN,NaN,'filled','Color',blue);
[frames,lastFrame]=holdFrames(f,writer,frames,30);
for n=0:5
 for step=1:15
  set(t,'XData',(n-1+step/15)-(0:3));[frames,lastFrame]=holdFrames(f,writer,frames,1);
 end
 terms={};total=0;
 for m=0:2
  j=n-m;if j>=0 && j<4,terms{end+1}=sprintf('%g×%g',x(m+1),h(j+1));total=total+x(m+1)*h(j+1);end
 end
 assert(total==linearConv(n+1));info.String=sprintf('n=%d：%s = %g',n,strjoin(terms,' + '),total);
 set(y,'XData',0:n,'YData',linearConv(1:n+1));[frames,lastFrame]=holdFrames(f,writer,frames,30);
end
cap.String='线性卷积 [2 7 13 13 7 6]；长度 3 + 4 − 1 = 6。';[frames,lastFrame]=holdFrames(f,writer,frames,60);
fprintf('圆周卷积：段1 %d帧\n',frames);
[ax,cap,info]=scene(f,'② L = 5：第 6 项折回','输出索引按 5 取模：n = 5 的样本叠加到 n = 0。');setupAxes(ax,[-.5 7.5],[0 16],'n','幅度');
y=stem(ax,0:5,linearConv,'filled','Color',blue);info.String='先看线性卷积的 6 个点';
[frames,lastFrame]=holdFrames(f,writer,frames,90);
a=linspace(0,1,46);px=5*(1-a);py=6+2*a+6*sin(pi*a);plot(ax,px,py,'--','Color',red,'LineWidth',1.4);
set(y,'XData',0:4,'YData',linearConv(1:5));moving=plot(ax,5,6,'o','Color',red,'MarkerFaceColor',red,'MarkerSize',9);
info.String='红点携带的数值始终是 6；弧线仅示意折回路径';
for j=2:46,set(moving,'XData',px(j),'YData',py(j));[frames,lastFrame]=holdFrames(f,writer,frames,1);end
moving.Visible='off';set(y,'YData',circ5);info.String='落点：n=0，2 + 6 = 8';cap.String='5 点圆周卷积 [8 7 13 13 7]；L < 6，越界样本绕回叠加。';
[frames,lastFrame]=holdFrames(f,writer,frames,225);
[ax,cap,info]=scene(f,'③ L = 6 与 L = 8','长度足够：线性卷积的每个样本都有自己的位置。');setupAxes(ax,[-.5 7.5],[0 15],'n','幅度');
ref=stem(ax,0:5,linearConv,'Color',gray,'MarkerSize',11,'LineWidth',1.6);y=stem(ax,0:5,circ6,'filled','Color',blue,'MarkerSize',4);
legend(ax,[ref y],{'线性卷积（空心圈）','6 点圆周卷积'},'Location','southoutside','Orientation','horizontal','AutoUpdate','off');
info.String='L = 6：全部重合';[frames,lastFrame]=holdFrames(f,writer,frames,150);
set(y,'XData',0:7,'YData',circ8);legend(ax,[ref y],{'线性卷积（空心圈）','8 点圆周卷积'},'Location','southoutside','Orientation','horizontal','AutoUpdate','off');info.String='L = 8：尾部两点为 0';cap.String='L ≥ N_x + N_h − 1 = 6 时，圆周卷积等于补零后的线性卷积。';
[frames,lastFrame]=holdFrames(f,writer,frames,150);
[ax,cap,info]=scene(f,'④ 用 FFT 做卷积前，先补足零','与本页静态图右下格对照：三组结果的有效样本一致。');setupAxes(ax,[-.5 7.5],[0 15],'n','幅度');
stem(ax,0:5,linearConv,'Color',gray,'MarkerSize',10,'LineWidth',1.5);stem(ax,0:5,circ6,'filled','Color',blue,'MarkerSize',4);stem(ax,0:7,circ8,'x','Color',[.47 .67 .19],'MarkerSize',9);
legend(ax,{'线性卷积','6 点圆周卷积','8 点圆周卷积（尾部补零）'},'Location','southoutside','Orientation','horizontal','AutoUpdate','off');
cap.String='用 fft 做卷积前先补零到 L ≥ 6。';[frames,lastFrame]=holdFrames(f,writer,frames,180);assert(frames==1200);

close(writer);catch failure,close(writer);rethrow(failure);end
fileInfo=dir(moviePath);if fileInfo.bytes<8e6,break;end
end
assert(fileInfo.bytes<8e6);checkValues(metrics,codeDir);
imwrite(lastFrame.cdata,fullfile(mediaDir,'3.4-circular-convolution-poster.png'));
metrics.frames=frames;metrics.frame_rate=30;metrics.duration_s=frames/30;metrics.width=1280;metrics.height=720;metrics.quality=quality;metrics.file_size_bytes=fileInfo.bytes;metrics.all_checks_passed=true;
metrics.matlab_version=version;metrics.generated_at=char(datetime('now','Format','yyyy-MM-dd HH:mm:ss'));
fid=fopen(fullfile(codeDir,'results','verification-video-circular-convolution.json'),'w','n','UTF-8');assert(fid>=0);fprintf(fid,'%s\n',jsonencode(metrics,PrettyPrint=true));fclose(fid);disp(metrics);

function checkValues(m,codeDir)
assert(isequal(m.linear,[2 7 13 13 7 6]));assert(isequal(m.circular_5,[8 7 13 13 7]));
assert(max(abs(m.circular_6-m.linear))<1e-12);assert(max(abs(m.circular_8-[m.linear 0 0]))<1e-12);
s=jsondecode(fileread(fullfile(codeDir,'verification-dft.json')));names=fieldnames(m.checks_max_abs_error);
for k=1:numel(names),assert(abs(m.checks_max_abs_error.(names{k})-s.checks_max_abs_error.(names{k}))<1e-10);end
end
function y = circular_convolution(x, h, L)
% L 点圆周卷积；要求 L 不小于两输入长度，避免 fft(x,L) 的隐式截断。
assert(L >= max(numel(x), numel(h)), '本函数要求 L 不小于两输入长度');
y = real(ifft(fft(x, L) .* fft(h, L)));
end


function [ax,cap,info]=scene(f,titleText,note)
clf(f);ax=axes(f,'Position',[.09 .21 .86 .52]);hold(ax,'on');grid(ax,'on');ax.FontSize=15;ax.Toolbar.Visible='off';
annotation(f,'textbox',[.07 .89 .92 .065],'String',titleText,'FontSize',24,'FontWeight','bold','EdgeColor','none','Interpreter','none');
annotation(f,'textbox',[.07 .81 .92 .06],'String',note,'FontSize',16,'EdgeColor','none','Interpreter','none');
cap=annotation(f,'textbox',[.07 .02 .92 .075],'String','','FontSize',17,'Color',[0 .36 .62],'EdgeColor','none','Interpreter','none');
info=annotation(f,'textbox',[.07 .745 .91 .05],'String','','FontSize',16,'HorizontalAlignment','right','EdgeColor','none','Interpreter','none');
end
function setupAxes(ax,xr,yr,xlab,ylab)
xlim(ax,xr);ylim(ax,yr);xlabel(ax,xlab);ylabel(ax,ylab);ax.FontSize=14;ax.Toolbar.Visible='off';grid(ax,'on');hold(ax,'on');
end
function [count,frame]=holdFrames(fig,writer,count,repeats)
drawnow;
frame=getframe(fig);
% Windows 高 DPI 会让 getframe 返回设备像素；基础索引采样统一输出尺寸。
[h,w,~]=size(frame.cdata);
if h~=720 || w~=1280
    rows=min(h,max(1,round(((1:720)-.5)*h/720+.5)));
    cols=min(w,max(1,round(((1:1280)-.5)*w/1280+.5)));
    frame.cdata=frame.cdata(rows,cols,:);
end
assert(size(frame.cdata,2)==1280 && size(frame.cdata,1)==720,'画布像素必须为 1280×720');
for repeat=1:repeats, writeVideo(writer,frame); end
count=count+repeats;
end
