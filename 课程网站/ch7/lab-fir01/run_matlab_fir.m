function run_matlab_fir
% FIR-01: same input samples as Python, causal zero-state filtering.
root = fileparts(mfilename('fullpath'));
outdir = fullfile(root, 'results');
data = readmatrix(fullfile(outdir, 'input.csv'));
assert(isequal(size(data), [2001 2]));
t = data(:,1); x = data(:,2);
b = ones(1,4)/4;
y = filter(b, 1, x);
impulse = filter(b, 1, [1; zeros(7,1)]);
assert(max(abs(impulse - [.25;.25;.25;.25;0;0;0;0])) < 1e-15);
step = filter(b, 1, ones(8,1));
assert(max(abs(step - [.25;.5;.75;1;1;1;1;1])) < 1e-15);
fid = fopen(fullfile(outdir,'matlab.csv'),'w');
assert(fid ~= -1); cleanup = onCleanup(@() fclose(fid));
fprintf(fid,'t,x,y\n');
fprintf(fid,'%.17g,%.17g,%.17g\n',[t,x,y].');
clear cleanup;
meta = struct('platform','MATLAB','version',version,'method','filter', ...
    'initial_state','zero','samples',numel(t),'taps',4,'local_checks_passed',2);
fid = fopen(fullfile(outdir,'matlab-runtime.json'),'w');
assert(fid ~= -1); cleanup = onCleanup(@() fclose(fid));
fprintf(fid,'%s\n',jsonencode(meta));
disp('FIR01_MATLAB_PASSED');
end
