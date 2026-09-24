%% 1.3 自制动画：只用基础 MATLAB，独立于 Live Script 构建
clearvars;
% 以下定义块逐字取自 demo_digital_advantages.m
fs = 100; n = 0:199; t = n/fs;
x = sin(2*pi*2*t) + 0.5*sin(2*pi*15*t);          % 与 1.2 相同的信号：2 Hz + 15 Hz
fgrid = linspace(0, fs/2, 501);
dtft = @(h, f) abs(exp(-1i*2*pi*f(:)/fs*(0:numel(h)-1)) * h(:)).';   % |H(f)|，直接按定义求和

%% 演示1：精度——系数用多少位表示
% 21 点低通（截止 6 Hz，窗函数法；第 7 章会讲）。系数分别用 16 位和 4 位表示。
L = 21; k = 0:L-1; fc = 6;
hd = 2*fc/fs * sinc_unscaled(2*pi*fc/fs*(k - (L-1)/2));
w = 0.5 - 0.5*cos(2*pi*k/(L-1));
h = hd .* w; h = h / sum(h);
qcoef = @(v, bits) round(v * 2^(bits-1)) / 2^(bits-1);          % 定点：bits 位，±1 满量程
h16 = qcoef(h, 16); h4 = qcoef(h, 4);
H = dtft(h, fgrid); H16 = dtft(h16, fgrid); H4 = dtft(h4, fgrid);
db = @(v) 20*log10(max(v, 1e-6));

%% 演示2：灵活性——同一套“硬件”，换一组系数就是另一个系统
hlp = h;                                          % 低通：留下 2 Hz
hhp = -h; hhp((L+1)/2) = hhp((L+1)/2) + 1;        % 高通：δ − 低通，留下 15 Hz
ylp = filter(hlp, 1, x); yhp = filter(hhp, 1, x); % 同一条语句 filter(b,1,x)，只换 b

%% 演示3：可靠性——数字系统每次结果一样；模拟元件有漂移
y1 = filter(hlp, 1, x); y2 = filter(hlp, 1, x);   % 跑两次
repeatDiff = max(abs(y1 - y2));                   % 应为 0（不是“很小”，是精确为 0）
rng(20260918); runs = 100; fcRC = 6;
yAnalog = zeros(runs, numel(x));
for r = 1:runs
    fcr = fcRC * (1 + 0.05*(2*rand-1));           % 模拟 RC 元件 ±5% 漂移
    a = exp(-2*pi*fcr/fs);                        % 一阶 RC 低通的差分方程近似
    yAnalog(r, :) = filter(1-a, [1 -a], x);
end
analogSpread = max(max(yAnalog) - min(yAnalog));

%% 演示4：时分复用——一套处理设备轮流处理 4 路信号
ch = [sin(2*pi*2*t); 0.8*sin(2*pi*3*t); 0.6*sin(2*pi*4*t + 1); 0.5*sin(2*pi*1*t)] + 0.5*sin(2*pi*15*t);
C = size(ch, 1);
stream = reshape(ch, 1, []);                      % 按时刻交织：ch1(0) ch2(0) ch3(0) ch4(0) ch1(1) ...
outStream = zeros(size(stream)); state = zeros(C, L-1);   % 一套乘加器 + 每路各自的状态
for i = 1:numel(stream)
    c = mod(i-1, C) + 1;
    [outStream(i), state(c, :)] = filter(hlp, 1, stream(i), state(c, :));
end
outCh = reshape(outStream, C, []);
sepCh = filter(hlp, 1, ch, [], 2);                % 各路单独处理作为对照
tdmDiff = max(abs(outCh(:) - sepCh(:)));          % 浮点舍入量级（1e-16）


codeDir=fileparts(mfilename('fullpath')); mediaDir=fullfile(codeDir,'..','media');
if ~exist(mediaDir,'dir'), mkdir(mediaDir); end
metrics=struct('coef_err_max_4bit',max(abs(h-h4)), ...
    'stopband_worst_db_ideal',max(db(H(fgrid>=12))), ...
    'stopband_worst_db_16bit',max(db(H16(fgrid>=12))), ...
    'stopband_worst_db_4bit',max(db(H4(fgrid>=12))), ...
    'lowpass_gain_2Hz',dtft(hlp,2),'lowpass_gain_15Hz',dtft(hlp,15), ...
    'highpass_gain_2Hz',dtft(hhp,2),'highpass_gain_15Hz',dtft(hhp,15), ...
    'repeat_run_max_diff',repeatDiff,'analog_output_spread_max',analogSpread, ...
    'tdm_vs_separate_max_diff',tdmDiff);
checkValues(metrics,codeDir); % 所有断言先于 VideoWriter 执行
bitsList=[16 12 10 8 6 5 4]; stopLevels=zeros(size(bitsList));
for j=1:numel(bitsList)
    response=dtft(qcoef(h,bitsList(j)),fgrid);
    stopLevels(j)=max(db(response(fgrid>=12)));
end
moviePath=fullfile(mediaDir,'1.3-digital-advantages.mp4');
posterPath=fullfile(mediaDir,'1.3-digital-advantages-poster.png');
f=figure('Color','w','Position',[30 30 1280 720],'MenuBar','none','ToolBar','none','Visible','off');
cleanup=onCleanup(@() delete(f(isgraphics(f))));
blue=[0 .36 .62]; orange=[.85 .33 .10]; gray=[.7 .7 .7]; colors=[blue;orange;.25 .55 .28;.55 .3 .65];
for quality=[90 75]
    writer=VideoWriter(moviePath,'MPEG-4'); writer.FrameRate=30; writer.Quality=quality; open(writer); frames=0;
    try
        for segment=1:4
            clf(f);
            titles={'① 精度：字长决定精度','② 灵活：换系数就换系统','③ 可靠：两次运行差为 0','④ 时分复用：一套设备轮流处理 4 路'};
            notes={'同一个低通滤波器，改变系数字长，观察幅频响应与阻带最差衰减。', ...
                '性能取决于存储的乘法器系数：换一组系数，低通就变成高通。', ...
                '测重复运行的差；观察模拟 RC 元件 ±5% 漂移下的输出范围。', ...
                '4 路按时刻交织，一套乘加器轮流处理；每路保留各自状态。'};
            annotation(f,'textbox',[.07 .88 .92 .075],'String',titles{segment},'EdgeColor','none','FontSize',25,'FontWeight','bold','Interpreter','none');
            annotation(f,'textbox',[.07 .805 .92 .065],'String',notes{segment},'EdgeColor','none','FontSize',16,'Interpreter','none');
            caption=annotation(f,'textbox',[.08 .025 .9 .065],'String','','EdgeColor','none','FontSize',18,'Color',blue,'Interpreter','none');
            switch segment
                case 1
                    ax=makeAxes(f,[.09 .23 .85 .53]); xlim(ax,[0 50]); ylim(ax,[-80 5]);
                    ideal=plot(ax,fgrid,db(H),'k','LineWidth',1.5);
                    changing=plot(ax,fgrid,NaN(size(fgrid)),'Color',blue,'LineWidth',1.8);
                    xline(ax,2,':'); xline(ax,15,':'); xlabel(ax,'频率 (Hz)'); ylabel(ax,'幅频响应 (dB)');
                    legend(ax,[ideal changing],{'理想系数','当前字长'},'Location','southoutside','Orientation','horizontal','AutoUpdate','off');
                    status=annotation(f,'textbox',[.52 .755 .42 .045],'String','','EdgeColor','none','FontSize',16,'HorizontalAlignment','right','Interpreter','none');
                    [frames,lastFrame]=holdFrames(f,writer,frames,30);
                    for j=1:numel(bitsList)
                        set(changing,'YData',db(dtft(qcoef(h,bitsList(j)),fgrid)),'Color',colors(mod(j-1,4)+1,:));
                        status.String=sprintf('b = %d 位，阻带最差 %.1f dB',bitsList(j),stopLevels(j));
                        if j==numel(bitsList), caption.String='16 位 −25.2 dB → 4 位 −13.8 dB：字长就是精度'; end
                        [frames,lastFrame]=holdFrames(f,writer,frames,45); % 每级恰好 1.5 s
                    end
                    [frames,lastFrame]=holdFrames(f,writer,frames,15); % 共 12 s
                case 2
                    left=makeAxes(f,[.09 .27 .25 .43]); xlim(left,[-1 21]); ylim(left,[-.2 1]);
                    coeff=stem(left,k,hlp,'filled','Color',blue,'MarkerSize',4); xlabel(left,'系数序号 k'); ylabel(left,'b(k)');
                    title(left,'21 个低通系数','FontSize',15);
                    right=makeAxes(f,[.43 .27 .51 .43]); xlim(right,[.3 1.3]); ylim(right,[-1.6 1.6]);
                    inp=plot(right,t,x,'Color',gray); low=plot(right,NaN,NaN,'Color',blue,'LineWidth',1.7); high=plot(right,NaN,NaN,'Color',orange,'LineWidth',1.7);
                    xlabel(right,'时间 t (s)'); ylabel(right,'幅度');
                    legend(right,[inp low high],{'输入','低通输出','高通输出'},'Location','southoutside','Orientation','horizontal','AutoUpdate','off');
                    idxView=find(t>=.3 & t<=1.3);
                    [frames,lastFrame]=holdFrames(f,writer,frames,30);
                    for j=1:60
                        ii=idxView(1:max(1,ceil(j/60*numel(idxView)))); set(low,'XData',t(ii),'YData',ylp(ii));
                        [frames,lastFrame]=holdFrames(f,writer,frames,1);
                    end
                    title(left,'系数改为 δ − h','FontSize',15);
                    for j=1:30
                        count=min(L,ceil(j/30*L)); current=hlp; current(1:count)=hhp(1:count);
                        set(coeff,'YData',current,'Color',orange);
                        [frames,lastFrame]=holdFrames(f,writer,frames,1);
                    end
                    for j=1:60
                        ii=idxView(1:max(1,ceil(j/60*numel(idxView)))); set(high,'XData',t(ii),'YData',yhp(ii));
                        [frames,lastFrame]=holdFrames(f,writer,frames,1);
                    end
                    caption.String='同一条 filter(b,1,x)，只换了 b';
                    [frames,lastFrame]=holdFrames(f,writer,frames,60); % 共 8 s
                case 3
                    ax=makeAxes(f,[.09 .24 .85 .47]); xlim(ax,[.3 1.3]); ylim(ax,[-1.5 1.5]); xlabel(ax,'时间 t (s)'); ylabel(ax,'幅度');
                    band=fill(ax,NaN,NaN,[1 .82 .71],'EdgeColor','none','FaceAlpha',.65);
                    first=plot(ax,NaN,NaN,'Color',blue,'LineWidth',2);
                    second=plot(ax,NaN,NaN,'--','Color',blue,'LineWidth',2);
                    legend(ax,[band first second],{'模拟 100 次范围','数字第 1 次','数字第 2 次（重合）'},'Location','southoutside','Orientation','horizontal','AutoUpdate','off');
                    status=annotation(f,'textbox',[.5 .735 .45 .06],'String','模拟运行：0 / 100','EdgeColor','none','FontSize',17,'HorizontalAlignment','right','Interpreter','none');
                    [frames,lastFrame]=holdFrames(f,writer,frames,30);
                    previous=0;
                    for group=1:40
                        count=round(group*runs/40); % 每次加 2—3 条，再定格供观察，总计 6 s
                        for runNo=previous+1:count
                            plot(ax,t,yAnalog(runNo,:),'Color',[1 .82 .71],'LineWidth',.6,'HandleVisibility','off');
                        end
                        set(band,'XData',[t fliplr(t)],'YData',[max(yAnalog(1:count,:),[],1) fliplr(min(yAnalog(1:count,:),[],1))]);
                        status.String=sprintf('模拟运行：%d / 100，带宽 %.3f',count,max(max(yAnalog(1:count,:),[],1)-min(yAnalog(1:count,:),[],1)));
                        [frames,lastFrame]=holdFrames(f,writer,frames,4+mod(group,2)); previous=count;
                    end
                    ii=find(t>=.3 & t<=1.3);
                    for j=1:30
                        jj=ii(1:ceil(j/30*numel(ii)));set(first,'XData',t(jj),'YData',y1(jj));
                        [frames,lastFrame]=holdFrames(f,writer,frames,1);
                    end
                    for j=1:30
                        jj=ii(1:ceil(j/30*numel(ii)));set(second,'XData',t(jj),'YData',y2(jj));
                        [frames,lastFrame]=holdFrames(f,writer,frames,1);
                    end
                    status.String=sprintf('两次运行差 = %g（精确）',repeatDiff);
                    caption.String='模拟：一条带，宽 0.046；数字：一条线，差精确为 0';
                    [frames,lastFrame]=holdFrames(f,writer,frames,30); % 共 10 s
                case 4
                    ax=axes(f,'Position',[.06 .14 .88 .65]);hold(ax,'on');axis(ax,[0 1 0 10]);axis(ax,'off');ax.Toolbar.Visible='off';
                    xPos=.12+.52*t(1:31)/.3; inputRows=[8.7 7.9 7.1 6.3]; outputRows=[3.4 2.6 1.8 1.0]; outHandles=gobjects(C,1);
                    for channel=1:C
                        plot(ax,xPos,inputRows(channel)+.24*ch(channel,1:31),'Color',colors(channel,:),'LineWidth',1.2);
                        text(ax,.01,inputRows(channel),sprintf('输入 %d',channel),'FontSize',12,'Color',colors(channel,:));
                        text(ax,.01,outputRows(channel),sprintf('输出 %d',channel),'FontSize',12,'Color',colors(channel,:));
                        plot(ax,[.12 .64],[outputRows(channel) outputRows(channel)],':','Color',[.8 .8 .8]);
                        outHandles(channel)=plot(ax,NaN,NaN,'.-','Color',colors(channel,:),'MarkerSize',10,'LineWidth',1.2);
                        text(ax,.18+.15*(channel-1),4.55,sprintf('ch%d(0)',channel),'FontSize',12,'HorizontalAlignment','center','Tag',sprintf('slot%d',channel));
                    end
                    for xx=[0 .15 .3]
                        px=.12+.52*xx/.3;
                        text(ax,px,9.55,sprintf('%.2g s',xx),'FontSize',12,'HorizontalAlignment','center');
                        text(ax,px,.3,sprintf('%.2g s',xx),'FontSize',12,'HorizontalAlignment','center');
                    end
                    plot(ax,[.12 .68],[5 5],'-','Color',gray);
                    text(ax,.72,5,'一套乘加器','FontSize',15,'FontWeight','bold');
                    text(ax,.74,3.2,{'每路各有状态','输出按通道拆开'},'FontSize',13);
                    text(ax,.12,5.65,'交织顺序：ch1(n) → ch2(n) → ch3(n) → ch4(n)','FontSize',13);
                    status=text(ax,.73,8.1,{'当前 n = 0','等待采样'},'FontSize',14);
                    moving=plot(ax,NaN,NaN,'o','MarkerSize',9,'MarkerFaceColor',blue,'Color',blue);
                    [frames,lastFrame]=holdFrames(f,writer,frames,30);
                    for index=1:124
                        channel=mod(index-1,C)+1; sample=floor((index-1)/C)+1;
                        slots=findobj(ax,'Tag',sprintf('slot%d',channel)); slots.String=sprintf('ch%d(%d)',channel,sample-1);
                        status.String={sprintf('当前 n = %d',sample-1),sprintf('轮到通道 %d',channel)};
                        start=[xPos(sample) inputRows(channel)+.24*ch(channel,sample)]; stop=[.18+.15*(channel-1) 5];
                        steps=1; if index<=4, steps=8; end % 第一轮慢放约 1 s，后续加速
                        for step=1:steps
                            fraction=step/steps; point=start+(stop-start)*fraction;
                            set(moving,'XData',point(1),'YData',point(2),'Color',colors(channel,:),'MarkerFaceColor',colors(channel,:));
                            if step==steps
                                set(outHandles(channel),'XData',xPos(1:sample),'YData',outputRows(channel)+.24*outCh(channel,1:sample));
                            end
                            [frames,lastFrame]=holdFrames(f,writer,frames,1);
                        end
                    end
                    moving.Visible='off';status.String={'4 路处理完成','状态各自独立'};
                    caption.String=sprintf('与各路单独处理差 %.1e：一套设备处理了 4 路',tdmDiff);
                    [frames,lastFrame]=holdFrames(f,writer,frames,118); % 共 10 s
            end
            fprintf('Segment %d complete; frames=%d\n',segment,frames);
        end
        close(writer);
    catch failure
        close(writer);rethrow(failure);
    end
    info=dir(moviePath); if info.bytes<8e6,break;end
end
assert(frames==1200 && info.bytes<8e6,'时长或文件大小不符合要求');
imwrite(lastFrame.cdata,posterPath);checkValues(metrics,codeDir);
metrics.matlab_version=version;metrics.generated_at=char(datetime('now','Format','yyyy-MM-dd HH:mm:ss'));
metrics.frames=frames;metrics.frame_rate=30;metrics.duration_s=frames/30;metrics.width=1280;metrics.height=720;
metrics.quality=quality;metrics.file_size_bytes=info.bytes;metrics.bits=bitsList;metrics.stopband_by_bits_db=stopLevels;
metrics.all_checks_passed=true;
fid=fopen(fullfile(codeDir,'results','verification-video-advantages.json'),'w','n','UTF-8');
assert(fid>=0,'无法写核验记录');fprintf(fid,'%s\n',jsonencode(metrics,PrettyPrint=true));fclose(fid);disp(metrics);

function ax=makeAxes(fig,position)
ax=axes(fig,'Position',position,'PositionConstraint','innerposition');hold(ax,'on');grid(ax,'on');ax.FontSize=14;ax.Toolbar.Visible='off';
end
function checkValues(m,codeDir)
assert(abs(m.coef_err_max_4bit-.05773)<1e-3,'4 位系数量化误差不符');
assert(all(abs([m.stopband_worst_db_ideal m.stopband_worst_db_16bit m.stopband_worst_db_4bit]-[-25.14 -25.15 -13.81])<.1),'阻带最差衰减不符');
assert(all(abs([m.lowpass_gain_2Hz m.lowpass_gain_15Hz]-[.940 .0040])<.01),'低通增益不符');
assert(all(abs([m.highpass_gain_2Hz m.highpass_gain_15Hz]-[.060 1.004])<.01),'高通增益不符');
assert(m.repeat_run_max_diff==0,'两次运行差必须精确为 0');
assert(abs(m.analog_output_spread_max-.04576)<1e-3,'模拟漂移输出带宽不符');
assert(m.tdm_vs_separate_max_diff<1e-12,'时分复用不符');
saved=jsondecode(fileread(fullfile(codeDir,'results','verification-advantages.json')));
names=fieldnames(m);
for i=1:numel(names)
    assert(abs(m.(names{i})-saved.(names{i}))<1e-10,['与原始核验记录不一致：' names{i}]);
end
end

function y = sinc_unscaled(z)
y = ones(size(z)); nz = (z ~= 0); y(nz) = sin(z(nz))./z(nz);
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
