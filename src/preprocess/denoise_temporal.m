function M_filt = denoise_temporal(M, Sec, cutoff_Hz)
    fs = 1 / median(diff(Sec));
    N = max(3, round(fs / (2 * cutoff_Hz)));
    if mod(N,2)==0, N=N+1; end
    M_filt = movmean(M, N, 1, 'Endpoints','shrink');
    M_filt = movmean(flipud(M_filt), N, 1, 'Endpoints','shrink');
    M_filt = flipud(M_filt);
end