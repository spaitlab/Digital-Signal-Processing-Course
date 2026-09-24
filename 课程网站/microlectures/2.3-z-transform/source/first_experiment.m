% Standalone bilateral z-transform partial sums. Change one parameter at a time.
a=.8; side='right'; r=1.2; theta=pi/3; N=40; z=r*exp(1i*theta);
if strcmp(side,'right'),n=0:N-1;terms=a.^n.*z.^(-n);inside=r>a;else,n=-1:-1:-N;terms=-a.^n.*z.^(-n);inside=r<a;end
S=cumsum(terms);fprintf('Inside ROC: %d; last term modulus %.8g\n',inside,abs(terms(end)));disp('Finite partial sum:');disp(S(end));
if abs(z-a)>1e-12,disp('Algebraic value (not a series sum outside ROC):');disp(z/(z-a));else,disp('Pole: algebraic value undefined');end
assert(all(isfinite(S)));
f=figure('Visible','off');subplot(1,2,1);plot(real([0 S]),imag([0 S]),'.-');axis equal;grid on;xlabel('Re S_N');ylabel('Im S_N');title('Finite partial sums');subplot(1,2,2);semilogy(1:N,abs(terms),'.-');xlabel('Term number');ylabel('Term magnitude');grid on;
exportgraphics(f,fullfile(fileparts(mfilename('fullpath')),'first_experiment_matlab.png'));close(f);
