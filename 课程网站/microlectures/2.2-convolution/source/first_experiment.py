from pathlib import Path
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
x=np.array([1,2,3,4]);h=np.array([3,2,1]);x0=0;h0=0
nx=x0+np.arange(len(x));nh=h0+np.arange(len(h));y=np.convolve(x,h);ny=x0+h0+np.arange(len(y))
manual=[sum(v*h[n-k-h0] for k,v in zip(nx,x) if 0<=n-k-h0<len(h)) for n in ny]
assert np.array_equal(manual,y);print('time:',ny,'output:',y)
fig,axes=plt.subplots(3,1,figsize=(9,7))
for ax,xs,ys,title in zip(axes,[nx,nh,ny],[x,h,y],['Input','Impulse response','Full linear convolution']):ax.stem(xs,ys);ax.set_title(title);ax.set_xlabel('n (sample index)')
fig.tight_layout();fig.savefig(Path(__file__).with_suffix('.png'));plt.close(fig)
