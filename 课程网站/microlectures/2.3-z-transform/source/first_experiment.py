from pathlib import Path
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
a=.8;side='right';r=1.2;theta=np.pi/3;N=40;z=r*np.exp(1j*theta)
n=np.arange(N) if side=='right' else -np.arange(1,N+1);terms=(1 if side=='right' else -1)*a**n*z**(-n);s=np.cumsum(terms);inside=r>a if side=='right' else r<a
print('Inside ROC:',inside,'finite sum:',s[-1],'last term modulus:',abs(terms[-1]));print('Algebraic value (not a sum outside ROC):',z/(z-a) if abs(z-a)>1e-12 else 'undefined at pole');assert np.isfinite(s).all()
fig,axes=plt.subplots(1,2,figsize=(10,4));v=np.r_[0,s];axes[0].plot(v.real,v.imag,'.-');axes[0].set(xlabel='Re S_N',ylabel='Im S_N',title='Finite partial sums');axes[0].axis('equal');axes[1].semilogy(np.arange(1,N+1),abs(terms),'.-');axes[1].set(xlabel='Term number',ylabel='Term magnitude');fig.tight_layout();fig.savefig(Path(__file__).with_suffix('.png'));plt.close(fig)
