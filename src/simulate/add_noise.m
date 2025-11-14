function M_noisy = add_noise(M, params)
    M_noisy = M;
    
    if params.gaussian_std > 0
        M_noisy = M_noisy + params.gaussian_std * randn(size(M));
    end
    
    if params.flicker_amp > 0
        [rows, cols] = size(M);
        f = logspace(-2, 0, rows);
        pink = randn(rows, cols);
        for c = 1:cols
            pink(:,c) = real(ifft(fft(pink(:,c)) ./ sqrt(f')));
        end
        M_noisy = M_noisy + params.flicker_amp * pink;
    end
    
    if params.drift_nm_per_scan > 0
        drift = (0:size(M,1)-1)' * params.drift_nm_per_scan;
        M_noisy = M_noisy + drift;
    end
end