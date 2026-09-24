function build_mlx()
%% build_mlx：把课程站的 .m 演示转成 Live Script（.mlx），执行并嵌入输出，再导出 HTML
% 在桌面版 MATLAB 中运行（Live Editor 功能需要桌面会话）。.m 仍是可批处理核验的源码，.mlx 用于课堂展示。
% 写成函数：executeAndSave 在基础工作区执行演示，演示开头的 clearvars 不会清掉这里的变量。
root = 'G:/2026-Agent/数字信号处理/课程网站/ch3/code';
outdir = fullfile(root, 'mlx'); if ~exist(outdir, 'dir'), mkdir(outdir); end
srcs = {'demo_fourier_forms.m', 'demo_dft.m', 'matlab/dfs_example_3_2.m', 'matlab/dft_example_3_3.m'};
for i = 1:numel(srcs)
    [~, stem] = fileparts(srcs{i});
    src = fullfile(root, srcs{i}); mlx = fullfile(outdir, [stem '.mlx']); html = fullfile(outdir, [stem '.html']);
    fprintf('[%d/%d] %s -> %s\n', i, numel(srcs), srcs{i}, [stem '.mlx']);
    matlab.internal.liveeditor.openAndSave(src, mlx);          % .m -> .mlx（%% 变节标题，注释变文本）
    matlab.internal.liveeditor.executeAndSave(mlx);            % 执行并把图和输出嵌入 .mlx
    export(mlx, html);                                         % 导出带输出的独立 HTML
end
close all
d = dir(outdir); for i = 3:numel(d), fprintf('  %-28s %6d KB\n', d(i).name, round(d(i).bytes/1024)); end
disp('BUILD_MLX_DONE');
end