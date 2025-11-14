function [zoneEdges_qcs, newLoOffset, newHiOffset] = compute_zone_boundaries(...
    opts, measured_cm_mm, varargin)
% COMPUTE_ZONE_BOUNDARIES  Full QCS mapping with alignment correction
%
% Inputs:
%   opts           - struct with all mapping params
%   measured_cm_mm - Center of Mass from analysis
%   'ActuatorCount' - default 100
%   'UniformWidth'  - default true
%
% Outputs:
%   zoneEdges_qcs  - [N+1 x 1] QCS bin edges
%   newLoOffset    - corrected Lo offset (mm)
%   newHiOffset    - corrected Hi offset (mm)

    p = inputParser;
    addRequired(p, 'opts');
    addRequired(p, 'measured_cm_mm', @isscalar);
    addParameter(p, 'ActuatorCount', 100);
    addParameter(p, 'UniformWidth', true);
    parse(p, opts, measured_cm_mm, varargin{:});

    N = p.Results.ActuatorCount;
    uniform = p.Results.UniformWidth;

    % === ACTUATOR WIDTHS ===
    if uniform
        actWidths = opts.actuatorWidth_mm * ones(N,1);
    else
        % Future: load from table
        actWidths = opts.actuatorWidth_mm * ones(N,1);
    end

    % === BEAM & SCANNER WIDTHS ===
    beamWidth = sum(actWidths);
    beamWithOffsets = beamWidth - opts.actuatorLoOffset - opts.actuatorHiOffset;
    scannerWidth = (opts.scannerHiEdge_cdbin - opts.scannerLoEdge_cdbin) * opts.cdBinWidth_mm;

    % === LINEAR SHRINKAGE ===
    shrinkage = (beamWithOffsets - scannerWidth) / beamWithOffsets;

    % === ZONE BOUNDARIES (CD bins) ===
    zoneBoundary_cd = zeros(N+1, 1);
    zoneBoundary_cd(1) = opts.scannerLoEdge_cdbin - ...
        (opts.actuatorLoOffset * (1 - shrinkage)) / opts.cdBinWidth_mm;

    shrunkWidths_cd = actWidths .* (1 - shrinkage) / opts.cdBinWidth_mm;
    for k = 2:N+1
        zoneBoundary_cd(k) = zoneBoundary_cd(k-1) + shrunkWidths_cd(k-1);
    end

    % === CONVERT TO QCS BINS ===
    qcsPerCD = opts.cdBinWidth_mm / opts.qcsBinWidth_mm;
    zoneEdges_qcs = round(zoneBoundary_cd * qcsPerCD);
    zoneEdges_qcs = max(1, min(zoneEdges_qcs, 1e6));

    % === ALIGNMENT CORRECTION ===
    % Expected CoM = center of actuator zone
    act_lo_mm = opts.actuatorLoOffset;
    act_hi_mm = opts.actuatorHiOffset;
    expected_cm_mm = (act_lo_mm + act_hi_mm) / 2;

    % Error in mm
    com_error_mm = measured_cm_mm - expected_cm_mm;

    % Distribute error to Lo/Hi offsets
    newLoOffset = opts.actuatorLoOffset - com_error_mm / 2;
    newHiOffset = opts.actuatorHiOffset - com_error_mm / 2;

    % Optional: clamp to avoid negative widths
end