%% 2.1 采样与恢复本地动画（基础 MATLAB）
clearvars;
% 下列信号块逐字取自 demo_sampling.m，含完整 xRec6 累加。
f0 = 5; dur = 1; tc = 0:1e-4:dur; xa = @(t) cos(2*pi*f0*t);
fsHigh = 50; nH = 0:fsHigh*dur; tH = nH/fsHigh; xH = xa(tH);
fsLow = 6;   nL = 0:fsLow*dur;  tL = nL/fsLow;  xL = xa(tL);
fAlias = abs(f0 - fsLow);                          % 折叠后的表观频率：|5 − 6| = 1 Hz

%% 演示2：频谱周期延拓——采样率 20 Hz 不重叠，12 Hz 重叠（混叠）
% 信号含 2、5、8 Hz 三个分量（最高 8 Hz）；采样后频谱以 f_s 为周期重复。
tones = [2 5 8]; amps = [1 0.8 0.6];
fsA = 20; fsB = 12;                                % 20 ≥ 2×8 不混叠；12 < 16 混叠
spectrumLines = @(fs) reshape((-3:3)'*fs + [tones, -tones], 1, []);   % 每个副本的谱线位置
lineAmps = @(fs) repelem([amps, amps], 7);        % 与 spectrumLines 的列主序一致

%% 演示3：从样本恢复连续信号——内插公式（教材 2.1.2）
% x_a(t) = Σ x(n) sin(π(t−nT)/T) / (π(t−nT)/T)，用 f_s = 12 Hz 的样本恢复 5 Hz 正弦。
fsR = 12; T = 1/fsR; nR = -60:60; tR = nR*T; xR = xa(tR);   % 多取一些样本，减小截断影响
sincU = @(z) (z == 0) + (z ~= 0).*sin(z + (z == 0))./(z + (z == 0));
tq = 0:1e-3:dur;
xRec = zeros(size(tq));
for k = 1:numel(nR), xRec = xRec + xR(k)*sincU(pi*(tq - tR(k))/T); end
xZoh = interp1(tR, xR, tq, 'previous');            % 零阶保持对照
xLin = interp1(tR, xR, tq, 'linear');              % 线性内插对照
errSinc = max(abs(xRec - xa(tq))); errZoh = max(abs(xZoh - xa(tq))); errLin = max(abs(xLin - xa(tq)));
% 混叠情形：用 6 Hz 的样本做同样的内插，只能恢复出 1 Hz
T6 = 1/fsLow; n6 = -30:30; t6 = n6*T6; x6 = xa(t6); xRec6 = zeros(size(tq));
for k = 1:numel(n6), xRec6 = xRec6 + x6(k)*sincU(pi*(tq - t6(k))/T6); end

codeDir=fileparts(mfilename('fullpath')); mediaDir=fullfile(codeDir,'..','media');
if ~exist(mediaDir,'dir'), mkdir(mediaDir); end
A=[cos(2*pi*fAlias*tq)',sin(2*pi*fAlias*tq)']; c=A\xRec6'; ampAlias=hypot(c(1),c(2));
sampleError=max(abs(xL-cos(2*pi*fAlias*tL)));
values=[sampleError ampAlias fsB-8 errSinc errZoh errLin];
checkValues(values,codeDir);
moviePath=fullfile(mediaDir,'2.1-sampling.mp4');
f=figure('Color','w','Position',[30 30 1280 720],'MenuBar','none','ToolBar','none','Visible','off');
cleanup=onCleanup(@() delete(f(isgraphics(f))));
blue=[0 .36 .62]; red=[.85 .2 .12]; gray=[.65 .65 .65];
for quality=[90 75]
 writer=VideoWriter(moviePath,'MPEG-4');writer.FrameRate=30;writer.Quality=quality;open(writer);frames=0;
 try
 for segment=1:4
  clf(f);ax=axes(f,'Position',[.09 .2 .86 .53]);hold(ax,'on');grid(ax,'on');
  ax.FontSize=15;ax.Toolbar.Visible='off';xlim(ax,[0 1]);ylim(ax,[-1.65 1.7]);xlabel(ax,'时间 t (s)');ylabel(ax,'幅度');
  names={'① 同一个 5 Hz 正弦，采样率一级级降','② 频谱以采样率重复：副本会靠拢','③ 样本够，用内插公式恢复','④ 样本不够，混叠后的信息无法唯一恢复'};
  notes={'采样点随采样率重画；红虚线是这些样本对应的基带表观频率。', ...
   '信号含 2、5、8 Hz；观察频谱副本与正负采样率一半的边界。', ...
   '12 Hz 采样：先加 0 ≤ t < 1 s 的 12 项，再补上区间外的样本贡献。', ...
   '6 Hz 采样：同样的样本可以来自 5 Hz，也可以来自 1 Hz。'};
  annotation(f,'textbox',[.07 .88 .91 .07],'String',names{segment},'FontSize',25,'FontWeight','bold','EdgeColor','none','Interpreter','none');
  annotation(f,'textbox',[.07 .8 .92 .07],'String',notes{segment},'FontSize',16,'EdgeColor','none','Interpreter','none');
  cap=annotation(f,'textbox',[.07 .025 .92 .07],'String','','FontSize',17,'Color',blue,'EdgeColor','none','Interpreter','none');
  infoText=text(ax,.99,1.52,'','HorizontalAlignment','right','FontSize',16);
  switch segment
   case 1
    ref=plot(ax,tc,xa(tc),'Color',gray,'LineWidth',1.5);
    samples=stem(ax,tH,xH,'filled','Color',blue,'MarkerSize',4);
    aliasLine=plot(ax,tc,xa(tc),'--','Color',red,'LineWidth',1.7);
    legend(ax,[ref samples aliasLine],{'原信号 5 Hz','采样值','基带表观频率'},'Location','southoutside','Orientation','horizontal','AutoUpdate','off');
    [frames,lastFrame]=holdFrames(f,writer,frames,30);
    for fs=[50 20 12 8 6]
     ts=0:1/fs:dur; apparent=min(abs(f0-(-10:10)*fs));
     assert(max(abs(xa(ts)-cos(2*pi*apparent*ts)))<1e-12);
     set(samples,'XData',ts,'YData',xa(ts));set(aliasLine,'YData',cos(2*pi*apparent*tc));
     infoText.String=sprintf('采样率 %g Hz → 看起来 %g Hz',fs,apparent);
     cap.String='10 Hz 是临界采样率；低于它，5 Hz 会冒充其他频率。';
     [frames,lastFrame]=holdFrames(f,writer,frames,60);
    end
    [frames,lastFrame]=holdFrames(f,writer,frames,30);
   case 2
    xlim(ax,[-30 30]);ylim(ax,[0 1.4]);xlabel(ax,'频率 (Hz)');ylabel(ax,'相对谱线幅度');
    infoText.Position=[29 1.25 0];
    replicas=stem(ax,spectrumLines(fsA),lineAmps(fsA),'Color',gray,'MarkerSize',3);
    base=stem(ax,[tones -tones],[amps amps],'filled','Color',blue,'LineWidth',1.7,'MarkerSize',5);
    edgeL=xline(ax,-fsA/2,'k--');edgeR=xline(ax,fsA/2,'k--');
    target=stem(ax,fsA-8,.6,'filled','Color',gray,'LineWidth',2,'MarkerSize',7);
    legend(ax,[base replicas edgeR target],{'原信号 ±2、±5、±8 Hz','周期副本','±采样率/2','跟踪 −8 + 采样率'},'Location','southoutside','Orientation','horizontal','AutoUpdate','off');
    [frames,lastFrame]=holdFrames(f,writer,frames,30);
    for fs=linspace(20,12,180)
     set(replicas,'XData',spectrumLines(fs));edgeL.Value=-fs/2;edgeR.Value=fs/2;
     set(target,'XData',fs-8);if fs-8<fs/2,target.Color=red;end
     infoText.String=sprintf('采样率 %.2f Hz；跟踪谱线 %.2f Hz',fs,fs-8);
     cap.String='副本以采样率为间隔；图中幅度归一化，只比较位置与重叠。';
     [frames,lastFrame]=holdFrames(f,writer,frames,1);
    end
    cap.String='采样率 12 Hz：8 Hz 折到 4 Hz，副本重叠就是混叠。';
    [frames,lastFrame]=holdFrames(f,writer,frames,90);
   otherwise
    if segment==3,nn=nR;ts=tR;xs=xR;period=T;expected=xRec;else,nn=n6;ts=t6;xs=x6;period=T6;expected=xRec6;end
    ref=plot(ax,tq,xa(tq),'k--','LineWidth',1.4);
    visible=ts>=0 & ts<=1;samples=stem(ax,ts(visible),xs(visible),'filled','Color',red,'MarkerSize',5);
    sumLine=plot(ax,tq,zeros(size(tq)),'Color',blue,'LineWidth',2.2);
    kernel=plot(ax,tq,zeros(size(tq)),'Color',[.65 .78 .65],'LineWidth',1.1);
    legend(ax,[ref samples sumLine kernel],{'原信号 5 Hz','采样值','已累加的 sinc 和','当前加权 sinc 项'},'Location','southoutside','Orientation','horizontal','AutoUpdate','off');
    [frames,lastFrame]=holdFrames(f,writer,frames,30);
    first=find(ts>=0 & ts<1);order=[first setdiff(1:numel(nn),first,'stable')];running=zeros(size(tq));
    if segment==3
     % 前 12 项每项 0.4 s；剩余 109 项在 30 帧（1 s）内分组累加。
     groups=arrayfun(@(i)order(i),1:12,'UniformOutput',false);
     rest=order(13:end);edges=round(linspace(0,numel(rest),31));
     for j=1:30,groups{end+1}=rest(edges(j)+1:edges(j+1));end
     repeats=[12*ones(1,12) ones(1,30)];tail=96;
    else
     % 61 项分组累加，用 150 帧即 5 s。
     groups=arrayfun(@(i)order(i),1:numel(order),'UniformOutput',false);
     edges=round(linspace(0,150,numel(order)+1));repeats=diff(edges);tail=60;
    end
    added=0;
    for j=1:numel(groups)
     for k=groups{j}
      contribution=xs(k)*sincU(pi*(tq-ts(k))/period);running=running+contribution;added=added+1;
     end
     set(kernel,'YData',contribution);set(sumLine,'YData',running);
     infoText.String=sprintf('%d / %d 项；对原信号最大误差 %.4f',added,numel(nn),max(abs(running-xa(tq))));
     if segment==3,cap.String='逐项相加：每个样本乘上一条平移的 sinc 核。';else,cap.String='黑虚线仍是 5 Hz；基带内插逐步形成慢变化曲线。';end
     [frames,lastFrame]=holdFrames(f,writer,frames,repeats(j));
    end
    assert(max(abs(running-expected))<1e-12,'重排累加应与原脚本一致');kernel.Visible='off';
    if segment==3
     cap.String='121 项 sinc 相加，误差约 8×10⁻⁴；有限截断近似理想恢复。';
    else
     cap.String='按基带 sinc 内插得到 1 Hz；仅凭这些样本无法区分原 5 Hz。';
    end
    [frames,lastFrame]=holdFrames(f,writer,frames,tail);
  end
  fprintf('完成第 %d 段；累计 %d 帧\n',segment,frames);
 end
 close(writer);
 catch failure
 close(writer);rethrow(failure);
 end
 fileInfo=dir(moviePath);if fileInfo.bytes<8e6,break;end
end
assert(frames==1200 && fileInfo.bytes<8e6);
imwrite(lastFrame.cdata,fullfile(mediaDir,'2.1-sampling-poster.png'));
checkValues(values,codeDir);
metrics=struct('matlab_version',version,'generated_at',char(datetime('now','Format','yyyy-MM-dd HH:mm:ss')), ...
 'frames',frames,'frame_rate',30,'duration_s',frames/30,'width',1280,'height',720,'quality',quality,'file_size_bytes',fileInfo.bytes, ...
 'sample_alias_error',sampleError,'alias_fitted_amplitude',ampAlias,'folded_8hz_to',fsB-8,'sinc_max_error',errSinc, ...
 'zoh_max_error',errZoh,'linear_max_error',errLin,'sinc_terms_recovery',numel(nR),'sinc_terms_alias',numel(n6), ...
 'source_comparison_tolerance',1e-10,'all_checks_passed',true);
fid=fopen(fullfile(codeDir,'results','verification-video-sampling.json'),'w','n','UTF-8');assert(fid>=0);fprintf(fid,'%s\n',jsonencode(metrics,PrettyPrint=true));fclose(fid);disp(metrics);

function checkValues(v,codeDir)
assert(v(1)<1e-12);assert(abs(v(2)-1.0003)<.05);assert(v(3)==4);
assert(abs(v(4)-.000787)<1e-4);assert(abs(v(5)-1.866)<1e-3);assert(abs(v(6)-.718)<1e-3);
saved=jsondecode(fileread(fullfile(codeDir,'results','verification-sampling.json')));
ref=[saved.alias_fitted_amplitude saved.folded_8hz_to saved.sinc_max_error saved.zoh_max_error saved.linear_max_error];
assert(all(abs(v(2:end)-ref)<1e-10),'与原演示确定性量不一致');
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
