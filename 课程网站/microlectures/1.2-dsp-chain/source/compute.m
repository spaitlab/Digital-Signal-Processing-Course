here=fileparts(mfilename('fullpath'));out=fullfile(here,'..');
fs=100;n=0:199;t=n/fs;slow=sin(2*pi*2*t);fast=.5*sin(2*pi*15*t);x=slow+fast;
delta=4/256;r=(x+2)/delta;near=abs(r-round(r))<1e-10;r(near)=round(r(near));codes=min(255,max(0,floor(r)));q=-2+(codes+.5)*delta;
assert(max(abs(q-x))<=delta/2+1e-12);
tc=(0:1999)/1000;continuous=sin(2*pi*2*tc)+.5*sin(2*pi*15*tc);configs=struct([]);
for M=[1,3,5,9]
 y=filter(ones(1,M)/M,1,q);manual=zeros(size(q));
 for i=1:numel(q),manual(i)=sum(q(max(1,i-M+1):i))/M;end
 assert(max(abs(y-manual))<1e-12);
 idx=n>=20;A=[sin(2*pi*2*t(idx))',cos(2*pi*2*t(idx))',sin(2*pi*15*t(idx))',cos(2*pi*15*t(idx))',ones(sum(idx),1)];c=A\y(idx)';
 amps=[hypot(c(1),c(2)),hypot(c(3),c(4))];g=@(f) abs(sum(exp(-1i*2*pi*f/fs*(0:M-1)))/M);
 theory=[g(2),.5*g(15)];assert(max(abs(amps-theory))<.01);
 zoh=repelem(y,10);smooth=filter(ones(1,20)/20,1,zoh);
 cfg=struct('M',M,'y',y,'zoh',zoh,'smooth',smooth,'amplitudes',amps,'theory',theory,'delay_ms',(M-1)/2/fs*1000,'manual_error',max(abs(y-manual)));
 if isempty(configs),configs=cfg;else,configs(end+1)=cfg;end
end
data=struct('fs',fs,'n',n,'t',t,'slow',slow,'fast',fast,'x',x,'q',q,'delta',delta,'codes',codes,'tc',tc,'continuous',continuous,'slow_cont',sin(2*pi*2*tc),'configs',configs,'preprocessing','assumed preprocessed input, analog circuit not simulated');
fid=fopen(fullfile(out,'data.json'),'w','n','UTF-8');fprintf(fid,'%s',jsonencode(data));fclose(fid);
qa=struct('version',version,'run_at',char(datetime('now')),'quantization_max_error',max(abs(q-x)),'half_step',delta/2,'manual_errors',[configs.manual_error],'delay_ms',[configs.delay_ms],'amplitudes_M5',configs(3).amplitudes,'passed',true);
fid=fopen(fullfile(out,'qa','matlab.json'),'w','n','UTF-8');fprintf(fid,'%s',jsonencode(qa,PrettyPrint=true));fclose(fid);disp(qa)
