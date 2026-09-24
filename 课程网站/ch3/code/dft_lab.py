"""DFT 教学补充实验；独立编写，不覆盖原书或原 Notebook。"""
import json
from pathlib import Path
import numpy as np
from scipy.signal import windows


def circular_convolution(x, h, length):
    if length < max(len(x), len(h)):
        raise ValueError('本函数要求长度不小于两输入长度，避免 FFT 隐式截断')
    return np.fft.ifft(np.fft.fft(x, length) * np.fft.fft(h, length))


def amplitude_spectrum(x, fs, window=None, nfft=None):
    """实信号单边幅值谱；相干单音幅值校正，不是 PSD。"""
    x = np.asarray(x)
    if np.iscomplexobj(x):
        raise ValueError('单边实信号示例不接受复信号')
    w = np.ones(len(x)) if window is None else np.asarray(window)
    if len(w) != len(x) or abs(w.sum()) < 1e-15:
        raise ValueError('窗长度须与记录长度相同，且窗和非零')
    nfft = len(x) if nfft is None else nfft
    if nfft < len(x):
        raise ValueError('本实验不允许截断记录')
    a = np.abs(np.fft.rfft(x * w, nfft)) / w.sum()
    a[1:-1 if nfft % 2 == 0 else None] *= 2
    return np.fft.rfftfreq(nfft, 1 / fs), a


def run():
    checks = []
    def check(name, actual, expected):
        delta = float(np.max(np.abs(np.asarray(actual) - np.asarray(expected))))
        passed = bool(np.allclose(actual, expected, rtol=1e-10, atol=1e-10))
        checks.append(dict(name=name, passed=passed, max_abs_error=delta))
        if not passed:
            raise AssertionError(name)

    rng = np.random.default_rng(20260917)
    for length in (7, 8, 17):
        x = rng.normal(size=length) + 1j * rng.normal(size=length)
        y = rng.normal(size=length) + 1j * rng.normal(size=length)
        X = np.fft.fft(x)
        k = np.arange(length)
        check(f'roundtrip_{length}', np.fft.ifft(X), x)
        check(f'linearity_{length}', np.fft.fft(2*x-3j*y), 2*X-3j*np.fft.fft(y))
        check(f'circular_shift_{length}', np.fft.fft(np.roll(x, 2)), X*np.exp(-2j*np.pi*k*2/length))
        check(f'parseval_complex_{length}', np.sum(abs(x)**2), np.sum(abs(X)**2)/length)
        realX = np.fft.fft(x.real)
        check(f'real_symmetry_{length}', realX[(-k) % length], realX.conj())

    x, h = [1, 2, 3], [2, 3, 1, 2]
    linear = np.convolve(x, h)
    check('linear_by_hand', linear, [2, 7, 13, 13, 7, 6])
    check('circular_5_folded', circular_convolution(x, h, 5), [8, 7, 13, 13, 7])
    check('linear_via_fft_6', circular_convolution(x, h, 6), linear)
    check('linear_via_fft_8', circular_convolution(x, h, 8), np.pad(linear, (0, 2)))
    # 对完整 DTFT 采样；fft(x, 4) 会截断，不能用它模拟长序列折叠。
    xlong = np.arange(1, 7)
    sampled = np.exp(-2j*np.pi*np.outer(np.arange(4), np.arange(6))/4) @ xlong
    check('frequency_sampling_time_folding', np.fft.ifft(sampled), [6, 8, 3, 4])

    fs, m, padded = 8000, 512, 4096
    n = np.arange(m)
    x = np.cos(2*np.pi*103*n/fs)
    check('zero_padding_same_dtft_grid', np.fft.fft(x, padded)[::8], np.fft.fft(x))
    check('alias_400_to_200_at_fs600', np.cos(2*np.pi*400*n/600), np.cos(2*np.pi*200*n/600))
    coherent = np.fft.fft(np.cos(2*np.pi*7*n/m))
    check('coherent_rectangular_other_bins', np.delete(coherent, [7, m-7]), np.zeros(m-2))
    offgrid = np.fft.fft(np.cos(2*np.pi*7.3*n/m))
    assert np.linalg.norm(np.delete(offgrid, [7, m-7])) > 1
    checks.append(dict(name='offgrid_leakage_present', passed=True))
    for length in (511, 512):
        n = np.arange(length)
        signal = 1.5 + 2.4*np.cos(2*np.pi*19*n/length)
        f, a = amplitude_spectrum(signal, fs)
        check(f'dc_not_doubled_{length}', a[0], 1.5)
        check(f'cosine_amplitude_{length}', a[19], 2.4)
        check(f'frequency_axis_{length}', f[19], 19*fs/length)
    n = np.arange(512)
    _, a = amplitude_spectrum(3*np.cos(np.pi*n), fs)
    check('nyquist_not_doubled', a[-1], 3)
    _, a = amplitude_spectrum(2.4*np.cos(2*np.pi*19*n/512), fs, windows.hann(512, sym=False), 4096)
    check('hann_coherent_gain_padding_amplitude', a[19*8], 2.4)
    for name in ('boxcar', 'bartlett', 'hann', 'hamming', 'blackman', 'gaussian', 'kaiser'):
        fn = getattr(windows, name)
        w = fn(51, 7) if name == 'gaussian' else fn(51, 14) if name == 'kaiser' else fn(51)
        check(f'{name}_symmetric', w, w[::-1])
        f = np.fft.rfftfreq(2048, 1/2)
        check(f'{name}_axis_length', len(f), len(np.fft.rfft(w, 2048)))
    report = dict(scope='独立教学补充脚本数值验证；不等于全部原 Notebook 执行验证',
                  numpy=np.__version__, checks=checks, passed=len(checks),
                  experiments=dict(linear=linear.tolist(), circular5=[8,7,13,13,7],
                  record_samples=m, fs=fs, original_grid_hz=fs/m, padded_grid_hz=fs/padded,
                  observation_seconds=m/fs, window_length=51, window_fft_length=2048))
    destination = Path(__file__).resolve().parents[1]/'reports/dft-chapter-lab.json'
    destination.write_text(json.dumps(report, ensure_ascii=False, indent=2)+'\n', encoding='utf-8')
    print(f'{len(checks)}/{len(checks)} numerical checks passed; {destination}')


if __name__ == '__main__':
    run()
