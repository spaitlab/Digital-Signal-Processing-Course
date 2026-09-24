% Standalone MATLAB script. Change w to compare frequencies.
n=0:79; w=0.2*pi; h=ones(1,5)/5;
x=cos(w*n); y=filter(h,1,x);
H=sum(h.*exp(-1i*w*(0:4))); steady=real(H*exp(1i*w*n));
c=[cos(w*n(5:end)).',sin(w*n(5:end)).']\y(5:end).';
err=max(abs(y(5:end)-steady(5:end))); assert(err<1e-12);
fprintf('Gain %.9f, fitted %.9f, steady error %.3g\n',abs(H),norm(c),err);
if abs(H)>1e-10, fprintf('Phase %.9f rad\n',angle(H)); else, fprintf('Phase undefined at zero response\n'); end
f=figure('Visible','off'); plot(n,x,'.-',n,y,'o-',n,steady,'--');
xlim([0 30]); xlabel('n (sample index)'); ylabel('Amplitude');
legend('input','zero-history output','steady prediction'); grid on;
exportgraphics(f,fullfile(fileparts(mfilename('fullpath')),'first_experiment_matlab.png')); close(f);
