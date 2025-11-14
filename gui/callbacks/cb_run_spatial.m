function cb_run_spatial(src, ~, app)
    M = app.CurrentMatrix; preIdx = 1:100; postIdx = 300:400; % Example
    opts = struct('binWidth_mm', app.spnBinWidth.Value);
    S = src.spatial.analyze_spatial(M, preIdx, postIdx, opts);
    app.LastSpatial = S; app.BinWidth = opts.binWidth_mm;
    app.StatusText = 'Spatial analysis done';
end