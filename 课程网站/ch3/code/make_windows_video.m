%% 第3章独立课堂动画；基础 MATLAB，核验先于 VideoWriter
clearvars;
db = @(v) 20*log10(max(abs(v), 1e-12));
fs = 8000; M = 512; Npad = 4096; f0 = 103;          % 103 Hz 不在 fs/M=15.625 Hz 网格上
n = 0:M-1; xTone = cos(2*pi*f0*n/fs);
Nw = 51; nw = (0:Nw-1)';
winNames = {'矩形', 'Hann', 'Hamming', 'Blackman'};
winData = {ones(Nw,1), 0.5-0.5*cos(2*pi*nw/(Nw-1)), 0.54-0.46*cos(2*pi*nw/(Nw-1)), ...
    0.42-0.5*cos(2*pi*nw/(Nw-1))+0.08*cos(4*pi*nw/(Nw-1))};
Nfw = 8192; binAxis = (0:Nfw-1)/Nfw*Nw;                  % 单位：周期/窗长（=DFT 频点间隔）
sidelobe = zeros(1,4); mainlobeNull = zeros(1,4);
strongCyc = 7.3; weakCyc = 20; weakAmp = 0.005;          % 弱音比主音低 46 dB
two = cos(2*pi*strongCyc*n/M) + weakAmp*cos(2*pi*weakCyc*n/M);
hannP = 0.5-0.5*cos(2*pi*(0:M-1)/M);                     % 周期型 Hann，配合 DFT 使用
specRect = abs(fft(two))/M*2; specHann = abs(fft(two.*hannP))/sum(hannP)*2;

for j=1:4
 W=abs(fft(winData{j},Nfw));W=W/W(1);half=W(1:Nfw/2);firstNull=find(diff(half)>0,1);
 mainlobeNull(j)=binAxis(firstNull);sidelobe(j)=db(max(half(firstNull:end)));
end
rectContrast = db(specRect(weakCyc+1)) - db(specRect(weakCyc-2));
hannContrast = db(specHann(weakCyc+1)) - db(specHann(weakCyc-2));
metrics=struct('window_peak_sidelobe_db',sidelobe,'window_first_null_bins',mainlobeNull, ...
'weak_tone_contrast_db_rect',rectContrast,'weak_tone_contrast_db_hann',hannContrast, ...
'weak_tone_amplitude_hann',specHann(weakCyc+1),'contrast_bins',[20 17]);

codeDir=fileparts(mfilename('fullpath'));mediaDir=fullfile(codeDir,'..','media');if ~exist(mediaDir,'dir'),mkdir(mediaDir);end
checkValues(metrics,codeDir);
moviePath=fullfile(mediaDir,'3.7-windows.mp4');
f=figure('Color','w','Position',[30 30 1280 720],'MenuBar','none','ToolBar','none','Visible','off');
cleanup=onCleanup(@() delete(f(isgraphics(f))));
blue=[0 .36 .62];red=[.85 .25 .1];gray=[.65 .65 .65];
for quality=[90 75]
writer=VideoWriter(moviePath,'MPEG-4');writer.FrameRate=30;writer.Quality=quality;open(writer);frames=0;
try

[ax,cap,info]=scene(f,'① 四种窗的形状与频谱','51 点对称窗：形状连续变形，右图同步重算频谱。');
ax.Position=[.08 .22 .38 .49];setupAxes(ax,[0 50],[0 1.1],'n','w[n]');shape=plot(ax,nw,winData{1},'Color',blue,'LineWidth',2);
a2=axes(f,'Position',[.56 .22 .38 .49]);setupAxes(a2,[0 12],[-100 5],'频率偏移（DFT 频点）','相对幅值 (dB)');
W=abs(fft(winData{1},Nfw));W=W/W(1);spectrum=plot(a2,binAxis,db(W),'Color',blue,'LineWidth',1.5);
info.String=sprintf('矩形：首零点 %.2f 频点；最高旁瓣 %.2f dB',mainlobeNull(1),sidelobe(1));
[frames,lastFrame]=holdFrames(f,writer,frames,75);
for j=2:4
 for a=linspace(0,1,45)
  wMorph=(1-a)*winData{j-1}+a*winData{j};W=abs(fft(wMorph,Nfw));W=W/W(1);
  half=W(1:Nfw/2);firstNull=find(diff(half)>0,1);currentNull=binAxis(firstNull);currentSide=db(max(half(firstNull:end)));
  set(shape,'YData',wMorph);set(spectrum,'YData',db(W));info.String=sprintf('%s → %s（%.0f%%）：首谷 %.2f 频点；最高旁瓣 %.2f dB',winNames{j-1},winNames{j},a*100,currentNull,currentSide);
  [frames,lastFrame]=holdFrames(f,writer,frames,1);
 end
 info.String=sprintf('%s：首零点 %.2f 频点；最高旁瓣 %.2f dB',winNames{j},currentNull,currentSide);
 [frames,lastFrame]=holdFrames(f,writer,frames,45);
end
cap.String='主瓣越窄，旁瓣越高：矩形 −13.3 dB，Blackman −58.1 dB。';[frames,lastFrame]=holdFrames(f,writer,frames,75);
[ax,cap,info]=scene(f,'② 弱音显现：矩形逐渐变为 Hann','512 点记录：7.3 周期主音 + 0.005 × 20 周期弱音；除以窗和校正幅值。');setupAxes(ax,[0 40],[-90 5],'频率索引 k','单边幅值 (dB)');
spectrum=stem(ax,0:M-1,db(specRect),'filled','Color',blue,'MarkerSize',4,'BaseValue',-90);xline(ax,weakCyc,'r--','k=20 弱音');
info.String=sprintf('矩形：对比度 %.2f dB（k=20 减 k=17）',rectContrast);[frames,lastFrame]=holdFrames(f,writer,frames,30);
for a=linspace(0,1,240)
 wMorph=(1-a)*ones(1,M)+a*hannP;spec=abs(fft(two.*wMorph))/sum(wMorph)*2;contrast=db(spec(weakCyc+1))-db(spec(weakCyc-2));
 set(spectrum,'YData',db(spec));info.String=sprintf('向周期型 Hann 变形 %.0f%%；对比度 %.2f dB（k=20 减 k=17）',100*a,contrast);
 [frames,lastFrame]=holdFrames(f,writer,frames,1);
end
cap.String='矩形 −2.2 dB → Hann 24.8 dB：弱音出来了，主瓣宽了一倍。';[frames,lastFrame]=holdFrames(f,writer,frames,150);
[ax,cap,info]=scene(f,'③ 选窗是取舍','同一段信号，同一幅值标尺：与静态图下排并排比较。');ax.Position=[.08 .22 .38 .47];
setupAxes(ax,[0 40],[-90 5],'频率索引 k','单边幅值 (dB)');stem(ax,0:M-1,db(specRect),'filled','Color',blue,'MarkerSize',4,'BaseValue',-90);xline(ax,weakCyc,'r:');title(ax,'矩形：弱音被泄漏淹没');
a2=axes(f,'Position',[.56 .22 .38 .47]);setupAxes(a2,[0 40],[-90 5],'频率索引 k','单边幅值 (dB)');stem(a2,0:M-1,db(specHann),'filled','Color',blue,'MarkerSize',4,'BaseValue',-90);xline(a2,weakCyc,'r:');title(a2,'Hann：主瓣宽，弱音显现');
cap.String='分辨相近频率要窄主瓣，发现弱信号要低旁瓣。';[frames,lastFrame]=holdFrames(f,writer,frames,240);assert(frames==1080);

close(writer);catch failure,close(writer);rethrow(failure);end
fileInfo=dir(moviePath);if fileInfo.bytes<8e6,break;end
end
assert(fileInfo.bytes<8e6);checkValues(metrics,codeDir);
imwrite(lastFrame.cdata,fullfile(mediaDir,'3.7-windows-poster.png'));
metrics.frames=frames;metrics.frame_rate=30;metrics.duration_s=frames/30;metrics.width=1280;metrics.height=720;metrics.quality=quality;metrics.file_size_bytes=fileInfo.bytes;metrics.all_checks_passed=true;
metrics.matlab_version=version;metrics.generated_at=char(datetime('now','Format','yyyy-MM-dd HH:mm:ss'));
fid=fopen(fullfile(codeDir,'results','verification-video-windows.json'),'w','n','UTF-8');assert(fid>=0);fprintf(fid,'%s\n',jsonencode(metrics,PrettyPrint=true));fclose(fid);disp(metrics);

function checkValues(m,codeDir)
assert(all(abs(m.window_peak_sidelobe_db-[-13.25 -31.47 -42.31 -58.11])<.1));
assert(all(abs(m.window_first_null_bins-[1 2.04 2.09 3.06])<.02));
assert(abs(m.weak_tone_contrast_db_rect+2.16)<.1 && abs(m.weak_tone_contrast_db_hann-24.81)<.1);
assert(abs(m.weak_tone_amplitude_hann-.00507)/.00507<.05);
s=jsondecode(fileread(fullfile(codeDir,'verification-dft.json')));names=fieldnames(m);
for k=1:numel(names),if strcmp(names{k},'contrast_bins'),continue;end;assert(all(abs(m.(names{k})(:)-s.(names{k})(:))<1e-10));end
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
