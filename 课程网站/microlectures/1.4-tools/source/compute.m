here=fileparts(mfilename('fullpath'));out=fullfile(here,'..');fs=100;f=2;configs=struct([]);
for N=[200,180]
 for A=[1,.5]
  for start=[0,1]
   n=start+(0:N-1);t=n/fs;x=A*sin(2*pi*f*t);squared=x.^2;cumulative=cumsum(squared);energy=sum(squared);
   cfg=struct('N',N,'A',A,'start',start,'n',n,'t',t,'x',x,'squared',squared,'cumulative',cumulative,'energy',energy,'cos_sum',sum(cos(4*pi*f*t)));
   assert(abs(energy-A^2/2*(N-cfg.cos_sum))<1e-11);
   if isempty(configs),configs=cfg;else,configs(end+1)=cfg;end
  end
 end
end
base=configs(1);shift=configs(2);assert(abs(base.energy-100)<1e-12);assert(abs(shift.energy-100)<1e-12);assert(max(abs(base.x-shift.x))>.1);
data=struct('fs',fs,'f',f,'configs',configs);fid=fopen(fullfile(out,'data.json'),'w','n','UTF-8');fprintf(fid,'%s',jsonencode(data));fclose(fid);
report=struct('version',version,'configuration_count',numel(configs),'baseline_energy',base.energy,'shifted_energy',shift.energy,'shift_max_difference',max(abs(base.x-shift.x)),'passed',true);fid=fopen(fullfile(out,'qa','matlab.json'),'w','n','UTF-8');fprintf(fid,'%s',jsonencode(report,PrettyPrint=true));fclose(fid);disp(report);
