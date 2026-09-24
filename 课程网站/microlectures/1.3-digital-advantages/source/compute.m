here=fileparts(mfilename('fullpath'));out=fullfile(here,'..');
fs=32;n=0:31;t=n/fs;x=.72*sin(2*pi*t)+.18*cos(6*pi*t);configs=struct([]);
for bits=[3,8]
 [q,delta]=quant(x,bits);
 for gain=[.5,1,2]
  ideal=gain*q;stored=quant(ideal,bits);again=quant(gain*q,bits);
  assert(isequal(stored,again));assert(max(abs(q-x))<=delta/2+1e-12);
  cfg=struct('bits',bits,'gain',gain,'q',q,'delta',delta,'max_error',max(abs(q-x)),'ideal',ideal,'stored',stored,'overload_count',sum(ideal<-1|ideal>1),'repeat_error',max(abs(stored-again)));
  if isempty(configs),configs=cfg;else,configs(end+1)=cfg;end
 end
end
channels=[.6*sin(2*pi*t);.5*cos(4*pi*t);.4*sin(6*pi*t);.3*cos(8*pi*t)];separate=.5*channels;stream=channels(:)';restored=reshape(.5*stream,4,[]);assert(isequal(restored,separate));
sent=[0,1,1,0,1,0,0,1,0,1,1,0];noise=struct([]);
for amount=[.2,.6]
 received=sent+(1-2*sent)*amount;decided=double(received>=.5);
 cfg=struct('amount',amount,'received',received,'decided',decided,'errors',sum(decided~=sent));
 if isempty(noise),noise=cfg;else,noise(end+1)=cfg;end
end
assert(noise(1).errors==0 && noise(2).errors==12);
tc=linspace(0,1,801);data=struct('fs',fs,'n',n,'t',t,'x',x,'tc',tc,'wave',.72*sin(2*pi*tc)+.18*cos(6*pi*tc),'configs',configs,'channels',channels,'separate',separate,'stream',stream,'restored',restored,'sent',sent,'noise',noise);
fid=fopen(fullfile(out,'data.json'),'w','n','UTF-8');fprintf(fid,'%s',jsonencode(data));fclose(fid);
qa=struct('version',version,'run_at',char(datetime('now')),'configuration_count',6,'input_error_bounds',true,'repeat_errors',[configs.repeat_error],'tdm_max_difference',max(abs(restored(:)-separate(:))),'noise_example_errors',[noise.errors],'minimum_sample_operations_per_second',4*fs,'passed',true);
fid=fopen(fullfile(out,'qa','matlab.json'),'w','n','UTF-8');fprintf(fid,'%s',jsonencode(qa,PrettyPrint=true));fclose(fid);disp(qa)
function [q,delta]=quant(x,bits)
L=2^bits;delta=2/L;r=(x+1)/delta;near=abs(r-round(r))<1e-10;r(near)=round(r(near));code=min(L-1,max(0,floor(r)));q=-1+(code+.5)*delta;
end
