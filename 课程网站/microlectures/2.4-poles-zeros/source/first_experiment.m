% Standalone MATLAB, basic functions only; zero-state stable causal system.
w=linspace(0,pi,801);z=exp(1i*w);p=.6+.6i;
H=(1+z.^-1)./(1-1.2*z.^-1+.72*z.^-2);G=z.*(z+1)./((z-p).*(z-conj(p)));
assert(max(abs(H-G))<1e-10);phase=angle(H);phase(end)=NaN;
n=0:199;x=cos(pi*n);y=filter([1 1],[1 -1.2 .72],x);
assert(abs(y(1)-1)<1e-12 && max(abs(y(161:end)))<1e-9);
f=figure('Visible','off');tiledlayout(2,2);
nexttile;plot(cos(w*2),sin(w*2),':');hold on;plot([0 -1],[0 0],'o');plot([.6 .6],[.6 -.6],'x');axis equal;title('Complete finite zeros and poles');
nexttile;plot(w/pi,abs(H),w/pi,abs(G),'--');xlabel('omega/pi');title('Direct vs geometry');
nexttile;plot(w/pi,phase);xlabel('omega/pi');ylabel('rad');title('Phase undefined at pi');
nexttile;stem(n(1:40),y(1:40),'.');xlabel('n');title('cos(pi n) startup: nonzero transient');
exportgraphics(f,fullfile(fileparts(mfilename('fullpath')),'first-experiment-matlab.png'));close(f);disp('MATLAB standalone passed');
