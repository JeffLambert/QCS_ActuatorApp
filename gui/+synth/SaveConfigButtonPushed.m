function SaveConfigButtonPushed(app, event)
    synthConfig = synth.gatherSynthConfigFromUI(app);
    [file, path] = uiputfile('*.mat', 'Save Synthetic Config');
    if isequal(file, 0), return; end
    save(fullfile(path, file), 'synthConfig');
    app.StatusLabel.Text = ['Synth config saved: ', file];
end