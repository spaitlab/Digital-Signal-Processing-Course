%% 6.4 自制动画；直接调用现有公用函数
clearvars;
here = fileparts(mfilename('fullpath')); if endsWith(here, 'mlx'), here = fileparts(here); end
if ~exist(fullfile(here, 'dsp_freqz.m'), 'file'), here = fileparts(which('dsp_freqz')); end   % Live Script 里 mfilename 为空时靠路径找
codedir = here; addpath(codedir); outdir = fullfile(codedir, 'results'); if ~exist(outdir, 'dir'), mkdir(outdir); end

Ts = [0.5 0.1]; L = 12; errStep = zeros(1, 2); yStep = cell(1, 2); tStep = cell(1, 2);
exactY = @(t) 0.5*(sin(t) - cos(t) + exp(-t));                        % y'+y=sin t，y(0)=0 的解析解
for i = 1:2
    T = Ts(i); [bz1, az1] = dsp_bilinear(1, [1 1], T);              % Ha(s)=1/(s+1) → 梯形法差分方程
    t = 0:T:L; y = filter(bz1, az1, sin(t));
    errStep(i) = max(abs(y - exactY(t))); yStep{i} = y; tStep{i} = t;
end

%% 演示2：频率映射 ω = 2·arctan(ΩT/2)（教材式 (6.3.7)、图 6.3.2）：整个 jΩ 轴压进 (−π, π)，高频压缩得厉害
T = 1; Om = linspace(0, 12, 600); wmap = 2*atan(Om*T/2);
wLin = Om*T;                                                          % 若是线性映射 ω=ΩT
devAt = @(Omega) 100*(Omega*T - 2*atan(Omega*T/2))/(2*atan(Omega*T/2));   % 相对偏离

wp = 0.2*pi; ws = 0.3*pi; ap = 1; as = 15; T = 1;
eps = sqrt(10^(ap/10) - 1);
WcPre = (2/T)*tan(wp/2); WsPre = (2/T)*tan(ws/2);
N = ceil(acosh(sqrt(10^(as/10) - 1)/eps)/acosh(WsPre/WcPre));         % 3.014 → 4
[bA, aA] = dsp_cheby1_analog(N, eps, WcPre); [bz8, az8] = dsp_bilinear(bA, aA, T);
azBook8 = conv([1 -1.4996 0.8482], [1 -1.5548 0.6493]); bzBook8 = 0.001836*[1 4 6 4 1];
errBook8 = max(abs([bz8 - bzBook8, az8 - azBook8]));
[bAn, aAn] = dsp_cheby1_analog(N, eps, wp); [bzn, azn] = dsp_bilinear(bAn, aAn, T);   % 不预畸变：直接拿 Ωc=ωp
wd = linspace(0, pi, 1024);
H8 = dsp_freqz(bz8, az8, wd); Hn = dsp_freqz(bzn, azn, wd);
att8 = -20*log10(abs(dsp_freqz(bz8, az8, [wp ws]))); attn = -20*log10(abs(dsp_freqz(bzn, azn, [wp ws])));
wEdgeNoPre = 2*atan(wp*T/2);                                           % 不预畸变时通带边界实际落在的位置


% 例 6.8 的映射恒等式；调用现有 dsp_freqs，不做例 6.7 或工具箱对照。
wCheck=linspace(0,pi-1e-3,512);
errMap8=max(abs(dsp_freqz(bz8,az8,wCheck)-dsp_freqs(bA,aA,(2/T)*tan(wCheck/2))));
metrics=struct('trapezoid_T',Ts,'trapezoid_err_sin_input',errStep,'map_dev_percent_at_1_3',[devAt(1) devAt(3)],'ex68_Wc_prewarped',WcPre,'ex68_N',N,'ex68_att_wp_ws',att8,'noprewarp_att_wp_ws',attn,'noprewarp_edge_over_pi',wEdgeNoPre/pi,'ex68_bz',bz8,'ex68_az',az8);
checkValues(metrics,codedir);assert(errMap8<1e-9);
mediaDir=fullfile(codedir,'..','media');if ~exist(mediaDir,'dir'),mkdir(mediaDir);end
f=figure('Color','w','Position',[30 30 1280 720],'MenuBar','none','ToolBar','none','Visible','off');cleanup=onCleanup(@() delete(f(isgraphics(f))));blue=[0 .36 .68];orange=[.85 .35 .05];moviePath=fullfile(mediaDir,'6.4-bilinear.mp4');
for quality=[90 75]
 writer=VideoWriter(moviePath,'MPEG-4');writer.FrameRate=30;writer.Quality=quality;open(writer);frames=0;
 try
 [cap,info]=scene(f,'① 来历：一条数值积分公式','y′+y=sin t，y(0)=0；黑线是解析解。');
 ax=panel(f,[.10 .24 .83 .48]);tc=linspace(0,L,600);plot(ax,tc,exactY(tc),'k-','LineWidth',1.8);xlim(ax,[0 L]);ylim(ax,[-.8 .85]);xlabel(ax,'t');ylabel(ax,'y(t)');
 a=plot(ax,NaN,NaN,'o-','Color',orange,'MarkerSize',5);b=plot(ax,NaN,NaN,'.-','Color',blue,'MarkerSize',9);legend(ax,{'解析解','T=0.5','T=0.1'},'Location','southoutside','Orientation','horizontal','AutoUpdate','off');
 info.String=sprintf('最大误差：T=0.5 → %.6f；T=0.1 → %.8f',errStep);[frames,lastFrame]=holdFrames(f,writer,frames,30);
 for j=1:90,k=max(1,ceil(j*numel(tStep{1})/90));set(a,'XData',tStep{1}(1:k),'YData',yStep{1}(1:k));[frames,lastFrame]=holdFrames(f,writer,frames,1);end
 for j=1:90,k=max(1,ceil(j*numel(tStep{2})/90));set(b,'XData',tStep{2}(1:k),'YData',yStep{2}(1:k));[frames,lastFrame]=holdFrames(f,writer,frames,1);end
 cap.String=sprintf('T 缩小 5 倍，误差缩小 %.1f 倍（约 25 倍）：这就是双线性变换的出身。',errStep(1)/errStep(2));[frames,lastFrame]=holdFrames(f,writer,frames,30);
 [cap,info]=scene(f,'② 映射：把整条 jΩ 轴弯进单位圆','T=1；演示正半轴，负半轴关于实轴对称。一对一映射，无混叠。');
 left=panel(f,[.12 .47 .18 .30]);xlim(left,[-2 2]);ylim(left,[0 13]);plot(left,[0 0],[0 13],'k-');xlabel(left,'Re s');ylabel(left,'Im s = Ω');title(left,'s 平面');ps=plot(left,0,0,'o','Color',blue,'MarkerFaceColor',blue,'MarkerSize',8);
 right=panel(f,[.65 .46 .18 .32]);tt=linspace(0,2*pi,360);plot(right,cos(tt),sin(tt),'k-');xlim(right,[-1.2 1.2]);ylim(right,[-1.2 1.2]);axis(right,'square');xlabel(right,'Re z');ylabel(right,'Im z');title(right,'z 平面');pz=plot(right,1,0,'o','Color',blue,'MarkerFaceColor',blue,'MarkerSize',8);
 curve=panel(f,[.12 .20 .76 .15]);plot(curve,Om,wLin/pi,'k--');yline(curve,1,'k:');xlim(curve,[0 12]);ylim(curve,[0 1.1]);xlabel(curve,'Ω (T=1)');ylabel(curve,'ω/π');path=plot(curve,NaN,NaN,'Color',blue,'LineWidth',2);pc=plot(curve,0,0,'o','MarkerFaceColor',blue,'Color',blue);text(curve,9,1.04,'ω=π','FontSize',12);
 link=annotation(f,'line',[.21 .815],[.47 .62],'Color',[.78 .84 .9],'LineWidth',1);[frames,lastFrame]=holdFrames(f,writer,frames,30);
 waypoints={linspace(0,1,90),linspace(1,3,60),linspace(3,12,90)};
 for leg=1:3
  for Omega=waypoints{leg}
   omega=2*atan(Omega*T/2);z=exp(1i*omega);set(ps,'YData',Omega);set(pz,'XData',real(z),'YData',imag(z));og=[Om(Om<Omega) Omega];set(path,'XData',og,'YData',2*atan(og*T/2)/pi);set(pc,'XData',Omega,'YData',omega/pi);
   set(link,'X',[.21 .65+.18*(real(z)+1.2)/2.4],'Y',[.47+.30*Omega/13 .46+.32*(imag(z)+1.2)/2.4]);
   info.String=sprintf('Ω=%.2f → ω/π=%.4f',Omega,omega/pi);cap.String='黑虚线：线性映射 ω=ΩT；蓝线：双线性频率映射。';[frames,lastFrame]=holdFrames(f,writer,frames,1);
  end
  if leg<3
   cap.String=sprintf('Ω=%.0f：相对偏离 %.2f%%；分母取实际映射值 ω。',Omega,devAt(Omega));text(curve,Omega+.2,omega/pi-.10,sprintf('%.1f%%',devAt(Omega)),'FontSize',13,'Color',orange);[frames,lastFrame]=holdFrames(f,writer,frames,30);
  end
 end
 cap.String=sprintf('Ω=1 偏离 %.1f%%，Ω=3 偏离 %.0f%%：高频压得厉害；有限 Ω 永远到不了 π。',devAt(1),devAt(3));[frames,lastFrame]=holdFrames(f,writer,frames,90);
 [cap,info]=scene(f,'③ 预畸变：先把指标弯回去','例 6.8：通带 0.2π / 1 dB，阻带 0.3π / 15 dB；同用 N=4。');
 ax=panel(f,[.10 .26 .83 .44]);[pre,no]=responsePlot(ax,wd,H8,Hn,wp,ws,ap,as,false);[frames,lastFrame]=holdFrames(f,writer,frames,30);
 for j=1:120,k=ceil(j*numel(wd)/120);set(no,'XData',wd(1:k)/pi,'YData',20*log10(abs(Hn(1:k))));info.String=sprintf('不预畸变：Ω_c=ω_p；边界落到 %.5fπ',wEdgeNoPre/pi);[frames,lastFrame]=holdFrames(f,writer,frames,1);end
 xline(ax,wEdgeNoPre/pi,':','Color',orange);text(ax,.30,-9,sprintf('边界跑了：%.3fπ',wEdgeNoPre/pi),'Color',orange,'FontSize',15);
 for j=1:120,k=ceil(j*numel(wd)/120);set(pre,'XData',wd(1:k)/pi,'YData',20*log10(abs(H8(1:k))));info.String=sprintf('预畸变 Ω_c=%.4f：ω_p 处 %.2f dB，ω_s 处 %.1f dB',WcPre,att8);[frames,lastFrame]=holdFrames(f,writer,frames,1);end
 xline(ax,wp/pi,':','Color',blue);text(ax,.30,-23,'预畸变：边界回到 0.2π','Color',blue,'FontSize',15);cap.String='先按 tan 把指标弯回去，再做变换：边界正好落在 0.2π。';[frames,lastFrame]=holdFrames(f,writer,frames,90);
 [cap,info]=scene(f,'④ 定格：频率映射与预畸变','同页面静态图②④：无混叠，频率轴非线性；设计前先补偿边界。');
 ax=panel(f,[.08 .30 .37 .39]);plot(ax,Om,wmap/pi,'Color',blue,'LineWidth',2);plot(ax,Om,wLin/pi,'k--');yline(ax,1,'k:');xlim(ax,[0 12]);ylim(ax,[0 1.1]);xlabel(ax,'Ω (T=1)');ylabel(ax,'ω/π');legend(ax,{'双线性','线性映射'},'Location','southoutside','Orientation','horizontal','AutoUpdate','off');
 ax=panel(f,[.57 .30 .37 .39]);responsePlot(ax,wd,H8,Hn,wp,ws,ap,as,true);xline(ax,wEdgeNoPre/pi,'k:');
 info.String=sprintf('例 6.8：Ω_c=%.4f，N=%d；ω_p/ω_s 处 %.2f / %.2f dB',WcPre,N,att8);
 cap.String={sprintf('② ω=2arctan(ΩT/2)：Ω=1 / 3 的相对偏离 %.1f%% / %.0f%%',devAt(1),devAt(3)),sprintf('④ 预畸变守住 0.2π；不预畸变的通带边界跑到 %.3fπ',wEdgeNoPre/pi)};[frames,lastFrame]=holdFrames(f,writer,frames,180);close(writer);
 catch failure,close(writer);rethrow(failure);end
 fileInfo=dir(moviePath);if fileInfo.bytes<8e6,break;end
end
assert(frames==1200 && fileInfo.bytes<8e6);checkValues(metrics,codedir);
imwrite(lastFrame.cdata,fullfile(mediaDir,'6.4-bilinear-poster.png'));
metrics.ex68_mapping_identity_max_error=errMap8;metrics.frames=frames;metrics.fps=30;metrics.duration_s=frames/30;metrics.width=1280;metrics.height=720;metrics.quality=quality;metrics.file_size_bytes=fileInfo.bytes;metrics.all_checks_passed=true;metrics.matlab_version=version;metrics.generated_at=char(datetime('now','Format','yyyy-MM-dd HH:mm:ss'));
fid=fopen(fullfile(outdir,'verification-video-bilinear.json'),'w','n','UTF-8');assert(fid>=0);fprintf(fid,'%s\n',jsonencode(metrics,PrettyPrint=true));fclose(fid);disp(metrics);

function checkValues(m,codedir)
r=jsondecode(fileread(fullfile(codedir,'results','verification-bilinear.json')));names=fieldnames(m);for j=1:numel(names),assert(all(abs(m.(names{j})(:)-r.(names{j})(:))<1e-10));end
assert(all(abs(m.trapezoid_err_sin_input-[.014125 .00055547])<1e-6));ratio=m.trapezoid_err_sin_input(1)/m.trapezoid_err_sin_input(2);assert(ratio>15 && ratio<35);
assert(all(abs(m.map_dev_percent_at_1_3-[7.8405 52.626])<1e-3));assert(abs(m.ex68_Wc_prewarped-.64984)<1e-6 && m.ex68_N==4);
assert(all(abs(m.ex68_att_wp_ws-[1 23.607])<1e-3));assert(all(abs(m.noprewarp_att_wp_ws-[2.2004 25.103])<1e-3));
% 0.19378 是展示舍入值，距完整值 4.38e-6；1e-6 核验按参考 JSON 完整值。
assert(abs(m.noprewarp_edge_over_pi-r.noprewarp_edge_over_pi)<1e-6);
end
function [cap,info]=scene(f,heading,note)
clf(f);annotation(f,'textbox',[.055 .90 .92 .07],'String',heading,'FontSize',24,'FontWeight','bold','EdgeColor','none','Interpreter','none');
annotation(f,'textbox',[.055 .82 .92 .065],'String',note,'FontSize',15,'EdgeColor','none','Interpreter','none');
info=annotation(f,'textbox',[.055 .755 .90 .055],'String','','FontSize',14,'HorizontalAlignment','right','EdgeColor','none','Interpreter','tex');
cap=annotation(f,'textbox',[.055 .025 .92 .11],'String','','FontSize',16,'Color',[0 .36 .62],'EdgeColor','none','Interpreter','tex');
end
function ax=panel(f,position)
ax=axes(f,'Position',position);hold(ax,'on');grid(ax,'on');ax.FontSize=14;ax.Toolbar.Visible='off';
end
function [pre,no]=responsePlot(ax,wd,H8,Hn,wp,ws,ap,as,showAll)
pre=plot(ax,NaN,NaN,'Color',[0 .36 .68],'LineWidth',2);no=plot(ax,NaN,NaN,'--','Color',[.85 .35 .05],'LineWidth',1.6);
if showAll,set(pre,'XData',wd/pi,'YData',20*log10(abs(H8)));set(no,'XData',wd/pi,'YData',20*log10(abs(Hn)));end
plot(ax,[0 wp/pi],[-ap -ap],'r-','LineWidth',2);plot(ax,[ws/pi 1],[-as -as],'r-','LineWidth',2);xlim(ax,[0 1]);ylim(ax,[-60 3]);xlabel(ax,'ω/π');ylabel(ax,'dB');legend(ax,{'预畸变','不预畸变','通带要求','阻带要求'},'Location','southoutside','NumColumns',2,'FontSize',11,'AutoUpdate','off');
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
