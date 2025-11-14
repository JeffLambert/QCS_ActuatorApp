function cb_run_preprocess(src, ~, app)
    M = app.RawMatrix; Sec = app.Sec;
    M = src.preprocess.denoise_temporal(M, Sec, app.spnTemporalCutoff.Value);
    M = src.preprocess.denoise_spatial(M, app.spnSpatialSigma.Value, app.spnBinWidth.Value);
    app.CurrentMatrix = M;
    app.StatusText = 'Preprocessing complete';
end