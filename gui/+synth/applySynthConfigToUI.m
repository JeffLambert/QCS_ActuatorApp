function applySynthConfigToUI(app, synthConfig)
    app.SampleRateEditField.Value     = synthConfig.sampleRate;
    app.ScanTimeEditField.Value       = synthConfig.scanPeriod;
    app.ResponseGainEditField.Value   = synthConfig.gain;
    app.TimeDelayEditField.Value      = synthConfig.delay;
    app.TimeConstantEditField.Value   = synthConfig.tau;

    % Clear noise
    for i = 1:4
        eval(['app.EnableNoise', num2str(i), 'CheckBox.Value = false;']);
        eval(['app.Level', num2str(i), 'EditField.Value = 0;']);
    end

    % Apply noise
    for i = 1:min(4, length(synthConfig.noise))
        n = synthConfig.noise{i};
        eval(['app.EnableNoise', num2str(i), 'CheckBox.Value = true;']);
        eval(['app.Noise', num2str(i), 'DropDown.Value = n.type;']);
        eval(['app.Level', num2str(i), 'EditField.Value = n.level;']);
    end
end