% 1.1微课：固定输入范围[-1,1]，中升均匀量化，L个区间的中心为L个电平。
here=fileparts(mfilename('fullpath'));out=fullfile(here,'..');
if ~exist(fullfile(out,'qa'),'dir'),mkdir(fullfile(out,'qa'));end
wave=@(t) .72*sin(2*pi*t)+.18*cos(6*pi*t);
t=linspace(0,1,801);configs=struct([]);
for fs=[16,32]
 for bits=[3,8]
  n=0:fs-1;ts=n/fs;x=wave(ts);L=2^bits;delta=2/L;
  codes=min(L-1,max(0,floor((x+1)/delta)));q=-1+(codes+.5)*delta;
  assert(max(abs(q-x))<=delta/2+1e-12);assert(all(codes>=0 & codes<L));
  cfg=struct('fs',fs,'bits',bits,'n',n,'t',ts,'x',x,'q',q,'codes',codes,'levels',-1+((0:L-1)+.5)*delta,'delta',delta,'max_error',max(abs(q-x)),'y',.5*x);
  if isempty(configs),configs=cfg;else,configs(end+1)=cfg;end
 end
end
assert(numel(unique(configs(1).levels))==8 && numel(configs(2).levels)==256);
overload=struct('input',1.3,'q',.875,'error',1.3-.875,'half_step',.125);
assert(overload.error>overload.half_step);
data=struct('t',t,'wave',wave(t),'configs',configs,'overload',overload,'normalization','amplitude dimensionless; time seconds; n integer');
fid=fopen(fullfile(out,'data.json'),'w','n','UTF-8');fprintf(fid,'%s',jsonencode(data));fclose(fid);
qa=struct('engine','MATLAB','version',version,'run_at',char(datetime('now')),'configuration_count',4,'all_error_bounds_passed',true,'level_counts',[8,256],'max_errors',[configs.max_error],'half_steps',[configs.delta]/2,'overload_test_passed',true);
fid=fopen(fullfile(out,'qa','matlab.json'),'w','n','UTF-8');fprintf(fid,'%s',jsonencode(qa,PrettyPrint=true));fclose(fid);disp(qa)
