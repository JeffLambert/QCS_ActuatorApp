function p = default_params()
    p.binWidth_mm = 0.25;
    p.actuatorWidth_bins = 5;
    p.actuatorCenter_bin = 50;
    p.bumpAmplitude_nm = 10;
    p.sigma_spatial_mm = 0.4;
    p.temporal_cutoff_Hz = 0.05;
    p.clusterFrac = 0.7;
    p.topN = 10;
end