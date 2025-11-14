function savePath = writeConfigToDisk(config)
    % WRITECONFIGTODISK Prompts user for a folder and saves the config struct.

    % Prompt for folder
    folder = uigetdir(pwd, 'Select Site Folder to Save Configuration');
    if folder == 0  % User cancelled
        savePath = '';
        return;
    end

    % Save .mat file in selected folder
    savePath = fullfile(folder, 'config.mat');
    save(savePath, 'config');
end
