from pathlib import Path
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
f0=5;fs=6;mode='cos'
n=np.arange(fs+1);t=n/fs;tc=np.linspace(0,1,1001);fold=f0-np.floor(f0/fs+.5)*fs
fn=np.cos if mode=='cos' else np.sin
x=fn(2*np.pi*f0*t);candidate=fn(2*np.pi*fold*t)
print(f'fs={fs} samples={len(x)} folded={fold} max_difference={np.max(np.abs(x-candidate)):.4g}')
plt.plot(tc,fn(2*np.pi*f0*tc),label='original');plt.plot(tc,fn(2*np.pi*fold*tc),label='candidate');plt.stem(t,x);plt.xlabel('t (s)');plt.ylabel('amplitude');plt.legend();plt.grid()
plt.savefig(Path(__file__).resolve().parent/'first-python.png');plt.close()
