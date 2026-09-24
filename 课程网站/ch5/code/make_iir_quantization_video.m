%% 5.3 自制系数舍入动画；基础 MATLAB，数值核心逐字来自原演示
clearvars;
A = 3; b1 = [1 1]; a1 = [1 -0.6]; b2 = [1 -3.14 1]; a2 = [1 0.7 0.72];
B = A*conv(b1, b2); Aa = conv(a1, a2);            % 乘开成直接型：B(z)/Aa(z)
Nh = 30; delta = [1 zeros(1, Nh-1)];
hDir = filter(B, Aa, delta);
hCas = A*filter(b2, a2, filter(b1, a1, delta));   % 第一节的输出作第二节的输入
errCas = max(abs(hCas - hDir));

%% 演示2：并联型——同一个 H(z) 拆成 G0 + A1/(1−0.6z^-1) + (r0 + r1 z^-1)/(1+0.7z^-1+0.72z^-2)（教材式 (5.2.9)）
% 分子恒等式：B(z) = G0·Aa(z) + A1·a2(z) + (r0 + r1 z^-1)·a1(z)，比较 z^0…z^-3 的系数得 4 个线性方程
col = @(p) [p(:); zeros(4 - numel(p), 1)];
Mtx = [col(Aa), col(a2), col(conv([1 0], a1)), col(conv([0 1], a1))];
coef = Mtx \ col(B); G0 = coef(1); A1 = coef(2); r0 = coef(3); r1 = coef(4);
hPar = G0*delta + filter(A1, a1, delta) + filter([r0 r1], a2, delta);   % 各节并行，输出相加
errPar = max(abs(hPar - hDir));
p54 = max(abs(roots([1 -2.95 3.14])));           % 教材例 5.4 第一节的极点模（供课堂说明）

%% 演示3：系数量化——一个极点密集的六阶系统，直接型与级联型的系数都舍入到 Bits 位小数，极点跑到哪里（教材 5.2.2 的论断）
rp = 0.98; th = [0.10 0.12 0.14]*pi;
secs = zeros(3, 3); for i = 1:3, secs(i, :) = [1 -2*rp*cos(th(i)) rp^2]; end   % 三个二阶节的分母
Ad = 1; for i = 1:3, Ad = conv(Ad, secs(i, :)); end                          % 直接型分母（六阶）
Bits = 8; q = @(c) round(c*2^Bits)/2^Bits;                                    % 舍入到 2^-Bits
AdQ = q(Ad); pDirQ = roots(AdQ);
pCasQ = zeros(6, 1); for i = 1:3, pCasQ(2*i-1:2*i) = roots(q(secs(i, :))); end
pExact = roots(Ad);
dDir = max(arrayfun(@(p) min(abs(pDirQ - p)), pExact));   % 每个精确极点到最近的量化极点的距离，取最大
dCas = max(arrayfun(@(p) min(abs(pCasQ - p)), pExact));
rDirQ = max(abs(pDirQ)); rCasQ = max(abs(pCasQ));

%% 演示4：量化后的幅频响应：直接型走样，级联型几乎不变
w = linspace(0, 0.5*pi, 2048);
Hex = 1 ./ dtft_resp(Ad, 1, w); Hdq = 1 ./ dtft_resp(AdQ, 1, w);
Hcq = ones(size(w)); for i = 1:3, Hcq = Hcq ./ dtft_resp(q(secs(i, :)), 1, w); end
ref = max(abs(Hex));


codeDir=fileparts(mfilename('fullpath')); mediaDir=fullfile(codeDir,'..','media');if ~exist(mediaDir,'dir'),mkdir(mediaDir);end
metrics=struct('err_cascade',errCas,'err_parallel',errPar,'parallel_G0',G0,'parallel_A1',A1,'parallel_r0',r0,'parallel_r1',r1,'sixth_order_Ad',Ad,'quant_bits',8,'pole_shift_direct',dDir,'pole_shift_cascade',dCas,'max_pole_radius_directQ',rDirQ,'max_pole_radius_cascadeQ',rCasQ);
checkValues(metrics,codeDir); % 只断言 Bits=8；写视频之前完成
bitsList=[16 15 14 12 10 8 6];sweep=repmat(struct('Bits',0,'pole_shift_direct',0,'pole_shift_cascade',0,'max_pole_radius_directQ',0,'max_pole_radius_cascadeQ',0),1,7);states=cell(1,7);
for j=1:numel(bitsList)
 states{j}=quantized(bitsList(j),Ad,secs,pExact,w,ref);t=states{j};
 sweep(j)=struct('Bits',t.Bits,'pole_shift_direct',t.dDir,'pole_shift_cascade',t.dCas,'max_pole_radius_directQ',t.rDir,'max_pole_radius_cascadeQ',t.rCas);
end
s8=states{find(bitsList==8)};
f=figure('Color','w','Position',[30 30 1280 720],'MenuBar','none','ToolBar','none','Visible','off');cleanup=onCleanup(@() delete(f(isgraphics(f))));
blue=[0 .36 .68];red=[.86 .24 .12];moviePath=fullfile(mediaDir,'5.3-iir-quantization.mp4');
for quality=[90 75]
 writer=VideoWriter(moviePath,'MPEG-4');writer.FrameRate=30;writer.Quality=quality;open(writer);frames=0;
 try
 [cap,info]=scene(f,'① 三种结构，同一个 h(n)','例 5.3：只改变实现结构，先比较未量化的输出。');
 ax=axes(f,'Position',[.09 .23 .85 .47]);hold(ax,'on');grid(ax,'on');ax.FontSize=15;ax.Toolbar.Visible='off';
 stem(ax,0:Nh-1,hDir,'Color',[.65 .65 .65],'MarkerSize',7);xlim(ax,[-1 30]);ylim(ax,[min(hDir)-1 max(hDir)+1]);xlabel(ax,'n');ylabel(ax,'h(n)');
 trace=stem(ax,NaN,NaN,'filled','Color',blue,'MarkerSize',3);lg=legend(ax,{'直接型','级联型'},'Location','northeast','AutoUpdate','off');
 info.String=sprintf('最大差：级联 %.2g；并联 %.2g',errCas,errPar);[frames,lastFrame]=holdFrames(f,writer,frames,30);
 for k=1:Nh,set(trace,'XData',0:k-1,'YData',hCas(1:k));[frames,lastFrame]=holdFrames(f,writer,frames,2);end
 [frames,lastFrame]=holdFrames(f,writer,frames,15);set(trace,'XData',NaN,'YData',NaN,'Color',red);lg.String={'直接型','并联型'};
 for k=1:Nh,set(trace,'XData',0:k-1,'YData',hPar(1:k));[frames,lastFrame]=holdFrames(f,writer,frames,2);end
 cap.String=sprintf('算出来的 h(n) 一样：级联差 %.0g，并联差 %.0g。',errCas,errPar);[frames,lastFrame]=holdFrames(f,writer,frames,75);
 [cap,info]=scene(f,'② 系数舍入位数一级级降','Bits 是小数位数；红 × 直接型，蓝 + 级联型；位移不保证单调。');
 [axL,axR,handles]=pairPlots(f,pExact,w,Hex,ref);
 cap.String='先看精确极点，再从 Bits=16 开始，看哪一级先越出单位圆。';[frames,lastFrame]=holdFrames(f,writer,frames,30);
 for j=1:7
  t=states{j};updatePair(handles,t,w);info.String=metricText(t);if t.rDir>1,info.Color=[.6 0 0];else,info.Color=[0 0 0];end
  outside=sum(real(t.pDir)>.0 & imag(t.pDir)>=0 & (real(t.pDir)<.55 | real(t.pDir)>1.15 | imag(t.pDir)>.65));
  cap.String=sprintf('直接型最大模 %.4f；级联型 %.4f。上半平面有 %d 个红叉超出局部视窗。',t.rDir,t.rCas,outside);
  [frames,lastFrame]=holdFrames(f,writer,frames,69);
 end
 updatePair(handles,s8,w);info.String=metricText(s8);cap.String=sprintf('回看 Bits=8：直接型位移 %.3f、最大模 %.3f；级联型 %.3f、%.3f。',s8.dDir,s8.rDir,s8.dCas,s8.rCas);[frames,lastFrame]=holdFrames(f,writer,frames,27);
 [cap,info]=scene(f,'③ 为什么','回到 Bits=8，放大观察三个精确极点附近。');
 ax=axes(f,'Position',[.08 .25 .42 .46]);hold(ax,'on');grid(ax,'on');ax.FontSize=14;ax.Toolbar.Visible='off';
 tt=linspace(0,2*pi,400);plot(ax,cos(tt),sin(tt),'k--');plot(ax,real(pExact),imag(pExact),'ko','MarkerSize',10,'LineWidth',1.5);plot(ax,real(s8.pDir),imag(s8.pDir),'x','Color',[.6 0 0],'MarkerSize',11,'LineWidth',2);plot(ax,real(s8.pCas),imag(s8.pCas),'+','Color',blue,'MarkerSize',11,'LineWidth',2);
 axis(ax,'equal');xlim(ax,[.85 1]);ylim(ax,[.27 .45]);xlabel(ax,'Re z');ylabel(ax,'Im z');title(ax,'黑圈：精确；蓝 +：级联型');
 cap.String='直接型的红叉已偏离这一局部视窗；二阶节的极点仍贴近黑圈。';[frames,lastFrame]=holdFrames(f,writer,frames,30);
 annotation(f,'textbox',[.54 .47 .41 .19],'String',{'直接型：6 个极点由 7 个系数共同决定','一个系数动，6 个极点一起动'},'FontSize',18,'Color',[.6 0 0],'EdgeColor','none','Interpreter','none');[frames,lastFrame]=holdFrames(f,writer,frames,75);
 annotation(f,'textbox',[.54 .28 .41 .16],'String',{'级联型：每个二阶节','只管自己的 2 个极点'},'FontSize',18,'Color',blue,'EdgeColor','none','Interpreter','none');
 cap.String='结构不改变 H(z)，但改变系数写成有限位数之后的 H(z)。';[frames,lastFrame]=holdFrames(f,writer,frames,135);
 [cap,info]=scene(f,'④ 定格：舍入到 2^{-8}','同页面静态图③④：极点位移与对应的幅频响应。');
 [axL,axR,handles]=pairPlots(f,pExact,w,Hex,ref);updatePair(handles,s8,w);info.String=metricText(s8);info.Color=[.6 0 0];
 cap.String={'③ 系数舍入后的极点：直接型越出单位圆，级联型接近精确极点','④ 量化后的幅频响应：级联型与精确曲线重合，直接型的峰走样'};
 [frames,lastFrame]=holdFrames(f,writer,frames,180);close(writer);
 catch failure,close(writer);rethrow(failure);end
 fileInfo=dir(moviePath);if fileInfo.bytes<8e6,break;end
end
assert(frames==1200 && fileInfo.bytes<8e6);checkValues(metrics,codeDir);
imwrite(lastFrame.cdata,fullfile(mediaDir,'5.3-iir-quantization-poster.png'));
metrics.bits_sweep=sweep;metrics.duration_s=frames/30;metrics.frames=frames;metrics.fps=30;metrics.width=1280;metrics.height=720;metrics.quality=quality;metrics.file_size_bytes=fileInfo.bytes;metrics.all_checks_passed=true;metrics.matlab_version=version;metrics.generated_at=char(datetime('now','Format','yyyy-MM-dd HH:mm:ss'));
first=find([sweep.max_pole_radius_directQ]>1,1);metrics.first_unstable_in_sweep_bits=bitsList(first);
fid=fopen(fullfile(codeDir,'results','verification-video-iir-quantization.json'),'w','n','UTF-8');assert(fid>=0);fprintf(fid,'%s\n',jsonencode(metrics,PrettyPrint=true));fclose(fid);disp(metrics);

function checkValues(m,codeDir)
s=jsondecode(fileread(fullfile(codeDir,'results','verification-iir-cascade-parallel.json')));
assert(m.quant_bits==8);names=fieldnames(m);for j=1:numel(names),assert(all(abs(m.(names{j})(:)-s.(names{j})(:))<1e-10));end
assert(m.err_cascade<1e-12 && m.err_parallel<1e-9);
% 任务书四位小数是展示值；1e-6 的系数核验以参考 JSON 完整精度为准。
for name={'parallel_G0','parallel_A1','parallel_r0','parallel_r1'},assert(abs(m.(name{1})-s.(name{1}))<1e-6);end
assert(abs(m.pole_shift_direct-.1626)<1e-3 && abs(m.pole_shift_cascade-.00213)<1e-4);
assert(abs(m.max_pole_radius_directQ-1.1218)<1e-3 && abs(m.max_pole_radius_cascadeQ-.9803)<1e-3);
end
function t=quantized(Bits,Ad,secs,pExact,w,ref)
q = @(c) round(c*2^Bits)/2^Bits;
AdQ=q(Ad);pDirQ=roots(AdQ);pCasQ=zeros(6,1);
for i=1:3,pCasQ(2*i-1:2*i)=roots(q(secs(i,:)));end
Hdq=1./dtft_resp(AdQ,1,w);Hcq=ones(size(w));for i=1:3,Hcq=Hcq./dtft_resp(q(secs(i,:)),1,w);end
t=struct('Bits',Bits,'pDir',pDirQ,'pCas',pCasQ,'HdB',20*log10(abs(Hdq)/ref),'HcB',20*log10(abs(Hcq)/ref),'dDir',max(arrayfun(@(p) min(abs(pDirQ-p)),pExact)),'dCas',max(arrayfun(@(p) min(abs(pCasQ-p)),pExact)),'rDir',max(abs(pDirQ)),'rCas',max(abs(pCasQ)));
end
function s=metricText(t)
flag='';if t.rDir>1,flag='；越出单位圆';end
s={sprintf('Bits=%d：直接型位移 %.3f（最大模 %.3f）%s',t.Bits,t.dDir,t.rDir,flag),sprintf('级联型位移 %.4f（最大模 %.3f）',t.dCas,t.rCas)};
end
function [cap,info]=scene(f,heading,note)
clf(f);
annotation(f,'textbox',[.055 .90 .91 .07],'String',heading,'FontSize',24,'FontWeight','bold','EdgeColor','none','Interpreter','tex');
annotation(f,'textbox',[.055 .82 .92 .065],'String',note,'FontSize',15,'EdgeColor','none','Interpreter','none');
info=annotation(f,'textbox',[.05 .71 .9 .1],'String','','FontSize',14,'HorizontalAlignment','right','EdgeColor','none','Interpreter','none');
cap=annotation(f,'textbox',[.055 .025 .91 .12],'String','','FontSize',16,'Color',[0 .36 .62],'EdgeColor','none','Interpreter','tex');
end
function [a,b,h]=pairPlots(f,pExact,w,Hex,ref)
a=axes(f,'Position',[.075 .25 .37 .42]);hold(a,'on');grid(a,'on');a.FontSize=13;a.Toolbar.Visible='off';
tt=linspace(0,2*pi,400);plot(a,cos(tt),sin(tt),'k--');plot(a,real(pExact),imag(pExact),'ko','MarkerSize',8,'LineWidth',1.5);
h.pD=plot(a,NaN,NaN,'rx','MarkerSize',10,'LineWidth',2);h.pC=plot(a,NaN,NaN,'b+','MarkerSize',10,'LineWidth',2);axis(a,'equal');xlim(a,[.55 1.15]);ylim(a,[-.05 .65]);xlabel(a,'Re z');ylabel(a,'Im z');
legend(a,{'单位圆','精确极点','直接型','级联型'},'Location','southoutside','Orientation','horizontal','FontSize',10,'AutoUpdate','off');
b=axes(f,'Position',[.57 .25 .37 .42]);hold(b,'on');grid(b,'on');b.FontSize=13;b.Toolbar.Visible='off';plot(b,w/pi,20*log10(abs(Hex)/ref),'k-','LineWidth',2);
h.hD=plot(b,NaN,NaN,'r-','LineWidth',1.3);h.hC=plot(b,NaN,NaN,'b--','LineWidth',1.5);xlim(b,[0 .5]);ylim(b,[-80 20]);xlabel(b,'\omega/\pi');ylabel(b,'相对幅度 (dB)');legend(b,{'精确','直接型量化','级联型量化'},'Location','southoutside','Orientation','horizontal','FontSize',10,'AutoUpdate','off');
end
function updatePair(h,t,w)
c=[.86 .24 .12];if t.rDir>1,c=[.6 0 0];end
set(h.pD,'XData',real(t.pDir),'YData',imag(t.pDir),'Color',c);set(h.pC,'XData',real(t.pCas),'YData',imag(t.pCas));set(h.hD,'XData',w/pi,'YData',t.HdB,'Color',c);set(h.hC,'XData',w/pi,'YData',t.HcB);
end

function H = dtft_resp(b, a, w)
z = exp(-1i*w(:).');
H = polyval(fliplr(b), z) ./ polyval(fliplr(a), z);
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
