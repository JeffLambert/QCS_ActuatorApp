function applyConfigToUI(app, config)
    % Force internal to mm
    app.InternalQCSBinWidth     = config.qcsBinWidth_mm;
    app.InternalCDBinWidth      = config.cdBinWidth_mm;
    app.InternalActuatorWidth   = config.actuatorWidth_mm;
    
    % Populate metadata
    app.NumOfActuatorsEditField.Value = config.NumOfAct;
    app.SiteNameEditField.Value     = config.siteName;
    app.CDControlDropDown.Value     = config.cdControl;
    app.ScannerIDEditField.Value    = config.scannerID;
    app.LoActuatorOffsetEditField.Value = config.actuatorLoOffset;
    app.HiActuatorOffsetEditField.Value = config.actuatorHiOffset;
    app.LoScannerEdge_cdbinEditField.Value    = config.scannerLoEdge_cdbin;
    app.HiScannerEdge_cdbinEditField.Value    = config.scannerHiEdge_cdbin;
    app.NumOfQCSbinsEditField.Value    =  config.qcsBin_numOf;
    app.NumOfCDbinsEditField.Value    =  config.cdBin_numOf;
    
    % Update display based on current unit preference
    app.updateUnitLabelsAndDisplay();
end