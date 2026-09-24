% Standalone; zero-state convolution. Finite plots are not convergence proofs.
n=0:127; hs={0.8.^n,1.2.^n,1./(n+1)}; names={'a=0.8','a=1.2','harmonic'};
f=figure('Visible','off');
for j=1:3
 h=hs{j}; y=conv(h,ones(size(n))); y=y(1:128);
 assert(max(abs(y-cumsum(h))./max(1,abs(y)))<1e-12);
 subplot(2,3,j); stem(n,h,'.'); title([names{j} ' h[n]']);
 subplot(2,3,j+3); plot(n,y); title('unit-step output'); xlabel('n');
end
exportgraphics(f,fullfile(fileparts(mfilename('fullpath')),'first-experiment-matlab.png')); close(f);
disp('MATLAB standalone experiment passed');
