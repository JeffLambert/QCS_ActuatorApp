function [Sec, M, binNames, info] = load_qcs_data(filename)
    [~, ~, ext] = fileparts(filename);
    if ~strcmpi(ext, '.mat')
        error('Only .mat files supported');
    end
    S = load(filename);
    if ~all(isfield(S, {'M', 'Sec', 'binNames'}))
        error('MAT file must contain M, Sec, binNames');
    end
    M = S.M; Sec = S.Sec; binNames = S.binNames;
    info.filename = filename;
end