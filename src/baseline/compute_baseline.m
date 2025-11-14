function baseline = compute_baseline(M, preIdx)
    profile = mean(M(preIdx, :), 1, 'omitnan');
    noise = std(M(preIdx, :), 0, 1, 'omitnan');
    baseline.profile = profile;
    baseline.noise = noise;
end