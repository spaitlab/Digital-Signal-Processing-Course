here=fileparts(mfilename('fullpath'));out=fullfile(here,'..');n=0:79;h=ones(1,5)/5;k=0:4;configs=struct([]);
for ratio=[.1,.2,.4,.6,.8]
 w=ratio*pi;x=cos(w*n);y=filter(h,1,x);terms=h.*exp(-1i*w*k);H=sum(terms);steady=real(H*exp(1i*w*n));yc=filter(h,1,exp(1i*w*n));
 fit=[cos(w*n(5:end)).',sin(w*n(5:end)).']\y(5:end).';fit_amp=hypot(fit(1),fit(2));valid=abs(H)>1e-10;
 phase=angle(H);if ~valid,phase=NaN;end
 err=max(abs(y(5:end)-steady(5:end)));assert(err<1e-12);assert(abs(fit_amp-abs(H))<1e-12);assert(max(abs(yc(5:end)-H*exp(1i*w*n(5:end))))<1e-12);
 cumulative=[0,cumsum(terms)];cfg=struct('ratio',ratio,'omega',w,'x',x,'y',y,'steady',steady,'amp',abs(H),'fit_amp',fit_amp,'phase',phase,'phase_valid',valid,'terms_re',real(terms),'terms_im',imag(terms),'sum_re',real(cumulative),'sum_im',imag(cumulative),'steady_error',err);
 if isempty(configs),configs=cfg;else,configs(end+1)=cfg;end
end
ratios=linspace(-2,2,801);response=sum(h.'.*exp(-1i*k.'*(ratios*pi)),1);periodic=sum(h.'.*exp(-1i*k.'*(ratios*pi+2*pi)),1);periodic_error=max(abs(response-periodic));assert(periodic_error<1e-12);
data=struct('n',n,'h',h,'ratios',ratios,'response_re',real(response),'response_im',imag(response),'response_amp',abs(response),'configs',configs);fid=fopen(fullfile(out,'data.json'),'w','n','UTF-8');fprintf(fid,'%s',jsonencode(data));fclose(fid);
report=struct('version',version,'test_ratios',[configs.ratio],'gains',[configs.amp],'fitted_gains',[configs.fit_amp],'max_steady_error',max([configs.steady_error]),'periodic_error',periodic_error,'passed',true);fid=fopen(fullfile(out,'qa','matlab.json'),'w','n','UTF-8');fprintf(fid,'%s',jsonencode(report,PrettyPrint=true));fclose(fid);disp(report);
