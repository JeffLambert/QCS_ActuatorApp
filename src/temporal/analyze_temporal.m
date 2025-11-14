function T = analyze_temporal(M, Sec, bumpStart, bumpEnd, lobeIdx)
    t = Sec;
    idx = t >= bumpStart & t <= bumpEnd;
    response = mean(M(idx, lobeIdx), 2);
    T.riseTime = estimate_rise_time(t(idx), response);
end

function tau = estimate_rise_time(t, y)
    ynorm = (y - min(y)) / (max(y) - min(y));
    t10 = interp1(ynorm, t, 0.1); t90 = interp1(ynorm, t, 0.9);
    tau = t90 - t10;
end