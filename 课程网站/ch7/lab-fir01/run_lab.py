"""FIR-01: reproducible, causal moving average experiment and platform audit.

Run without arguments for the fixed four-tap baseline. Exploration results live
in separate directories; comparison never interpolates away timing errors.
"""
from pathlib import Path
import argparse
import hashlib
import json
import platform
from datetime import datetime, timezone

import numpy as np
import scipy
from scipy.signal import lfilter
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

ROOT = Path(__file__).resolve().parent
FS = 1000.0


def response(frequency, taps):
    return np.exp(-2j * np.pi * np.asarray(frequency)[..., None]
                  * np.arange(taps) / FS).mean(axis=-1)


def fit_components(t, y, f2=250.0):
    keep = (t >= .1) & (t < 1.9)
    ts = t[keep]
    design = np.column_stack([np.sin(2*np.pi*50*ts), np.cos(2*np.pi*50*ts),
                              np.sin(2*np.pi*f2*ts), np.cos(2*np.pi*f2*ts),
                              np.ones(ts.size)])
    c = np.linalg.lstsq(design, y[keep], rcond=None)[0]
    amp50=float(np.hypot(c[0], c[1]))
    phase = float(np.arctan2(c[1], c[0])) if amp50 >= 1e-12 else None
    return dict(amplitude_50_hz=amp50,
                amplitude_interference=float(np.hypot(c[2], c[3])),
                phase_50_rad=phase,
                phase_delay_50_ms=-phase/(2*np.pi*50)*1000 if phase is not None else None)


def write_json(path, data):
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2, allow_nan=False)+'\n', encoding='utf-8')


def read_csv(path):
    data = np.loadtxt(path, delimiter=',', skiprows=1, ndmin=2)
    if data.shape != (2001, 3) or not np.all(np.isfinite(data)):
        raise ValueError(f'{path.name}: expected 2001 finite rows, columns t,x,y')
    if not np.all(np.diff(data[:, 0]) > 0):
        raise ValueError(f'{path.name}: time must be strictly increasing')
    return data


def run(taps=4, f2=250.0):
    if not 2 <= taps <= 16 or not 0 < f2 < FS/2 or abs(f2-50) < 1e-6:
        raise ValueError('Use 2..16 taps and 0 < f2 < 500 Hz, excluding 50 Hz')
    baseline = taps == 4 and f2 == 250
    out = ROOT/'results' if baseline else ROOT/'explorations'/f'M{taps}-f{f2:g}'
    out.mkdir(parents=True, exist_ok=True)
    t = np.arange(2001)/FS
    x = np.sin(2*np.pi*50*t) + .8*np.sin(2*np.pi*f2*t)
    b = np.ones(taps)/taps
    y = lfilter(b, [1.0], x)
    np.savetxt(out/'input.csv', np.column_stack([t,x]), delimiter=',',
               header='t,x', comments='', fmt='%.17g')
    np.savetxt(out/'python.csv', np.column_stack([t,x,y]), delimiter=',',
               header='t,x,y', comments='', fmt='%.17g')
    metrics = fit_components(t,y,f2)
    h50, h2 = response(np.array([50,f2]), taps)
    expected = dict(amplitude_50_hz=float(abs(h50)),
                    amplitude_interference=float(.8*abs(h2)),
                    group_delay_ms=(taps-1)/2/FS*1000)
    checks = {}
    def check(name, condition):
        checks[name] = bool(condition)
    check('sample_count_and_endpoint', len(t)==2001 and t[-1]==2)
    impulse = lfilter(b,[1],np.r_[1.,np.zeros(31)])
    check('impulse_response', np.allclose(impulse,np.r_[b,np.zeros(32-taps)],rtol=0,atol=1e-15))
    step = lfilter(b,[1],np.ones(32))
    check('step_startup_and_dc', np.allclose(step,np.minimum(np.arange(1,33)/taps,1),rtol=0,atol=1e-15))
    manual = np.array([sum(x[max(0,n-taps+1):n+1])/taps for n in range(len(x))])
    check('causal_difference_equation', np.max(abs(y-manual))<1e-14)
    analytic = np.imag(h50*np.exp(2j*np.pi*50*t)+.8*h2*np.exp(2j*np.pi*f2*t))
    check('steady_analytic_waveform', np.max(abs(y[taps-1:]-analytic[taps-1:]))<1e-11)
    check('50_hz_amplitude', abs(metrics['amplitude_50_hz']-abs(h50))<1e-11)
    check('interference_amplitude', abs(metrics['amplitude_interference']-.8*abs(h2))<1e-11)
    if abs(h50)>1e-10:
        check('50_hz_phase', metrics['phase_50_rad'] is not None and
              abs(np.angle(np.exp(1j*(metrics['phase_50_rad']-np.angle(h50)))))<1e-10)
    else:
        check('50_hz_null_has_no_reported_phase', metrics['phase_50_rad'] is None)
    if baseline:
        check('quarter_fs_null', metrics['amplitude_interference']<1e-12)
        check('delay_1_5_ms', abs(metrics['phase_delay_50_ms']-1.5)<1e-10)
    report = dict(experiment='FIR-01', baseline=baseline,
                  run_utc=datetime.now(timezone.utc).isoformat(),
                  versions=dict(python=platform.python_version(),numpy=np.__version__,scipy=scipy.__version__),
                  fs_hz=FS,taps=taps,interference_hz=f2,samples=len(t),
                  initial_state='zero',filter_method='scipy.signal.lfilter (causal)',
                  fit_window='0.1 <= t < 1.9; joint sine/cosine + constant fit',
                  input_sha256=hashlib.sha256((out/'input.csv').read_bytes()).hexdigest(),
                  measured=metrics,theory=expected,checks=checks,passed=all(checks.values()))
    write_json(out/'python-metrics.json',report)
    fig, ax = plt.subplots(2,2,figsize=(12,7),layout='constrained')
    show=(t>=.1)&(t<=.16)
    ax[0,0].plot(t[show]*1000,x[show],label='Input',alpha=.65)
    ax[0,0].plot(t[show]*1000,y[show],label='Causal output',lw=2)
    ax[0,0].plot(t[show]*1000,np.sin(2*np.pi*50*t[show]),'--',label='50 Hz input',alpha=.7)
    ax[0,0].set(xlabel='Time (ms)',ylabel='Amplitude',title='Steady waveform: attenuation + delay')
    ax[0,0].legend(fontsize=8)
    ax[0,1].stem(np.arange(taps),b)
    ax[0,1].set(xlabel='Sample n',ylabel='h[n]',title=f'{taps}-tap impulse response')
    freqs=np.linspace(0,500,2001)
    ax[1,0].plot(freqs,abs(response(freqs,taps)))
    ax[1,0].scatter([50,f2],[abs(h50),abs(h2)],color=['tab:green','tab:red'])
    ax[1,0].set(xlabel='Frequency (Hz)',ylabel='Gain',title='Frequency response (not an ideal low-pass)')
    ax[1,1].stem(np.arange(12),y[:12],linefmt='C1-',markerfmt='C1o',label='Actual startup')
    ax[1,1].plot(np.arange(12),analytic[:12],'k--',label='Steady-state formula')
    ax[1,1].set(xlabel='Sample n',ylabel='Amplitude',title='Zero initial state: first samples differ')
    ax[1,1].legend(fontsize=8)
    for a in ax.flat: a.grid(alpha=.2)
    fig.suptitle(f'FIR-01 | fs=1000 Hz | M={taps} | interference={f2:g} Hz')
    fig.savefig(out/'python-overview.png',dpi=160)
    plt.close(fig)
    print(json.dumps(dict(output=str(out),measured=metrics,passed=report['passed'],checks=len(checks)),ensure_ascii=False))
    if not report['passed']: raise RuntimeError('Numerical checks failed')
    return report


def compare(required=()):
    out=ROOT/'results'
    base=read_csv(out/'python.csv')
    platforms={}
    for name in ('matlab','syslab','sysplorer'):
        path=out/f'{name}.csv'
        if not path.exists():
            platforms[name]={'status':'not_run'}
            attempt=out/f'{name}-attempt.json'
            if attempt.exists():
                evidence=json.loads(attempt.read_text(encoding='utf-8'))
                platforms[name]={'status':'blocked','reason':evidence.get('error','No output from attempted run')}
            continue
        try:
            data=read_csv(path)
            metrics=fit_components(data[:,0],data[:,2])
            error=data[:,2]-base[:,2]
            checks=dict(time_axis=np.max(abs(data[:,0]-base[:,0]))<1e-12,
                        input_samples=np.max(abs(data[:,1]-base[:,1]))<1e-10,
                        full_output_including_startup=np.max(abs(error))<1e-10,
                        amplitude_50=abs(metrics['amplitude_50_hz']-abs(response(50,4)))<1e-10,
                        null_250=metrics['amplitude_interference']<1e-12,
                        delay_50=metrics['phase_delay_50_ms'] is not None and abs(metrics['phase_delay_50_ms']-1.5)<1e-9)
            platforms[name]=dict(status='passed' if all(checks.values()) else 'failed',
                                 max_abs_error=float(np.max(abs(error))),rmse=float(np.sqrt(np.mean(error**2))),
                                 measured=metrics,checks={k:bool(v) for k,v in checks.items()},
                                 csv_sha256=hashlib.sha256(path.read_bytes()).hexdigest())
        except (ValueError,OSError) as exc:
            platforms[name]=dict(status='failed',error=str(exc))
    report=dict(experiment='FIR-01',checked_utc=datetime.now(timezone.utc).isoformat(),
                reference='Current local Python run; historical metrics are not imported',
                tolerances=dict(time_s=1e-12,input=1e-10,output=1e-10,null_amplitude=1e-12),
                platforms=platforms)
    write_json(out/'comparison.json',report)
    lines=['# FIR-01 本机跨平台验收','', '| 平台 | 状态 | 相对 Python 最大绝对误差 |', '|---|---|---|']
    for name,r in platforms.items():
        lines.append(f"| {name} | {r['status']} | {r.get('max_abs_error','—')} |")
    lines+=['','not_run 表示没有结果文件；blocked 表示尝试执行但未得到结果，原因见 JSON，二者均不算通过。全序列误差包含启动瞬态；幅相拟合使用 0.1≤t<1.9。',
            '机器可读判据、时间与输入校验见 comparison.json。仅比较已导出的本机结果，不使用历史小结数值充当运行输出。']
    (out/'comparison.md').write_text('\n'.join(lines)+'\n',encoding='utf-8')
    fig,axes=plt.subplots(2,1,figsize=(10,6),layout='constrained')
    mask=(base[:,0]>=.1)&(base[:,0]<=.14)
    axes[0].plot(base[mask,0]*1000,base[mask,2],label='Python',lw=3,alpha=.5)
    for name,r in platforms.items():
        if r['status']!='passed': continue
        values=read_csv(out/f'{name}.csv')
        axes[0].plot(values[mask,0]*1000,values[mask,2],label=name,ls='--')
        axes[1].plot(base[:,0],values[:,2]-base[:,2],label=name,ls='--')
    axes[0].set(xlabel='Time (ms)',ylabel='Output',title='Verified platform outputs')
    axes[1].set(xlabel='Time (s)',ylabel='Error relative to Python',title='All samples, including startup')
    for a in axes:
        a.grid(alpha=.2)
        if a.lines: a.legend()
    fig.savefig(out/'platform-comparison.png',dpi=160)
    plt.close(fig)
    print(json.dumps(report,ensure_ascii=False,indent=2))
    if any(r['status']=='failed' for r in platforms.values()) or any(platforms[n]['status']!='passed' for n in required):
        raise RuntimeError('Platform comparison failed or required platform missing')
    return report


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--taps',type=int,default=4)
    parser.add_argument('--f2',type=float,default=250)
    parser.add_argument('--compare',action='store_true')
    parser.add_argument('--require',nargs='*',choices=['matlab','syslab','sysplorer'],default=[])
    args=parser.parse_args()
    if args.compare: compare(args.require)
    else: run(args.taps,args.f2)
