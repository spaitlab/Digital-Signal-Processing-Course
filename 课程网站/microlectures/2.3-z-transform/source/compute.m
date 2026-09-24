root=fileparts(fileparts(mfilename('fullpath')));a=.8;N=1:40;configs=struct([]);j=0;max_relative_error=0;
for side={'right','left'}
 for r=[.4 .8 1 1.2]
  for theta=[0 pi/3]
   z=r*exp(1i*theta);if strcmp(side{1},'right'),n=0:39;terms=a.^n.*z.^(-n);q=a/z;closed=(1-q.^N)/(1-q);inside=r>a;else,n=-1:-1:-40;terms=-a.^n.*z.^(-n);q=z/a;closed=-q*(1-q.^N)/(1-q);inside=r<a;end
   sums=cumsum(terms);if abs(q-1)<1e-12,if strcmp(side{1},'right'),closed=N;else,closed=-N;end;end
   err=max(abs(sums-closed)./max(1,abs(closed)));max_relative_error=max(max_relative_error,err);assert(err<1e-12);
   valid=abs(z-a)>1e-12;if valid,algebraic=z/(z-a);ar=real(algebraic);ai=imag(algebraic);else,ar=NaN;ai=NaN;end
   j=j+1;item=struct('side',side{1},'r',r,'theta',theta,'q_abs',abs(q),'inside',inside,'algebraic_valid',valid,'algebraic_re',ar,'algebraic_im',ai,'term_abs',abs(terms),'sum_re',real(sums),'sum_im',imag(sums));if j==1,configs=item;else,configs(j)=item;end
  end
 end
end
omega=linspace(-pi,pi,121);right_dtft=zeros(size(omega));left_last=zeros(size(omega));
for k=1:numel(omega),z=exp(1i*omega(k));right_dtft(k)=sum(a.^(0:119).*z.^(-(0:119)));left_last(k)=abs(-a^(-120)*z^120);end
exact=1./(1-a*exp(-1i*omega));dtft_error=max(abs(right_dtft-exact));assert(dtft_error<2e-11);
data=struct('a',a,'N',N,'nr',0:8,'xr',a.^(0:8),'nl',-8:-1,'xl',-a.^(-8:-1),'configs',configs,'omega',omega,'dtft_re',real(right_dtft),'dtft_im',imag(right_dtft),'exact_re',real(exact),'exact_im',imag(exact));
report=struct('passed',true,'version',version,'config_count',j,'partial_sum_relative_error',max_relative_error,'dtft_120_terms_max_error',dtft_error,'unit_left_term120_abs',left_last(1),'boundary_term_modulus',1,'right_roc','abs(z)>0.8','left_roc','abs(z)<0.8; origin by extension');
fid=fopen(fullfile(root,'data.json'),'w','n','UTF-8');fwrite(fid,jsonencode(data),'char');fclose(fid);fid=fopen(fullfile(root,'qa','matlab.json'),'w','n','UTF-8');fwrite(fid,jsonencode(report,PrettyPrint=true),'char');fclose(fid);disp(report);
