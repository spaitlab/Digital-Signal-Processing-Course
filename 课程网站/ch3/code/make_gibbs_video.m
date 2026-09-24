%% 第3章独立课堂动画；基础 MATLAB，核验先于 VideoWriter
clearvars;
q = linspace(-pi,pi,20001);
truth = sign(sin(q)); truth(abs(sin(q))<1e-12)=0;
counts = [1,5,25,101]; ratios=zeros(size(counts)); errors=zeros(size(counts));

for j=1:numel(counts)
    h = 1:2:(2*counts(j)-1);
    approx = (4/pi)*sum(sin(h(:)*q)./h(:),1);
    peakTime = pi/(2*counts(j));
    peakValue = (4/pi)*sum(sin(h*peakTime)./h);
    ratios(j)=(peakValue-1)/2; % 跳变量为2，不能除以平台值1。
    errors(j)=sqrt(mean((approx-truth).^2));
end
metrics=struct('odd_harmonic_counts',counts,'gibbs_overshoot_fraction_of_jump',ratios,'square_wave_grid_rmse',errors);

codeDir=fileparts(mfilename('fullpath'));mediaDir=fullfile(codeDir,'..','media');if ~exist(mediaDir,'dir'),mkdir(mediaDir);end
checkValues(metrics,codeDir);
moviePath=fullfile(mediaDir,'3.1-gibbs.mp4');
f=figure('Color','w','Position',[30 30 1280 720],'MenuBar','none','ToolBar','none','Visible','off');
cleanup=onCleanup(@() delete(f(isgraphics(f))));
blue=[0 .36 .62];red=[.85 .25 .1];gray=[.65 .65 .65];
for quality=[90 75]
writer=VideoWriter(moviePath,'MPEG-4');writer.FrameRate=30;writer.Quality=quality;open(writer);frames=0;
try

[ax,cap,info]=scene(f,'① 谐波一项项加：有限谐波合成方波','观察整体逼近和跳变旁的尖角，过冲按跳变量 2 归一。');setupAxes(ax,[-1 1],[-1.5 1.5],'t / π（基波周期 2π）','幅度');
plot(ax,q/pi,truth,'k--');curve=plot(ax,q/pi,zeros(size(q)),'Color',blue,'LineWidth',1.5);legend(ax,{'理想方波','部分和'},'Location','southoutside','Orientation','horizontal','AutoUpdate','off');
[frames,lastFrame]=holdFrames(f,writer,frames,30);
for count=1:25
 [approx,ratio,rmse,peakTime,peakValue]=partial(count,q,truth);set(curve,'YData',approx);info.String=sprintf('%d 个奇次谐波；最高次数 %d；过冲 %.2f%%',count,2*count-1,100*ratio);
 if count<=5,repeats=36;else,repeats=9;end
 [frames,lastFrame]=holdFrames(f,writer,frames,repeats);
end
cap.String='25 项：整体误差已小，跳变旁的尖角还在。';[frames,lastFrame]=holdFrames(f,writer,frames,90);
[ax,cap,info]=scene(f,'② 放大跳变处：峰变窄，过冲不趋于零','峰位置按 π/(2N) 精确求出；RMSE 始终在原来的全网格上计算。');setupAxes(ax,[0 .2],[.8 1.25],'t / π','幅度');
plot(ax,q/pi,truth,'k--');curve=plot(ax,q/pi,approx,'Color',blue,'LineWidth',1.5);peak=plot(ax,peakTime/pi,peakValue,'ro','MarkerFaceColor',red);
info.String=sprintf('25 项；过冲 %.2f%%；全网格 RMSE %.4f',100*ratio,rmse);[frames,lastFrame]=holdFrames(f,writer,frames,30);
for count=25:2:101
 [approx,ratio,rmse,peakTime,peakValue]=partial(count,q,truth);set(curve,'YData',approx);set(peak,'XData',peakTime/pi,'YData',peakValue);
 info.String=sprintf('%d 项；过冲 %.2f%%；全网格 RMSE %.4f',count,100*ratio,rmse);[frames,lastFrame]=holdFrames(f,writer,frames,1);
end
cap.String='101 项：RMSE 0.044，过冲 8.95%；峰向跳变靠拢，高度约 1.179。';[frames,lastFrame]=holdFrames(f,writer,frames,291);
[ax,cap,info]=scene(f,'③ 整体逼近改善，过冲仍在','与静态图 3 对照：1、5、25、101 个奇次谐波。');delete(ax);
for j=1:4
 col=mod(j-1,2);row=floor((j-1)/2);a=axes(f,'Position',[.08+.49*col .52-.32*row .37 .18]);setupAxes(a,[-1 1],[-1.5 1.5],'t / π','幅度');
 [approx,ratio,rmse]=partial(counts(j),q,truth);plot(a,q/pi,truth,'k--');plot(a,q/pi,approx,'Color',blue,'LineWidth',1.4);
 title(a,sprintf('%d 项：过冲 %.2f%%；RMSE %.3f',counts(j),100*ratio,rmse),'FontSize',13);
end
cap.String='整体逼近改善，过冲区域变窄；相对跳变量的过冲不趋于零。';[frames,lastFrame]=holdFrames(f,writer,frames,180);assert(frames==1020);

close(writer);catch failure,close(writer);rethrow(failure);end
fileInfo=dir(moviePath);if fileInfo.bytes<8e6,break;end
end
assert(fileInfo.bytes<8e6);checkValues(metrics,codeDir);
imwrite(lastFrame.cdata,fullfile(mediaDir,'3.1-gibbs-poster.png'));
metrics.frames=frames;metrics.frame_rate=30;metrics.duration_s=frames/30;metrics.width=1280;metrics.height=720;metrics.quality=quality;metrics.file_size_bytes=fileInfo.bytes;metrics.all_checks_passed=true;
metrics.matlab_version=version;metrics.generated_at=char(datetime('now','Format','yyyy-MM-dd HH:mm:ss'));
fid=fopen(fullfile(codeDir,'results','verification-video-gibbs.json'),'w','n','UTF-8');assert(fid>=0);fprintf(fid,'%s\n',jsonencode(metrics,PrettyPrint=true));fclose(fid);disp(metrics);

function checkValues(m,codeDir)
assert(all(abs(m.gibbs_overshoot_fraction_of_jump-[.1366 .0912 .0896 .0895])<1e-4));
assert(all(abs(m.square_wave_grid_rmse-[.435 .201 .0895 .0437])<1e-3));assert(all(diff(m.square_wave_grid_rmse)<0));
assert(abs(m.gibbs_overshoot_fraction_of_jump(end)-.08949)<1e-4);
s=jsondecode(fileread(fullfile(codeDir,'verification-fourier-forms.json')));names=fieldnames(m);
for k=1:numel(names),assert(all(abs(m.(names{k})(:)-s.(names{k})(:))<1e-10));end
end
function [approx,ratio,rmse,peakTime,peakValue]=partial(count,q,truth)
h=1:2:(2*count-1);approx=(4/pi)*sum(sin(h(:)*q)./h(:),1);
peakTime=pi/(2*count);peakValue=(4/pi)*sum(sin(h*peakTime)./h);ratio=(peakValue-1)/2;rmse=sqrt(mean((approx-truth).^2));
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
