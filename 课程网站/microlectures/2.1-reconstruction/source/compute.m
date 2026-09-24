root=fileparts(fileparts(mfilename('fullpath')));t=linspace(-1,1,801);ref=cos(2*pi*5*t);mask=abs(t)<=0.5+1e-12;
configs=struct([]);pairs=[12,12;12,36;12,120;6,120];
for j=1:size(pairs,1)
 fs=pairs(j,1);M=pairs(j,2);n=-M:M;tn=n/fs;x=cos(2*pi*5*tn);
 u=fs*t(:)-n;K=ones(size(u));nz=abs(u)>1e-12;K(nz)=sin(pi*u(nz))./(pi*u(nz));
 ys=(K*x.').';yl=interp1(tn,x,t,'linear');yz=interp1(tn,x,t,'previous');
 e=[yz(mask)-ref(mask);yl(mask)-ref(mask);ys(mask)-ref(mask)];
 un=n(:)-n;Ks=ones(size(un));nz=un~=0;Ks(nz)=sin(pi*un(nz))./(pi*un(nz));sample_err=max(abs(Ks*x.'-x.'));
 assert(sample_err<1e-12);
 item=struct('fs',fs,'M',M,'count',numel(n),'tn',tn,'samples',x,'sinc',ys,'linear',yl,'hold',yz,'rmse',sqrt(mean(e.^2,2)).','maxerr',max(abs(e),[],2).','sample_error',sample_err,'alias_rmse',sqrt(mean((ys(mask)-cos(2*pi*t(mask))).^2)));
 if j==1,configs=item;else,configs(j)=item;end
end
n=-12:12;fs=12;x=cos(2*pi*5*n/fs);order=[0,reshape([1:12;-(1:12)],1,[])];terms=zeros(25,numel(t));
for j=1:25,u=fs*t-order(j);v=ones(size(u));nz=abs(u)>1e-12;v(nz)=sin(pi*u(nz))./(pi*u(nz));terms(j,:)=cos(2*pi*5*order(j)/fs)*v;end
partials=cumsum(terms,1);assert(max(abs(partials(end,:)-configs(1).sinc))<1e-12);
report=struct('passed',true,'version',version,'interval',[-.5,.5],'grid_step',t(2)-t(1),'method_order',{{'hold','linear','sinc'}},'rmse',vertcat(configs.rmse),'maxerr',vertcat(configs.maxerr),'sample_maxerr',max([configs.sample_error]),'alias_vs_1Hz_rmse',configs(4).alias_rmse);
assert(all(diff(report.rmse(1:3,3))<0));assert(report.alias_vs_1Hz_rmse<.01);
data=struct('t',t,'reference',ref,'alias_reference',cos(2*pi*t),'configs',configs,'order',order,'terms',terms,'partials',partials);
fid=fopen(fullfile(root,'data.json'),'w','n','UTF-8');fwrite(fid,jsonencode(data),'char');fclose(fid);
fid=fopen(fullfile(root,'qa','matlab.json'),'w','n','UTF-8');fwrite(fid,jsonencode(report,PrettyPrint=true),'char');fclose(fid);disp(report);

