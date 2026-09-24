root=fileparts(fileparts(mfilename('fullpath')));w=linspace(0,pi,801);z=exp(1i*w);rs=[.5 sqrt(.72) .95];cases=struct([]);err=0;
for k=1:3
 r=rs(k);p=r*exp(1i*pi/4);a=[1 -2*r*cos(pi/4) r*r];H=(1+z.^-1)./(1+a(2)*z.^-1+a(3)*z.^-2);G=z.*(z+1)./((z-p).*(z-conj(p)));
 err=max(err,max(abs(H-G)));[pk,j]=max(abs(H));ph=angle(H);ph(end)=NaN;
 item=struct('r',r,'a',a,'re',real(H),'im',imag(H),'amp',abs(H),'phase',ph,'peak',pk,'peak_w_pi',w(j)/pi);
 if k==1,cases=item;else,cases(k)=item;end
end
assert(err<1e-10);assert(abs(cases(2).peak_w_pi-.25)>.001);
n=0:199;signals=struct([]);e=0;
for k=1:3
 om=[pi/4 pi/2 pi];v=om(k);x=cos(v*n);y=filter([1 1],[1 -1.2 .72],x);hv=(1+exp(-1i*v))/(1-1.2*exp(-1i*v)+.72*exp(-2i*v));pred=real(hv*exp(1i*v*n));ee=max(abs(y(161:end)-pred(161:end)));e=max(e,ee);
 item=struct('w_pi',v/pi,'x',x,'y',y,'steady',pred,'tail_error',ee,'amp',abs(hv));if k==1,signals=item;else,signals(k)=item;end
end
assert(e<1e-9);assert(abs(signals(3).y(1)-1)<1e-12);assert(cases(2).amp(end)<1e-12);
data=struct('w_pi',w/pi,'cases',cases,'n',n,'signals',signals,'zeros',[0 -1]);
f=fopen(fullfile(root,'data.json'),'w','n','UTF-8');fprintf(f,'%s',jsonencode(data));fclose(f);
f=fopen(fullfile(root,'data.js'),'w','n','UTF-8');fprintf(f,'window.DATA=%s;',jsonencode(data));fclose(f);
report=struct('version',version,'complex_factor_error',err,'steady_tail_error',e,'main_peak_w_pi',cases(2).peak_w_pi,'main_peak',cases(2).peak,'phase_at_pi_defined',false,'passed',true);
f=fopen(fullfile(root,'qa','matlab.json'),'w','n','UTF-8');fprintf(f,'%s',jsonencode(report,PrettyPrint=true));fclose(f);disp(report);
