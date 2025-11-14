function M_bump = simulate_bump_response(M_clean, Sec, params)
    M_bump = M_clean;
    t = Sec;
    t_start = params.bumpStart_sec;
    t_rise = params.riseTime_sec;
    t_hold = params.holdTime_sec;
    
    idx = t >= t_start;
    response = zeros(size(t));
    response(idx) = 1 - exp(-(t(idx) - t_start)/t_rise);
    response(t > t_start + t_hold) = exp(-(t(t > t_start + t_hold) - (t_start + t_hold))/t_rise);
    
    c = params.actuatorCenter; w = params.actuatorWidth;
    idx_bins = max(1, c-floor(w/2)) : min(size(M,2), c+floor(w/2));
    M_bump(:, idx_bins) = M_bump(:, idx_bins) + params.bumpAmplitude_nm * response;
end