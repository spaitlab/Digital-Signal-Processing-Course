root=fileparts(fileparts(mfilename('fullpath')));n=0:127;configs=struct([]);j=0;err=0;
for a=[.8 1 1.2]
 h=filter(1,[1 -a],[1 zeros(1,127)]);step=filter(1,[1 -a],ones(1,128));hh=a.^n;
 if a==1,exact=n+1;else,exact=(1-a.^(n+1))/(1-a);end
 e=max(abs(step-exact)./max(1,abs(exact)));err=max(err,e);assert(e<1e-12);assert(max(abs(h-hh)./max(1,abs(hh)))<1e-12);
 j=j+1;item=struct('id',sprintf('a%.1f',a),'a',a,'n',n,'h',h,'step',step,'abs_partial',cumsum(abs(h)),'stable',a<1,'causal',true);if j==1,configs=item;else,configs(j)=item;end
end
h=1./(n+1);step=conv(h,ones(size(n)));step=step(1:128);assert(max(abs(step-cumsum(h)))<1e-12);configs(4)=struct('id','harmonic','a',NaN,'n',n,'h',h,'step',step,'abs_partial',cumsum(h),'stable',false,'causal',true);
nl=-40:0;hl=-(1.2).^nl;hl(end)=0;tn=-10:10;yl=zeros(size(tn));approx=yl;m=1:200;
for k=1:numel(tn),if tn(k)<0,yl(k)=-1.2^(tn(k)+1)/.2;else,yl(k)=-5;end;approx(k)=sum(-1.2.^(-m).*(tn(k)+m>=0));end
left_error=max(abs(yl-approx));assert(left_error<1e-12);groups=zeros(1,7);for k=1:7,groups(k)=sum(1./(2^(k-1)+1:2^k));end;assert(all(groups>=.5));
data=struct('configs',configs,'nl',nl,'hl',hl,'tn',tn,'left_step',yl,'left_step_200',approx,'group_sums',groups);
report=struct('passed',true,'version',version,'recurrence_relative_error',err,'left_step_200_error',left_error,'right08_l1',5,'left12_l1',5,'harmonic_128_sum',step(end),'group_sums',groups,'case_verdicts',{{'a0.8 stable causal','a1.0 unstable causal','a1.2 unstable causal','harmonic unstable causal','left1.2 stable noncausal'}});
fid=fopen(fullfile(root,'data.json'),'w','n','UTF-8');fwrite(fid,jsonencode(data),'char');fclose(fid);fid=fopen(fullfile(root,'qa','matlab.json'),'w','n','UTF-8');fwrite(fid,jsonencode(report,PrettyPrint=true),'char');fclose(fid);disp(report);
