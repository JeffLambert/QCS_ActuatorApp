function LoadSynthConfigButtonPushed(app, event)
    [file, path] = uigetfile('*.mat', 'Load Synthetic Config');
    if isequal(file, 0), return; end
    loaded = load(fullfile(path, file));
    if isfield(loaded, 'synthConfig')
        synth.applySynthConfigToUI(app, loaded.synthConfig);
        app.StatusLabel.Text = ['Loaded: ', file];
    else
        app.StatusLabel.Text = 'Invalid config file';
    end
end