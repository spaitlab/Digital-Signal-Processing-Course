from pathlib import Path
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
w=np.linspace(0,np.pi,801);z=np.exp(1j*w);p=.6+.6j
h=(1+1/z)/(1-1.2/z+.72/z**2);g=z*(z+1)/((z-p)*(z-p.conjugate()))
assert max(abs(h-g))<1e-10
phase=np.angle(h);phase[-1]=np.nan;n=np.arange(200);x=np.cos(np.pi*n);y=[]
for k in n:y.append(x[k]+(x[k-1] if k else 0)+1.2*(y[k-1] if k else 0)-.72*(y[k-2] if k>=2 else 0))
assert y[0]==1 and max(abs(np.array(y[160:])))<1e-9
fig,ax=plt.subplots(2,2,figsize=(11,7));ax[0,0].plot(np.cos(2*w),np.sin(2*w),':');ax[0,0].plot([0,-1],[0,0],'o');ax[0,0].plot([.6,.6],[.6,-.6],'x');ax[0,0].set_aspect('equal');ax[0,0].set_title('Complete finite zeros and poles')
ax[0,1].plot(w/np.pi,abs(h));ax[0,1].plot(w/np.pi,abs(g),'--');ax[0,1].set_title('Direct vs geometry');ax[0,1].set_xlabel('omega/pi')
ax[1,0].plot(w/np.pi,phase);ax[1,0].set_title('Phase undefined at pi');ax[1,0].set_xlabel('omega/pi');ax[1,0].set_ylabel('rad')
ax[1,1].stem(n[:40],y[:40],markerfmt='.');ax[1,1].set_title('cos(pi n) startup: nonzero transient');ax[1,1].set_xlabel('n')
fig.tight_layout();fig.savefig(Path(__file__).with_name('first-experiment-python.png'));print('Python standalone passed')
