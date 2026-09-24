% Standalone full linear convolution. Keep time origins separately.
x=[1 2 3 4];h=[3 2 1];x0=0;h0=0;
nx=x0+(0:numel(x)-1);nh=h0+(0:numel(h)-1);
y=conv(x,h);ny=x0+h0+(0:numel(y)-1);manual=zeros(size(y));
for i=1:numel(y),for j=1:numel(x),k=ny(i)-nx(j)-h0+1;if k>=1 && k<=numel(h),manual(i)=manual(i)+x(j)*h(k);end;end;end
assert(max(abs(y-manual))<1e-12);disp('Rows: time index; output');disp([ny;y]);
f=figure('Visible','off');subplot(3,1,1);stem(nx,x);title('Input');subplot(3,1,2);stem(nh,h);title('Impulse response');subplot(3,1,3);stem(ny,y);title('Full linear convolution');xlabel('n (sample index)');
exportgraphics(f,fullfile(fileparts(mfilename('fullpath')),'first_experiment_matlab.png'));close(f);
