here=fileparts(mfilename('fullpath'));out=fullfile(here,'..');f0=5;tc=linspace(0,1,1001);configs=struct([]);
for fs=[20,12,6,10]
 for kind=["cos","sin"]
  n=0:fs;t=n/fs;fold=f0-floor(f0/fs+.5)*fs;
  if kind=="cos",x=cos(2*pi*f0*t);alias=cos(2*pi*fold*t);wave=cos(2*pi*f0*tc);alias_wave=cos(2*pi*fold*tc);else,x=sin(2*pi*f0*t);alias=sin(2*pi*fold*t);wave=sin(2*pi*f0*tc);alias_wave=sin(2*pi*fold*tc);end
  err=max(abs(x-alias));assert(err<1e-12);lines=reshape([-f0;f0]+(-3:3)*fs,1,[]);
  cfg=struct('fs',fs,'kind',char(kind),'fold',fold,'n',n,'t',t,'x',x,'alias',alias,'wave',wave,'alias_wave',alias_wave,'alias_error',err,'lines',lines);
  if isempty(configs),configs=cfg;else,configs(end+1)=cfg;end
 end
end
critical=configs(end);assert(max(abs(critical.x))<1e-12);
data=struct('f0',f0,'tc',tc,'configs',configs);fid=fopen(fullfile(out,'data.json'),'w','n','UTF-8');fprintf(fid,'%s',jsonencode(data));fclose(fid);
report=struct('version',version,'configurations',numel(configs),'max_alias_difference',max([configs.alias_error]),'critical_sine_max',max(abs(critical.x)),'passed',true);fid=fopen(fullfile(out,'qa','matlab.json'),'w','n','UTF-8');fprintf(fid,'%s',jsonencode(report,PrettyPrint=true));fclose(fid);disp(report);
