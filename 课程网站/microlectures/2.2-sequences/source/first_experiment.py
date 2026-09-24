from pathlib import Path
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
mode='pi';shift=20;n=np.arange(120)
omega=.3*np.pi if mode=='pi' else .3
x=np.cos(omega*n);y=np.cos(omega*(n+shift))
print(f'shift={shift} max_difference={np.max(np.abs(y-x)):.12g}')
plt.stem(n[:41],x[:41],linefmt='C0-',markerfmt='C0o',label='x[n]');plt.stem(n[:41],y[:41],linefmt='C1-',markerfmt='C1.',label='x[n+N]');plt.xlabel('n');plt.ylabel('amplitude');plt.legend();plt.grid()
plt.savefig(Path(__file__).resolve().parent/'first-python.png');plt.close()
