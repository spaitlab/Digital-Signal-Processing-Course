%% 1.2 本地课堂动画；运行前先核验，基础 MATLAB，无工具箱依赖
clearvars;
% 以下信号定义逐字取自 demo_dsp_chain.m（含采样、量化、平均、保持和平滑）。
fs = 100; T = 1/fs; dur = 2;
xa = @(t) sin(2*pi*2*t) + 0.5*sin(2*pi*15*t);   % 教材图 1.2.1 里的 x_a(t)
tc = 0:1e-4:dur;                                 % 很密的时间网格，代表“连续”
n = 0:dur*fs; t = n*T;                           % 采样时刻 t = nT
x = xa(t);                                       % 采样：离散时间、连续幅值

%% 演示2：量化——幅值也变成有限个数码
full = 2;                                        % 量化范围 ±2（信号峰值 1.5，不削顶）
quantize = @(v, bits) max(-full, min(full - 2*full/2^bits, round(v/(2*full)*2^bits)/2^bits*2*full));
x3 = quantize(x, 3);                             % 3 位：8 个电平，误差明显
x8 = quantize(x, 8);                             % 8 位：256 个电平
step3 = 2*full/2^3; step8 = 2*full/2^8;

%% 演示3：数字处理——把相邻 5 个数取平均（这就是一个“系统”）
M = 5; b = ones(1, M)/M;
y = filter(b, 1, x8);                            % 输入 8 位数字信号，输出数字信号

%% 演示4：D/A 变换——零阶保持，再平滑
tzoh = tc; yzoh = interp1(t, y, tc, 'previous', 'extrap');   % 零阶保持：每个样本保持一个采样周期
smoothLen = round(0.02/1e-4);                    % 平滑滤波：20 ms 窗的滑动平均（近似模拟平滑滤波器）
ysmooth = filter(ones(1, smoothLen)/smoothLen, 1, yzoh);


codeDir = fileparts(mfilename('fullpath'));
mediaDir = fullfile(codeDir, '..', 'media');
if ~exist(mediaDir,'dir'), mkdir(mediaDir); end
qerr3 = max(abs(x-x3)); qerr8 = max(abs(x-x8));
idx = n >= M-1; tt = t(idx);
A = [sin(2*pi*2*tt)', cos(2*pi*2*tt)', sin(2*pi*15*tt)', cos(2*pi*15*tt)', ones(numel(tt),1)];
c = A \ y(idx)'; amp2 = hypot(c(1),c(2)); amp15 = hypot(c(3),c(4));
values = [qerr3 qerr8 amp2 amp15];
checkValues(values,codeDir); % 必须在创建视频前通过
moviePath = fullfile(mediaDir,'1.2-dsp-chain.mp4');
posterPath = fullfile(mediaDir,'1.2-dsp-chain-poster.png');
f = figure('Color','w','Position',[30 30 1280 720],'MenuBar','none','ToolBar','none','Visible','off');
cleanup = onCleanup(@() delete(f(isgraphics(f))));
blue = [0 .36 .62]; orange = [.85 .33 .1]; gray = [.65 .65 .65];
% 未设置字体覆盖，沿用 demo_dsp_chain.m / MATLAB 的默认中文字体。
for quality = [90 75]
    writer = VideoWriter(moviePath,'MPEG-4'); writer.FrameRate=30; writer.Quality=quality; open(writer);
    frames = 0;
    try
        for segment = 1:4
            clf(f);
            ax = axes(f,'Position',[.09 .16 .86 .61]); hold(ax,'on'); grid(ax,'on');
            xlim(ax,[0 1]); ylim(ax,[-2.1 1.8]); xlabel(ax,'时间 t (s)'); ylabel(ax,'幅度'); ax.FontSize=15; ax.Toolbar.Visible='off';
            titles = {'① 采样','② A/D 量化','③ 数字处理：相邻 5 个数取平均','④ D/A 与平滑'};
            notes = {'采样得到离散时间信号；采样率 100 Hz。预处理位于采样前，本动画从采样开始。', ...
                '量化把幅值变成有限个数码；3 位共 8 个电平。', ...
                '相邻 5 个数取平均：快变的 15 Hz 干扰压低，慢变的 2 Hz 基本保留。', ...
                '每个样本保持一个采样周期；再用 20 ms 平均近似模拟平滑滤波器。'};
            annotation(f,'textbox',[.07 .87 .9 .08],'String',titles{segment},'EdgeColor','none','FontSize',25,'FontWeight','bold','Interpreter','none');
            annotation(f,'textbox',[.07 .79 .92 .07],'String',notes{segment},'EdgeColor','none','FontSize',16,'Interpreter','none');
            caption = annotation(f,'textbox',[.09 .03 .86 .07],'String','','EdgeColor','none','FontSize',18,'Color',blue,'Interpreter','none');
            switch segment
                case 1
                    plot(ax,tc,xa(tc),'Color',gray,'LineWidth',1.2);
                    a=stem(ax,NaN,NaN,'filled','Color',blue,'MarkerSize',4);
                    legend(ax,{'模拟信号：2 Hz + 0.5 × 15 Hz','采样点'},'Location','southoutside','Orientation','horizontal');
                    [frames,lastFrame]=holdFrames(f,writer,frames,30);
                    for k=1:101
                        set(a,'XData',t(1:k),'YData',x(1:k));
                        [frames,lastFrame]=holdFrames(f,writer,frames,2);
                    end
                    caption.String='时间变成离散的采样时刻，幅值还没有量化。';
                    [frames,lastFrame]=holdFrames(f,writer,frames,8); % 8 s
                case 2
                    xlim(ax,[0 .5]); yline(ax,(-4:3)*step3,'--','Color',orange);
                    raw=plot(ax,t(1:51),x(1:51),'.','Color',gray,'MarkerSize',12);
                    a=stem(ax,NaN,NaN,'filled','Color',orange,'MarkerSize',5);
                    legend(ax,[raw a],{'量化前的采样值','3 位量化值（虚线为 8 个电平）'},'Location','southoutside','Orientation','horizontal','AutoUpdate','off');
                    moving=plot(ax,NaN,NaN,'o','Color',blue,'MarkerFaceColor',blue,'MarkerSize',7);
                    err=text(ax,.49,1.65,'当前最大误差：0.000','HorizontalAlignment','right','FontSize',15);
                    [frames,lastFrame]=holdFrames(f,writer,frames,30);
                    for k=1:51
                        for snap=1:3
                            set(moving,'XData',t(k),'YData',x(k)+(x3(k)-x(k))*snap/3);
                            [frames,lastFrame]=holdFrames(f,writer,frames,1);
                        end
                        set(a,'XData',t(1:k),'YData',x3(1:k));
                        err.String=sprintf('当前最大误差：%.3f',max(abs(x(1:k)-x3(1:k))));
                        [frames,lastFrame]=holdFrames(f,writer,frames,1);
                    end
                    moving.Visible='off'; caption.String='台阶 0.5，最大误差 0.246（全段核验）；8 位误差约 0.0075。';
                    [frames,lastFrame]=holdFrames(f,writer,frames,66); % 10 s
                case 3
                    stem(ax,t(1:101),x8(1:101),'Color',gray,'MarkerSize',3);
                    window=patch(ax,[-.045 .005 .005 -.045],[-2.1 -2.1 1.8 1.8],blue,'FaceAlpha',.12,'EdgeColor','none');
                    a=stem(ax,NaN,NaN,'filled','Color',blue,'MarkerSize',4);
                    legend(ax,{'8 位数字输入','当前 5 个样本（起始不足处补零）','平均后的数字输出'},'Location','southoutside','Orientation','horizontal');
                    [frames,lastFrame]=holdFrames(f,writer,frames,30);
                    for k=1:101
                        set(window,'XData',[t(k)-.045 t(k)+.005 t(k)+.005 t(k)-.045]);
                        set(a,'XData',t(1:k),'YData',y(1:k));
                        [frames,lastFrame]=holdFrames(f,writer,frames,2);
                    end
                    caption.String='15 Hz：0.5 → 0.156；2 Hz：1 → 0.985（稳态拟合，课堂近似值）';
                    [frames,lastFrame]=holdFrames(f,writer,frames,68); % 10 s
                case 4
                    a=stairs(ax,NaN,NaN,'Color',gray,'LineWidth',1.6);
                    bline=plot(ax,NaN,NaN,'Color',blue,'LineWidth',2);
                    ref=plot(ax,NaN,NaN,'k--','LineWidth',1.2);
                    legend(ax,{'零阶保持','20 ms 平滑输出','原来的 2 Hz 参考'},'Location','southoutside','Orientation','horizontal');
                    [frames,lastFrame]=holdFrames(f,writer,frames,30);
                    for k=1:60
                        last=min(10001,round(k/60*10001));
                        set(a,'XData',tc(1:last),'YData',yzoh(1:last));
                        [frames,lastFrame]=holdFrames(f,writer,frames,1);
                    end
                    for k=1:90
                        last=min(10001,round(k/90*10001));
                        set(bline,'XData',tc(1:last),'YData',ysmooth(1:last));
                        [frames,lastFrame]=holdFrames(f,writer,frames,1);
                    end
                    set(ref,'XData',tc(1:10001),'YData',sin(2*pi*2*tc(1:10001)));
                    caption.String='输出变平滑，也会延迟；黑色虚线仅作原始 2 Hz 成分的参考。';
                    [frames,lastFrame]=holdFrames(f,writer,frames,60); % 8 s，末尾 2 s 定格
            end
            fprintf('完成第 %d 段，累计 %d 帧\n',segment,frames);
        end
        close(writer);
    catch failure
        close(writer);
        rethrow(failure);
    end
    info=dir(moviePath);
    if info.bytes < 8e6, break; end
end
assert(info.bytes<8e6,'视频仍超过 8 MB，请进一步简化画面');
imwrite(lastFrame.cdata,posterPath);
checkValues(values,codeDir); % 末尾复核，与原演示和 verification.json 一致
metrics=struct('matlab_version',version,'generated_at',char(datetime('now','Format','yyyy-MM-dd HH:mm:ss')), ...
    'frames',frames,'frame_rate',30,'duration_s',frames/30,'width',1280,'height',720,'quality',quality, ...
    'file_size_bytes',info.bytes,'quant_err_max_3bit',qerr3,'quant_err_max_8bit',qerr8, ...
    'amp_2Hz_fitted',amp2,'amp_15Hz_fitted',amp15,'all_checks_passed',true);
fid=fopen(fullfile(codeDir,'results','verification-video.json'),'w','n','UTF-8');
assert(fid>=0,'无法写入核验记录'); fprintf(fid,'%s\n',jsonencode(metrics,PrettyPrint=true)); fclose(fid);
disp(metrics);

function checkValues(values,codeDir)
expected=[.2460 .0075 .985 .156]; tolerance=[1e-3 1e-3 .01 .01];
assert(all(abs(values-expected)<tolerance),'动画数值不符合课堂核验值');
saved=jsondecode(fileread(fullfile(codeDir,'results','verification.json')));
reference=[saved.quant_err_max_3bit saved.quant_err_max_8bit saved.amp_2Hz_fitted saved.amp_15Hz_fitted];
assert(all(abs(values-reference)<1e-10),'动画数值与原演示 verification.json 不一致');
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
