"""Standalone offline reconstruction. Output image is saved beside this file."""
from pathlib import Path
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
fs=12;M=36;n=np.arange(-M,M+1);tn=n/fs;x=np.cos(2*np.pi*5*tn)
t=np.linspace(-1,1,801);ref=np.cos(2*np.pi*5*t);mask=np.abs(t)<=.5+1e-12
ys=np.sinc(fs*t[:,None]-n)@x
yl=np.interp(t,tn,x);yz=x[np.clip(np.searchsorted(tn,t,side='right')-1,0,len(x)-1)]
assert np.max(np.abs(np.sinc(n[:,None]-n)@x-x))<1e-12
fig,ax=plt.subplots(figsize=(11,4));ax.plot(t,ref,color='gray',label='5Hz reference')
for label,y in [('hold',yz),('linear',yl),('finite sinc',ys)]:
 e=y[mask]-ref[mask];print(label,'RMSE',np.sqrt(np.mean(e*e)),'max error',np.max(np.abs(e)));ax.plot(t,y,label=label)
ax.plot(tn,x,'k.',label='samples');ax.set(xlim=(-.5,.5),ylim=(-1.3,1.3),xlabel='t / s',ylabel='Amplitude');ax.legend();fig.tight_layout();fig.savefig(Path(__file__).with_suffix('.png'));plt.close(fig)
