function config = loadConfigFromDisk()
% LOADCONFIGFROMDISK Opens a file dialog and loads the config.mat struct

[file, path] = uigetfile('Sites/*/config.mat', 'Select Config');
if isequal(file, 0)
    config = [];
    return;
end

s = load(fullfile(path, file), 'config');
config = s.config;
end
