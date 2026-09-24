here=fileparts(mfilename('fullpath'));out=fullfile(here,'..');n=0:119;configs=struct([]);
for id=["pi","rad"]
 if id=="pi",omega=.3*pi;else,omega=.3;end
 x=cos(omega*n);cmp=struct([]);
 for shift=[7,20,21,40]
  shifted=cos(omega*(n+shift));diff=shifted-x;c=struct('shift',shift,'shifted',shifted,'difference',diff,'max_error',max(abs(diff)),'phase_gap',abs(exp(1i*omega*shift)-1));
  if isempty(cmp),cmp=c;else,cmp(end+1)=c;end
 end
 cfg=struct('id',char(id),'omega',omega,'x',x,'phase_x',cos(omega*n),'phase_y',sin(omega*n),'comparisons',cmp);
 if isempty(configs),configs=cfg;else,configs(end+1)=cfg;end
end
assert(configs(1).comparisons(2).max_error<1e-12);assert(configs(1).comparisons(4).max_error<1e-12);assert(configs(2).comparisons(3).max_error>1e-3);
brick_n=-2:6;values=[1,2,-1,1];parts=zeros(4,numel(brick_n));
for k=0:3,parts(k+1,:)=values(k+1)*(brick_n==k);end
reconstructed=sum(parts,1);assert(isequal(reconstructed,[0,0,values,0,0,0]));
data=struct('n',n,'configs',configs,'brick_n',brick_n,'values',values,'parts',parts,'reconstructed',reconstructed);fid=fopen(fullfile(out,'data.json'),'w','n','UTF-8');fprintf(fid,'%s',jsonencode(data));fclose(fid);
report=struct('version',version,'period20_error',configs(1).comparisons(2).max_error,'rad_shift21_error',configs(2).comparisons(3).max_error,'delta_reconstruction_exact',true,'passed',true);fid=fopen(fullfile(out,'qa','matlab.json'),'w','n','UTF-8');fprintf(fid,'%s',jsonencode(report,PrettyPrint=true));fclose(fid);disp(report);
