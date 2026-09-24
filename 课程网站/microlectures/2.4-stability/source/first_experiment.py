"""Standalone: Python + numpy + matplotlib. Finite curves are not infinite-sum proofs."""
from pathlib import Path
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
n=np.arange(128);fig,axes=plt.subplots(2,3,figsize=(12,6))
for j,(name,h) in enumerate([('a=0.8',.8**n),('a=1.2',1.2**n),('harmonic',1/(n+1))]):
 y=np.convolve(h,np.ones(128))[:128]
 assert np.allclose(y,np.cumsum(h))
 axes[0,j].stem(n,h,markerfmt='.');axes[0,j].set_title(name+' h[n]')
 axes[1,j].plot(n,y);axes[1,j].set_title('unit-step output');axes[1,j].set_xlabel('n')
fig.tight_layout();fig.savefig(Path(__file__).with_name('first-experiment-python.png'));print('Python experiment passed')
