function M = apply_noise(M, type, level, nTime)
    switch type
        case 'Gaussian'
            M = M + level * 5 * randn(size(M));
        case '1/f (Pink)'
            pink = pink_noise(nTime, size(M,2));
            M = M + level * 5 * pink;
        case 'Quantization'
            q = level * 2;
            M = round(M / q) * q;
        case 'Dropouts'
            mask = rand(size(M)) < level * 0.05;
            M(mask) = 0;
        case 'Baseline Drift'
            drift = (0:nTime-1)' * (level * 0.1);
            M = M + drift;
    end
end