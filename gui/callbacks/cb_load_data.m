function cb_load_data(src, ~, app)
    [file, path] = uigetfile('*.mat');
    if isequal(file,0), return; end
    [Sec, M, ~, info] = src.data.load_qcs_data(fullfile(path,file));
    app.Sec = Sec; app.RawMatrix = M; app.CurrentMatrix = M;
    app.StatusText = sprintf('Loaded: %s', info.filename);
end