% Standalone experiment: change fs and M one at a time.
fs=12; M=36; n=-M:M; tn=n/fs; x=cos(2*pi*5*tn);
t=linspace(-1,1,801); ref=cos(2*pi*5*t); mask=abs(t)<=0.5+1e-12;
u=fs*t(:)-n; K=ones(size(u)); nz=abs(u)>1e-12; K(nz)=sin(pi*u(nz))./(pi*u(nz));
ys=(K*x.').'; yl=interp1(tn,x,t,'linear'); yz=interp1(tn,x,t,'previous');
e=[yz(mask)-ref(mask);yl(mask)-ref(mask);ys(mask)-ref(mask)];
disp('Rows: hold, linear, finite sinc; columns: RMSE, max error');disp([sqrt(mean(e.^2,2)),max(abs(e),[],2)]);
assert(all(isfinite(e),'all'));
f=figure('Visible','off');plot(t,ref,'--',t,yz,t,yl,t,ys,tn,x,'k.');
xlim([-.5 .5]);ylim([-1.3 1.3]);xlabel('t / s');ylabel('Amplitude');legend('5Hz reference','hold','linear','finite sinc','samples');grid on;
exportgraphics(f,fullfile(fileparts(mfilename('fullpath')),'first_experiment_matlab.png'));close(f);
