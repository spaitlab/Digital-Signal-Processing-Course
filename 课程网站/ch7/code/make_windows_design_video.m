%% 7.4 自制动画；局部函数及数值定义来自原脚本
clearvars;
N = 51; wnames = {'矩形', '三角', '汉宁', '汉明', '布莱克曼', '凯塞 β=7.865'};
W = [win('rect', N); win('triang', N); win('hann', N); win('hamming', N); win('blackman', N); win('kaiser', N, 7.865)];

%% 演示2：窗的频谱：主瓣宽度与最高旁瓣（教材表 7.2.2 的“旁瓣峰值”列）
w = linspace(0, pi, 16384); WdB = zeros(6, numel(w)); sidelobe = zeros(1, 6); mainlobe = zeros(1, 6);
for i = 1:6
    Wf = abs(polyval(fliplr(W(i, :)), exp(-1i*w))); WdB(i, :) = 20*log10(Wf/Wf(1));
    [~, lmin] = local_maxima(-Wf); mainlobe(i) = 2*w(lmin(1));                 % 主瓣宽 = 2×第一零点
    sidelobe(i) = max(WdB(i, w > w(lmin(1))));                                 % 第一零点之外的最高旁瓣
end

%% 演示3：同一个理想低通（ωc=0.5π，N=51）用六种窗：阻带最小衰减对照表 7.2.2（−21/−25/−44/−53/−74/−80 dB）
wc = 0.5*pi; alpha = (N - 1)/2; hd = ideal_lp(wc, alpha, 0:N-1);
HdB = zeros(6, numel(w)); stopAtt = zeros(1, 6); transW = zeros(1, 6);
for i = 1:6
    h = hd.*W(i, :); Hf = abs(polyval(fliplr(h), exp(-1i*w))); HdB(i, :) = 20*log10(Hf/max(Hf));
    [~, lmin] = local_maxima(-Hf); i1 = lmin(find(w(lmin) > wc, 1));           % 阻带第一个谷
    stopAtt(i) = -max(HdB(i, w > w(i1)));                                      % 之后的最高旁瓣
    transW(i) = (w(find(Hf < 10^(-stopAtt(i)/20), 1)) - w(find(Hf < 1 - 10^(-stopAtt(i)/20), 1)))/pi;   % 从 1−δ 降到 δ 的宽度（π 为单位）
end
tableAtt = [21 25 44 53 74 80];

[h13, N13] = design_lp(0.3*pi, 0.5*pi, 'hann', 6.6);
[att13, rip13] = measure(h13, w, 0.3*pi, 0.5*pi, 'lp');
fs16 = 250; vp1 = 2*pi*15/fs16; vp2 = 2*pi*80/fs16; vs1 = 2*pi*40/fs16; vs2 = 2*pi*60/fs16;
[h16, N16] = design_bs(vp1, vp2, vs1, vs2, 'hamming', 6.6);
[att16, rip16] = measure(h16, w, [vp1 vp2], [vs1 vs2], 'bs');
% 教材参数（汉明、N=43）实测阻带只有约 47.5 dB，达不到 50 dB：把 N 逐步加大到达标为止
N16fix = N16; att16fix = att16;
while att16fix < 50
    N16fix = N16fix + 2; a16 = (N16fix - 1)/2; n16 = 0:N16fix-1; w1 = (vp1 + vs1)/2; w2 = (vp2 + vs2)/2;
    hd16 = -(ideal_lp(w2, a16, n16) - ideal_lp(w1, a16, n16)); hd16(n16 == a16) = 1 - (w2 - w1)/pi;
    att16fix = measure(hd16.*win('hamming', N16fix), w, [vp1 vp2], [vs1 vs2], 'bs');
end

here=fileparts(mfilename('fullpath'));outdir=fullfile(here,'results');mediaDir=fullfile(here,'..','media');if ~exist(mediaDir,'dir'),mkdir(mediaDir);end
metrics=struct('window_sidelobe_dB',sidelobe,'lowpass_stop_att_dB',stopAtt,'lowpass_transition_over_pi',transW,'ex713_N',N13,'ex713_att_ws_dB',att13,'ex713_pass_ripple_dB',rip13,'ex716_N',N16,'ex716_att_dB',att16,'ex716_N_needed_for_50dB',N16fix,'ex716_att_dB_fixed',att16fix);
checkValues(metrics,outdir);
H13=20*log10(abs(polyval(fliplr(h13),exp(-1i*w))));h16fixed=hd16.*win('hamming',N16fix);H16=20*log10(abs(polyval(fliplr(h16),exp(-1i*w))));H16fixed=20*log10(abs(polyval(fliplr(h16fixed),exp(-1i*w))));
f=figure('Color','w','Position',[30 30 1280 720],'MenuBar','none','ToolBar','none','Visible','off');cleanup=onCleanup(@() delete(f(isgraphics(f))));blue=[0 .36 .68];orange=[.85 .35 .05];moviePath=fullfile(mediaDir,'7.4-windows-design.mp4');
for quality=[90 75]
 writer=VideoWriter(moviePath,'MPEG-4');writer.FrameRate=30;writer.Quality=quality;open(writer);frames=0;
 try
 [cap,info]=scene(f,'① 同一个理想低通，换六种窗','N=51，ω_c=0.5π；变形中的窗是插值过渡，指标实时计算。');
 a=panel(f,[.08 .28 .36 .42]);wv=plot(a,0:N-1,W(1,:),'Color',blue,'LineWidth',2);xlim(a,[0 N-1]);ylim(a,[0 1.08]);xlabel(a,'n');ylabel(a,'w(n)');
 b=panel(f,[.57 .28 .37 .42]);hv=plot(b,w/pi,HdB(1,:),'Color',blue,'LineWidth',1.3);xlim(b,[0 1]);ylim(b,[-120 5]);xlabel(b,'ω/π');ylabel(b,'h_d·w 的幅频响应 (dB)');
 info.String=sprintf('矩形：阻带 %.1f dB，过渡带 %.3fπ；表 7.2.2：%d dB',stopAtt(1),transW(1),tableAtt(1));[frames,lastFrame]=holdFrames(f,writer,frames,30+39);
 for i=2:6
  for mix=linspace(0,1,36)
   v=(1-mix)*W(i-1,:)+mix*W(i,:);[db,att,tw]=currentWindow(hd.*v,w,wc);set(wv,'YData',v);set(hv,'YData',db);
   info.String=sprintf('%s → %s：阻带 %.1f dB，过渡带 %.3fπ',wnames{i-1},wnames{i},att,tw);cap.String='降低旁瓣通常需要更宽的主瓣；不同窗的过渡带宽并非逐个单调。';[frames,lastFrame]=holdFrames(f,writer,frames,1);
  end
  info.String=sprintf('%s：阻带 %.1f dB，过渡带 %.3fπ；表 7.2.2：%d dB',wnames{i},stopAtt(i),transW(i),tableAtt(i));[frames,lastFrame]=holdFrames(f,writer,frames,39);
 end
 cap.String=sprintf('矩形 → 凯塞：阻带 %.0f → %.0f dB，过渡带 %.2fπ → %.2fπ；体现旁瓣与主瓣的取舍。',stopAtt(1),stopAtt(6),transW(1),transW(6));[frames,lastFrame]=holdFrames(f,writer,frames,36);
 [cap,info]=scene(f,'② 设计步骤：例 7.13','先按阻带最小衰减选窗，再按过渡带宽度定 N，最后实测。');
 steps=annotation(f,'textbox',[.055 .29 .41 .4],'String',{'① 指标：ω_p=0.3π，ω_s=0.5π','    阻带最小衰减 A_s=40 dB'},'FontSize',18,'EdgeColor','none','Interpreter','tex');
 a=panel(f,[.56 .29 .39 .4]);xlabel(a,'n');ylabel(a,'h(n)');xlim(a,[-1 N13]);ylim(a,[-.12 .43]);[frames,lastFrame]=holdFrames(f,writer,frames,30);
 selected=find(tableAtt>=40,1);assert(selected==3);steps.String={'① 指标：0.3π / 0.5π，40 dB','② 首个满足的窗：汉宁 44 dB','③ N=ceil(6.6π/Δω)+1，取奇数 35'};
 hd13=ideal_lp((.3*pi+.5*pi)/2,(N13-1)/2,0:N13-1);st=stem(a,0:N13-1,hd13,'filled','Color',[.55 .55 .55],'MarkerSize',4);info.String='先画理想低通 h_d(n) 的 35 个样本';[frames,lastFrame]=holdFrames(f,writer,frames,90);
 steps.String={'① 指标：0.3π / 0.5π，40 dB','② 选汉宁窗：表中 44 dB','③ 按过渡带定 N，取奇数 35','④ ω_c=(ω_p+ω_s)/2=0.4π','    h(n)=h_d(n)·w(n)'};
 for mix=linspace(0,1,60),set(st,'YData',(1-mix)*hd13+mix*h13,'Color',blue);info.String='乘窗：两端样本向零缩短';[frames,lastFrame]=holdFrames(f,writer,frames,1);end
 [frames,lastFrame]=holdFrames(f,writer,frames,30);
 cla(a);plot(a,[.5 1],[-40 -40],'r-','LineWidth',2);xlim(a,[0 1]);ylim(a,[-100 5]);xlabel(a,'ω/π');ylabel(a,'dB');curve=plot(a,NaN,NaN,'Color',blue,'LineWidth',1.5);
 for k=1:90,j=ceil(k*numel(w)/90);set(curve,'XData',w(1:j)/pi,'YData',H13(1:j));[frames,lastFrame]=holdFrames(f,writer,frames,1);end
 % 原 measure 的 att13 是整个阻带的最小衰减，沿用参考字段名而不误作单点。
 text(a,.52,-32,sprintf('阻带最小 %.1f dB',att13),'Color',blue,'FontSize',13);info.String=sprintf('ω≥ω_s：最小衰减 %.2f dB；通带起伏 %.4f dB',att13,rip13);cap.String=sprintf('汉宁窗，N=%d：阻带最小衰减 %.1f dB ≥ 40 dB；通带起伏 %.2f dB。',N13,att13,rip13);[frames,lastFrame]=holdFrames(f,writer,frames,60);
 [cap,info]=scene(f,'③ 不达标就加 N：例 7.16','fs=250 Hz，阻带 40—60 Hz，要求阻带最小衰减 50 dB。');
 a=panel(f,[.10 .28 .83 .43]);plot(a,[40 60],[-50 -50],'r-','LineWidth',2);xlim(a,[0 fs16/2]);ylim(a,[-100 5]);xlabel(a,'频率 (Hz)');ylabel(a,'dB');curve=plot(a,w/(2*pi)*fs16,H16,'Color',[.6 .6 .6],'LineWidth',1.5);[frames,lastFrame]=holdFrames(f,writer,frames,30);
 set(curve,'Color',[.7 0 0]);info.String=sprintf('汉明 N=%d：%.1f dB < 50 dB，不达标',N16,att16);info.Color=[.7 0 0];cap.String='先暂停：设计公式为什么只是估计？';[frames,lastFrame]=holdFrames(f,writer,frames,90);
 plot(a,w/(2*pi)*fs16,H16fixed,'Color',blue,'LineWidth',1.5);info.String=sprintf('增至 N=%d：%.1f dB ≥ 50 dB，达标',N16fix,att16fix);info.Color=blue;legend(a,{'50 dB 要求',sprintf('N=%d',N16),sprintf('N=%d',N16fix)},'Location','southoutside','Orientation','horizontal','AutoUpdate','off');[frames,lastFrame]=holdFrames(f,writer,frames,90);
 cap.String=sprintf('教材参数差 %.1f dB：设计公式是估计，最后要按实测定 N。',50-att16);[frames,lastFrame]=holdFrames(f,writer,frames,30);
 [cap,info]=scene(f,'④ 定格：窗的取舍与设计结果','沿用页面静态图③的数据；右图只保留例 7.13，不加入例 7.14。');
 a=panel(f,[.08 .31 .38 .39]);plot(a,w/pi,HdB.','LineWidth',1);xlim(a,[0 1]);ylim(a,[-120 5]);xlabel(a,'ω/π');ylabel(a,'dB');legend(a,wnames,'Location','southoutside','NumColumns',3,'FontSize',10,'AutoUpdate','off');
 a=panel(f,[.57 .31 .37 .39]);plot(a,w/pi,H13,'Color',blue,'LineWidth',1.6);plot(a,[.5 1],[-40 -40],'r-','LineWidth',2);xlim(a,[0 1]);ylim(a,[-100 5]);xlabel(a,'ω/π');ylabel(a,'dB');legend(a,{'例 7.13','40 dB 要求'},'Location','southoutside','Orientation','horizontal','AutoUpdate','off');
 cap.String={sprintf('③ 同一低通加六种窗：阻带 %.0f/%.0f/%.0f/%.0f/%.0f/%.0f dB',stopAtt),sprintf('④ 例 7.13：汉宁 N=%d，阻带最小衰减 %.1f dB',N13,att13)};[frames,lastFrame]=holdFrames(f,writer,frames,120);close(writer);
 catch failure,close(writer);rethrow(failure);end
 fileInfo=dir(moviePath);if fileInfo.bytes<8e6,break;end
end
assert(frames==1200 && fileInfo.bytes<8e6);checkValues(metrics,outdir);imwrite(lastFrame.cdata,fullfile(mediaDir,'7.4-windows-design-poster.png'));
metrics.frames=frames;metrics.fps=30;metrics.duration_s=40;metrics.width=1280;metrics.height=720;metrics.quality=quality;metrics.file_size_bytes=fileInfo.bytes;metrics.all_checks_passed=true;metrics.matlab_version=version;metrics.generated_at=char(datetime('now','Format','yyyy-MM-dd HH:mm:ss'));
fid=fopen(fullfile(outdir,'verification-video-windows-design.json'),'w','n','UTF-8');assert(fid>=0);fprintf(fid,'%s\n',jsonencode(metrics,PrettyPrint=true));fclose(fid);disp(metrics);

function checkValues(m,outdir)
r=jsondecode(fileread(fullfile(outdir,'verification-windows-design.json')));names=fieldnames(m);for j=1:numel(names),assert(all(abs(m.(names{j})(:)-r.(names{j})(:))<1e-10));end
assert(all(abs(m.window_sidelobe_dB-r.window_sidelobe_dB(:).')<.1));assert(all(abs(m.lowpass_stop_att_dB-r.lowpass_stop_att_dB(:).')<.1));assert(all(abs(m.lowpass_transition_over_pi-r.lowpass_transition_over_pi(:).')<1e-3));
assert(m.ex713_N==35 && abs(m.ex713_att_ws_dB-43.94)<.01 && abs(m.ex713_pass_ripple_dB-.0713)<1e-3);assert(m.ex716_N==43 && abs(m.ex716_att_dB-47.46)<.01 && m.ex716_N_needed_for_50dB==45 && abs(m.ex716_att_dB_fixed-52.55)<.01);
end
function [db,att,tw]=currentWindow(h,w,wc)
Hf=abs(polyval(fliplr(h),exp(-1i*w)));db=20*log10(Hf/max(Hf));[~,lm]=local_maxima(-Hf);i1=lm(find(w(lm)>wc,1));att=-max(db(w>w(i1)));tw=(w(find(Hf<10^(-att/20),1))-w(find(Hf<1-10^(-att/20),1)))/pi;
end
function [cap,info]=scene(f,heading,note)
clf(f);annotation(f,'textbox',[.055 .90 .92 .07],'String',heading,'FontSize',24,'FontWeight','bold','EdgeColor','none','Interpreter','none');annotation(f,'textbox',[.055 .82 .92 .065],'String',note,'FontSize',15,'EdgeColor','none','Interpreter','tex');
info=annotation(f,'textbox',[.055 .745 .90 .07],'String','','FontSize',14,'HorizontalAlignment','right','EdgeColor','none','Interpreter','tex');cap=annotation(f,'textbox',[.055 .025 .92 .11],'String','','FontSize',16,'Color',[0 .36 .62],'EdgeColor','none','Interpreter','tex');
end
function ax=panel(f,position)
ax=axes(f,'Position',position);hold(ax,'on');grid(ax,'on');ax.FontSize=14;ax.Toolbar.Visible='off';
end

function wv = win(kind, N, beta)
n = 0:N-1; M = N - 1;
switch kind
    case 'rect',     wv = ones(1, N);
    case 'triang',   wv = 1 - abs(2*n - M)/M;                                   % 三角（巴特利特）窗
    case 'hann',     wv = 0.5 - 0.5*cos(2*pi*n/M);
    case 'hamming',  wv = 0.54 - 0.46*cos(2*pi*n/M);
    case 'blackman', wv = 0.42 - 0.5*cos(2*pi*n/M) + 0.08*cos(4*pi*n/M);
    case 'kaiser',   wv = besseli(0, beta*sqrt(1 - (2*n/M - 1).^2))/besseli(0, beta);   % 教材式 (7.2.10)
end
end

function h = ideal_lp(wc, alpha, n)
h = zeros(size(n)); i = abs(n - alpha) > 1e-12;
h(i) = sin(wc*(n(i) - alpha))./(pi*(n(i) - alpha)); h(~i) = wc/pi;
end

function N = choose_N(Bt, factor)
N = ceil(factor*pi/Bt) + 1; if mod(N, 2) == 0, N = N + 1; end                  % 与教材 Python 代码一致：取奇数
end

function [h, N] = design_lp(wp, ws, kind, factor)
N = choose_N(abs(ws - wp), factor); alpha = (N - 1)/2; wc = (wp + ws)/2;
h = ideal_lp(wc, alpha, 0:N-1).*win(kind, N);
end

function [h, N] = design_bs(wp1, wp2, ws1, ws2, kind, factor)
N = choose_N(min(abs(wp1 - ws1), abs(wp2 - ws2)), factor); alpha = (N - 1)/2; n = 0:N-1;
w1 = (wp1 + ws1)/2; w2 = (wp2 + ws2)/2;
hd = -(ideal_lp(w2, alpha, n) - ideal_lp(w1, alpha, n)); hd(n == alpha) = 1 - (w2 - w1)/pi;   % 全通 − 带通
h = hd.*win(kind, N);
end

function [att, rip] = measure(h, w, wp, ws, kind)
% 阻带最小衰减（dB）与通带最大起伏（dB）
Hf = abs(polyval(fliplr(h), exp(-1i*w)));
switch kind
    case 'lp', sb = w >= ws; pb = w <= wp;
    case 'hp', sb = w <= ws; pb = w >= wp;
    case 'bp', sb = w <= ws(1) | w >= ws(2); pb = w >= wp(1) & w <= wp(2);
    case 'bs', sb = w >= ws(1) & w <= ws(2); pb = w <= wp(1) | w >= wp(2);
end
att = -20*log10(max(Hf(sb))); rip = 20*log10(max(Hf(pb))) - 20*log10(min(Hf(pb)));
end

function [pk, loc] = local_maxima(x)
loc = find(x(2:end-1) > x(1:end-2) & x(2:end-1) >= x(3:end)) + 1; pk = x(loc);
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
