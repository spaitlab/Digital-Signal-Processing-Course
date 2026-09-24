from pathlib import Path
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
fs=100; f=2; N=200; A=1; start=0
n=start+np.arange(N); t=n/fs; x=A*np.sin(2*np.pi*f*t)
E=np.sum(x**2)
print(f'N={x.size} first={x[0]:.12g} last_t={t[-1]:.12g} sum_squares={E:.12g}')
plt.stem(n,x,markerfmt='.');plt.xlabel('n');plt.ylabel('x[n]');plt.grid()
plt.savefig(Path(__file__).resolve().parent/'first-python.png');plt.close()
