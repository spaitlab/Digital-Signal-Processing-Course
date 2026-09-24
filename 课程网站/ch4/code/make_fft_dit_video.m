%% 4.2 独立 DIT 动画；定义和两个 FFT 函数逐字来自 demo_fft_cost.m
clearvars;
Nlist = 2.^(3:14);
md = Nlist.^2;                                     % 直接计算 DFT 的复乘数
mF = Nlist/2 .* log2(Nlist);                       % 按时间抽取 FFT 的复乘数
ratio = md ./ mF;

N8 = 8; x8 = (1:8);                                % 教材图 4.2.5 的 N=8 例子
[X8, stages8, order8] = fft_dit(x8);               % stages8 每一行是一级蝶形之后的中间结果

rng(20260919);
xTest = randn(1, 1024) + 1i*randn(1, 1024);
errDIT = max(abs(fft_dit(xTest) - fft(xTest)));
bitrev = order8 - 1;
metrics=struct('N_list',Nlist,'direct_mults',md,'fft_mults',mF,'ratio',ratio, ...
'bitreversal_N8',bitrev,'X8_abs',abs(X8),'stage_abs',abs(stages8), ...
'dit_vs_fft_max_err_N8',max(abs(X8-fft(x8))),'dit_vs_fft_max_err_1024',errDIT,'random_seed',20260919);
codeDir=fileparts(mfilename('fullpath'));mediaDir=fullfile(codeDir,'..','media');if ~exist(mediaDir,'dir'),mkdir(mediaDir);end
checkValues(metrics,codeDir);
moviePath=fullfile(mediaDir,'4.2-fft-dit.mp4');
f=figure('Color','w','Position',[30 30 1280 720],'MenuBar','none','ToolBar','none','Visible','off');cleanup=onCleanup(@() delete(f(isgraphics(f))));
blue=[0 .36 .62];red=[.85 .25 .1];gray=[.75 .75 .75];
for quality=[90 75]
 writer=VideoWriter(moviePath,'MPEG-4');writer.FrameRate=30;writer.Quality=quality;open(writer);frames=0;
 try
 [ax,cap,info]=scene(f,'① 奇偶分开，分到不能再分','按每组内的序号奇偶拆分；下方显示三位二进制的反转。');
 ax.Position=[.06 .2 .90 .55];axis(ax,[0 9 -.5 4.5]);axis(ax,'off');
 xs=1:8;rects=gobjects(1,8);texts=gobjects(1,8);bits=gobjects(1,8);
 for n=0:7
  rectangle(ax,'Position',[xs(n+1)-.38 3.4 .76 .65],'FaceColor',[.94 .96 .98],'EdgeColor',gray);
  text(ax,xs(n+1),3.72,sprintf('x(%d)\n值 %d',n,n+1),'HorizontalAlignment','center','FontSize',14);
  rects(n+1)=rectangle(ax,'Position',[xs(n+1)-.38 1.8 .76 .65],'FaceColor',[.86 .93 .98],'EdgeColor',blue,'LineWidth',1.4);
  texts(n+1)=text(ax,xs(n+1),2.12,sprintf('x(%d) = %d',n,n+1),'HorizontalAlignment','center','FontSize',13);
  bits(n+1)=text(ax,xs(n+1),1.62,'','HorizontalAlignment','center','FontSize',12,'FontName','Consolas');
 end
 text(ax,.3,4.35,'原始输入','FontSize',14);info.String='n=0…7，输入值 1…8';[frames,lastFrame]=holdFrames(f,writer,frames,30);
 orders={[0 2 4 6 1 3 5 7],[0 4 2 6 1 5 3 7],[0 4 2 6 1 5 3 7]};previous=0:7;
 for level=1:3
  target=orders{level};assert(isequal(sort(target),0:7));
  oldpos=zeros(1,8);newpos=zeros(1,8);
  for n=0:7,oldpos(n+1)=find(previous==n);newpos(n+1)=find(target==n);end
  groupLength=8/2^level;
  for a=linspace(0,1,45)
   for n=0:7
    pos=(1-a)*oldpos(n+1)+a*newpos(n+1);yy=1.8-.28*(level-1)-.28*a+.85*sin(pi*a)*sign(newpos(n+1)-oldpos(n+1));
    set(rects(n+1),'Position',[pos-.38 yy .76 .65]);set(texts(n+1),'Position',[pos yy+.32 0]);
    raw=dec2bin(n,3);set(bits(n+1),'Position',[pos yy-.18 0],'String',sprintf('%s → %s',raw,fliplr(raw)));
   end
   info.String=sprintf('第 %d 次拆分：%d 组，每组 %d 点',level,2^level,groupLength);
   [frames,lastFrame]=holdFrames(f,writer,frames,1);
  end
  % 分组边界在各层到位后画出；最后一次两点拆成单点，顺序不再改变。
  groupMarks=gobjects(0);
  for edge=groupLength:groupLength:7,groupMarks(end+1)=plot(ax,[edge+.5 edge+.5],[1.4-.28*level 2.55-.28*level],':','Color',gray,'LineWidth',1.3);end
  [frames,lastFrame]=holdFrames(f,writer,frames,15);delete(groupMarks);previous=target;
 end
 assert(isequal(previous,bitrev));cap.String='分三次，顺序变成 0 4 2 6 1 5 3 7：就是位反转。';[frames,lastFrame]=holdFrames(f,writer,frames,90);
 [ax,cap,info]=scene(f,'② 三级蝶形，原位计算','每级 4 个蝶形；先乘旋转因子，再一加一减。节点只显示幅值。');
 ax.Position=[.05 .18 .91 .56];axis(ax,[-.4 10.5 .35 9.15]);axis(ax,'off');xx=[.8 3.6 6.4 9.2];yy=8:-1:1;
 node=gobjects(4,8);values=gobjects(4,8);edges=cell(3,4);factors=gobjects(3,4);pairs=cell(3,4);
 for stage=1:3
  L=2^stage;half=L/2;b=0;
  for start=1:L:8
   for k=0:half-1
    b=b+1;u=start+k;v=u+half;pairs{stage,b}=[u v];x0=xx(stage);x1=xx(stage+1);
    edges{stage,b}=[plot(ax,[x0+.12 x1-.10],[yy(u) yy(u)],'Color',gray),plot(ax,[x0+.12 x1-.10],[yy(u) yy(v)],'Color',gray), ...
     plot(ax,[x0+.12 x0+.70 x1-.10],[yy(v) yy(v) yy(u)],'Color',gray),plot(ax,[x0+.12 x1-.10],[yy(v) yy(v)],'Color',gray)];
    factors(stage,b)=text(ax,x0+.78,yy(v)+.14,sprintf('W_{%d}^{%d}',L,k),'FontSize',12,'Color',gray,'BackgroundColor','w','Margin',1);
   end
  end
 end
 for col=1:4
  if col==1,label='位反转输入';else,label=sprintf('第 %d 级后',col-1);end
  text(ax,xx(col),8.85,label,'HorizontalAlignment','center','FontSize',15,'FontWeight','bold');
  for n=1:8
   node(col,n)=plot(ax,xx(col),yy(n),'o','Color',gray,'MarkerFaceColor','w','MarkerSize',6);
   values(col,n)=text(ax,xx(col)+.13,yy(n), '—','FontSize',12,'Color',gray,'BackgroundColor','w','Margin',1);
   if col==1,set(node(col,n),'Color',blue,'MarkerFaceColor',blue);set(values(col,n),'String',sprintf('%.2f',abs(stages8(col,n))),'Color',blue);text(ax,xx(col)-.28,yy(n),sprintf('x(%d)',bitrev(n)),'HorizontalAlignment','right','FontSize',11);end
  end
 end
 cap.String='原位：每个蝶形的两个输出，覆盖对应的两个输入存储单元。';
 [frames,lastFrame]=holdFrames(f,writer,frames,30);
 for stage=1:3
  for b=1:4
   set(edges{stage,b},'Color',red,'LineWidth',2);set(factors(stage,b),'Color',red,'FontWeight','bold');
   pair=pairs{stage,b};
   for n=pair,set(node(stage+1,n),'Color',red,'MarkerFaceColor',red);set(values(stage+1,n),'String',sprintf('%.2f',abs(stages8(stage+1,n))),'Color',red);end
   info.String=sprintf('第 %d 级，第 %d 个蝶形；位置 %d 与 %d；上端相加，下端相减',stage,b,pair(1)-1,pair(2)-1);
   [frames,lastFrame]=holdFrames(f,writer,frames,24);
   set(edges{stage,b},'Color',blue,'LineWidth',1);set(factors(stage,b),'Color',blue,'FontWeight','normal');
   set(node(stage+1,pair),'Color',blue,'MarkerFaceColor',blue);set(values(stage+1,pair),'Color',blue);
  end
  info.String=sprintf('第 %d 级完成；同一组 8 个存储单元已更新',stage);[frames,lastFrame]=holdFrames(f,writer,frames,24);
 end
 cap.String='3 级 × 4 个蝶形 = 12 次复乘，直接算要 64 次（统一计数，未扣除特殊因子）。';
 [frames,lastFrame]=holdFrames(f,writer,frames,150);
 [ax,cap,info]=scene(f,'③ 输出就是 X(k)','从信号流图最右列读出幅值；k 按自然顺序 0…7 排列。');
 xlim(ax,[-.5 7.5]);ylim(ax,[0 40]);xlabel(ax,'输出索引 k');ylabel(ax,'|X(k)|');
 stem(ax,0:7,abs(X8),'filled','Color',blue,'MarkerSize',5);plot(ax,0:7,abs(fft(x8)),'o','Color',gray,'MarkerSize',12,'LineWidth',1.7);
 text(ax,0:7,abs(X8)+1.7,compose('%.2f',abs(X8)),'HorizontalAlignment','center','FontSize',13);
 legend(ax,{'自写 DIT','fft(1:8) 空心圈'},'Location','southoutside','Orientation','horizontal','AutoUpdate','off');
 info.String=sprintf('与 fft 的最大差 %.2g < 10^{-12}',metrics.dit_vs_fft_max_err_N8);cap.String='输出是自然顺序，不用再排。';[frames,lastFrame]=holdFrames(f,writer,frames,180);
 [ax,cap,info]=scene(f,'④ 算得动：比较复乘次数','教材统一计数；旋转因子为 1 等特例未扣除，不是本机实测耗时。');
 set(ax,'XScale','log','YScale','log');xlim(ax,[8 16384]);ylim(ax,[8 1e9]);xlabel(ax,'N');ylabel(ax,'复乘次数');
 direct=plot(ax,NaN,NaN,'-o','Color',red,'LineWidth',2);fast=plot(ax,NaN,NaN,'-s','Color',blue,'LineWidth',2);
 legend(ax,{'直接计算 N^2','DIT：(N/2) log_2 N'},'Location','northwest','AutoUpdate','off');
 [frames,lastFrame]=holdFrames(f,writer,frames,30);
 for j=1:numel(Nlist)
  set(direct,'XData',Nlist(1:j),'YData',md(1:j));set(fast,'XData',Nlist(1:j),'YData',mF(1:j));
  info.String=sprintf('N=%d：%.0f 次 vs %.0f 次；比值 %.1f',Nlist(j),md(j),mF(j),ratio(j));
  [frames,lastFrame]=holdFrames(f,writer,frames,10);
  if Nlist(j)==2048
   xline(ax,2048,':','Color',gray);text(ax,2048,3e6,'约 372 倍','FontSize',16,'Color',blue,'HorizontalAlignment','right','BackgroundColor','w');
   cap.String='N=2048：4,194,304 次 vs 11,264 次。';[frames,lastFrame]=holdFrames(f,writer,frames,60);
  end
 end
 cap.String='N=2048：4,194,304 次 vs 11,264 次；点数越大，优势越明显。';[frames,lastFrame]=holdFrames(f,writer,frames,30);assert(frames==1260);
 close(writer);
 catch failure,close(writer);rethrow(failure);end
 fileInfo=dir(moviePath);if fileInfo.bytes<8e6,break;end
end
assert(fileInfo.bytes<8e6);checkValues(metrics,codeDir);
imwrite(lastFrame.cdata,fullfile(mediaDir,'4.2-fft-dit-poster.png'));
metrics.frames=frames;metrics.frame_rate=30;metrics.duration_s=frames/30;metrics.width=1280;metrics.height=720;metrics.quality=quality;metrics.file_size_bytes=fileInfo.bytes;metrics.all_checks_passed=true;
metrics.matlab_version=version;metrics.generated_at=char(datetime('now','Format','yyyy-MM-dd HH:mm:ss'));
fid=fopen(fullfile(codeDir,'results','verification-video-fft-dit.json'),'w','n','UTF-8');assert(fid>=0);fprintf(fid,'%s\n',jsonencode(metrics,PrettyPrint=true));fclose(fid);disp(metrics);

function checkValues(m,codeDir)
s=jsondecode(fileread(fullfile(codeDir,'results','verification-fft-cost.json')));
assert(isequal(m.bitreversal_N8,[0 4 2 6 1 5 3 7]));assert(m.dit_vs_fft_max_err_N8<1e-12);assert(m.dit_vs_fft_max_err_1024<1e-9);
assert(isequal(size(m.stage_abs),[4 8]));assert(max(abs(m.X8_abs(:)-s.X8_abs(:)))<1e-9);
names={'N_list','direct_mults','fft_mults','ratio','bitreversal_N8','X8_abs'};
for j=1:numel(names),assert(all(abs(m.(names{j})(:)-s.(names{j})(:))<1e-10));end
end
function [ax,cap,info]=scene(f,titleText,note)
clf(f);ax=axes(f,'Position',[.09 .22 .86 .51]);hold(ax,'on');grid(ax,'on');ax.FontSize=15;ax.Toolbar.Visible='off';
annotation(f,'textbox',[.07 .89 .92 .065],'String',titleText,'FontSize',24,'FontWeight','bold','EdgeColor','none','Interpreter','none');
annotation(f,'textbox',[.07 .81 .92 .06],'String',note,'FontSize',16,'EdgeColor','none','Interpreter','none');
cap=annotation(f,'textbox',[.07 .02 .92 .075],'String','','FontSize',16,'Color',[0 .36 .62],'EdgeColor','none','Interpreter','none');
info=annotation(f,'textbox',[.07 .745 .91 .05],'String','','FontSize',15,'HorizontalAlignment','right','EdgeColor','none','Interpreter','tex');
end

function [X, stages, order] = fft_dit(x)
% 按时间抽取的基-2 FFT（教材 4.2）：位反转重排 + v 级原位蝶形。返回每级之后的中间结果。
x = x(:).'; N = numel(x); v = log2(N); assert(v == round(v), 'N 必须是 2 的幂');
order = bitrevorder_basic(N);                      % 位反转顺序（1 起）
X = x(order); stages = zeros(v + 1, N); stages(1, :) = X;
for s = 1:v                                        % 第 s 级：蝶形跨度 L = 2^s
    L = 2^s; half = L/2; W = exp(-2i*pi*(0:half-1)/L);
    for start = 1:L:N
        for k = 0:half-1
            a = X(start + k); b = W(k+1) * X(start + k + half);   % DIT：先乘旋转因子
            X(start + k) = a + b; X(start + k + half) = a - b;
        end
    end
    stages(s + 1, :) = X;
end
end

function order = bitrevorder_basic(N)
v = log2(N); order = zeros(1, N);
for n = 0:N-1
    r = 0; m = n;
    for b = 1:v, r = r*2 + mod(m, 2); m = floor(m/2); end
    order(n+1) = r + 1;
end
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
