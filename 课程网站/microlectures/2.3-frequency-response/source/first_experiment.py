"""Standalone NumPy/Matplotlib experiment; outputs beside this script."""
from pathlib import Path
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
n=np.arange(80);w=.2*np.pi;h=np.ones(5)/5
x=np.cos(w*n);y=np.convolve(x,h)[:len(n)]
H=np.sum(h*np.exp(-1j*w*np.arange(5)));steady=np.real(H*np.exp(1j*w*n))
coef=np.linalg.lstsq(np.column_stack([np.cos(w*n[4:]),np.sin(w*n[4:])]),y[4:],rcond=None)[0]
error=float(np.max(np.abs(y[4:]-steady[4:])))
assert error<1e-12
print('gain=',abs(H),' fitted=',np.linalg.norm(coef),' phase=',np.angle(H) if abs(H)>1e-10 else 'undefined',' steady error=',error)
fig,ax=plt.subplots(figsize=(10,4));ax.plot(n,x,'.-',label='input');ax.plot(n,y,'o-',label='zero-history output');ax.plot(n,steady,'--',label='steady prediction');ax.axvspan(0,3.5,color='gray',alpha=.15);ax.set(xlim=(0,30),xlabel='n (sample index)',ylabel='Amplitude');ax.legend();fig.tight_layout();fig.savefig(Path(__file__).with_suffix('.png'));plt.close(fig)
