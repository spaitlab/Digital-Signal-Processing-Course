% 微课01：只导出本片使用的数据，所有量有明确定义。
here=fileparts(mfilename('fullpath')); out=fullfile(here,'..');
w=linspace(-4*pi,4*pi,1201); t=linspace(-18,18,1201); n=-18:18;
P=3*su(1.5*w); X=1+2*cos(w); N=8; k=-16:16;
xp=double(ismember(mod(n,N),[0,1,7])); dfs=1+2*cos(2*pi*k/N);
Ts=[8,16]; fs=cell(1,2);
for a=1:2
 T=Ts(a); m=-floor(4*pi/(2*pi/T)):floor(4*pi/(2*pi/T));
 fs{a}=struct('T',T,'omega',2*pi*m/T,'c',3/T*su(3*pi*m/T));
end
direct=sum(exp(-1i*(-1:1)'*w),1);
one=[1,1,0,0,0,0,0,1]; d=fft(one);
checks=[max(abs(direct-X)),max(abs(1+2*cos(w+2*pi)-X)),max(abs(d-(1+2*cos(2*pi*(0:7)/8))))];
orth=mean(exp(1i*(2-1)*2*pi*(0:4095)/4096));
assert(all(checks<1e-10) && abs(orth)<1e-10);
data=struct('omega',w,'t',t,'n',n,'P',P,'X',X,'N',N,'k',k,'xp',xp,'dfs',dfs,'fs',{fs});
fid=fopen(fullfile(out,'data.json'),'w','n','UTF-8'); fprintf(fid,'%s',jsonencode(data)); fclose(fid);
qa=struct('engine','MATLAB','version',version,'run_at',char(datetime('now')),'errors',checks,'orthogonality_error',abs(orth),'P0',3,'c0_T8',3/8,'c0_T16',3/16,'Xpi',-1,'passed',true);
fid=fopen(fullfile(out,'qa','matlab.json'),'w','n','UTF-8'); fprintf(fid,'%s',jsonencode(qa,PrettyPrint=true)); fclose(fid);
disp(qa)
function y=su(z)
y=ones(size(z)); nz=z~=0; y(nz)=sin(z(nz))./z(nz);
end
