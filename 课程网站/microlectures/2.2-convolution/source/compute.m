root=fileparts(fileparts(mfilename('fullpath'))); x=[1 2 3 4]; specs={'base',[3 2 1],0,0;'shift',[3 2 1],-1,2;'echo',[1 0 .5],0,0};
configs=struct([]);
for q=1:3
 id=specs{q,1};h=specs{q,2};x0=specs{q,3};h0=specs{q,4};nx=x0+(0:numel(x)-1);nh=h0+(0:numel(h)-1);y=conv(x,h);ny=x0+h0+(0:numel(y)-1);k=-3:10;xk=zeros(size(k));[ok,loc]=ismember(k,nx);xk(ok)=x(loc(ok));steps=struct([]);
 for j=1:numel(y)+2
  n=ny(1)+j-2;hv=zeros(size(k));[ok,loc]=ismember(n-k,nh);hv(ok)=h(loc(ok));p=xk.*hv;item=struct('n',n,'hshift',hv,'products',p,'sum',sum(p));if j==1,steps=item;else,steps(j)=item;end
 end
 contributions=zeros(numel(x),numel(y));for j=1:numel(x),[ok,loc]=ismember(ny-nx(j),nh);contributions(j,ok)=x(j)*h(loc(ok));end
 assert(max(abs(sum(contributions,1)-y))<1e-12);assert(max(abs([steps(2:end-1).sum]-y))<1e-12);assert(max(abs(conv(h,x)-y))<1e-12);
 item=struct('id',id,'x',x,'h',h,'x0',x0,'h0',h0,'nx',nx,'nh',nh,'ny',ny,'y',y,'k',k,'xk',xk,'steps',steps,'contributions',contributions,'partial',cumsum(contributions,1));if q==1,configs=item;else,configs(q)=item;end
end
filtered=filter([3 2 1],1,[x 0 0]);assert(isequal(filtered,configs(1).y));assert(isequal(configs(1).y,[3 8 14 20 11 4]));
data=struct('configs',configs);report=struct('passed',true,'version',version,'base_y',configs(1).y,'shift_n',configs(2).ny,'echo_y',configs(3).y,'filter_padded_y',filtered,'routes',{{'conv','flip_shift_sum','weighted_responses','filter_padded','commutativity'}});
fid=fopen(fullfile(root,'data.json'),'w','n','UTF-8');fwrite(fid,jsonencode(data),'char');fclose(fid);fid=fopen(fullfile(root,'qa','matlab.json'),'w','n','UTF-8');fwrite(fid,jsonencode(report,PrettyPrint=true),'char');fclose(fid);disp(report);
