function S = analyze_spatial(M, preIdx, postIdx, opts, bumpedActuator)
    arguments
        M double
        preIdx (1,:) {mustBeInteger, mustBePositive}
        postIdx (1,:) {mustBeInteger, mustBePositive}
        opts struct
        bumpedActuator (1,1) double {mustBeInteger, mustBePositive} = 1
    end
    disp('→ analyze_spatial');

    % === 1. DELTA PROFILE ===
    delta = mean(M(postIdx,:), 1) - mean(M(preIdx,:), 1);
    nCD = size(M, 2);

    % === 2. SCANNER REGION ===
    scanner_lo = round(opts.scannerLoEdge_cdbin);
    scanner_hi = round(opts.scannerHiEdge_cdbin);
    scannerIdx = scanner_lo : scanner_hi;
    scannerIdx = scannerIdx(scannerIdx >= 1 & scannerIdx <= nCD);
    if isempty(scannerIdx)
        error('Scanner region outside data range');
    end

    % === 3. ACTUATOR ZONE MAPPING ===
    Num_Actuators = opts.numActuators;
    if ~isfield(opts, 'numActuators') || Num_Actuators < 1
        Num_Actuators = 1;
    end
    Actuator_Width_Array = opts.actuatorWidth_mm * ones(Num_Actuators, 1);
    Static_Sheet_Width = (opts.scannerHiEdge_cdbin - opts.scannerLoEdge_cdbin) * opts.cdBinWidth_mm;
    Sheet_Width_at_Beam = sum(Actuator_Width_Array);
    Sheet_Width_at_Beam_wOffsets = Sheet_Width_at_Beam - opts.actuatorLoOffset - opts.actuatorHiOffset;
    Linear_Shrinkage = max(0, (Sheet_Width_at_Beam_wOffsets - Static_Sheet_Width) / Sheet_Width_at_Beam_wOffsets);
    Distance_Btwn_Zones = (Actuator_Width_Array * (1 - Linear_Shrinkage)) / opts.cdBinWidth_mm;

    Zone_Boundary = zeros(Num_Actuators + 1, 1);
    Zone_Boundary(1) = opts.scannerLoEdge_cdbin - (opts.actuatorLoOffset * (1 - Linear_Shrinkage)) / opts.cdBinWidth_mm;
    for k = 2:Num_Actuators+1
        Zone_Boundary(k) = Zone_Boundary(k-1) + Distance_Btwn_Zones(k-1);
    end
    Zone_Boundary_Bins = Zone_Boundary;
    Zone_Boundary_Bins = max(1, min(Zone_Boundary_Bins, nCD));

    % === 11. STORE IN S ===
    S.Zone_Boundary_Bins = Zone_Boundary_Bins;
    S.Linear_Shrinkage = Linear_Shrinkage;
    S.Num_Actuators = Num_Actuators;
    S.delta = delta;
    S.bumpedActuator = bumpedActuator;

    % === 4. LOBE — FRACTIONAL BINS ===
    act_lo_bin = S.Zone_Boundary_Bins(bumpedActuator);
    act_hi_bin = S.Zone_Boundary_Bins(bumpedActuator + 1);
    actIdx = act_lo_bin : 0.1 : act_hi_bin;
    actIdx = actIdx(actIdx >= 1 & actIdx <= nCD);
    lobe = interp1(1:nCD, delta, actIdx, 'linear');
    x = 1:length(lobe);

    % === 5–12. REST OF ANALYSIS ===
    totalMass = sum(lobe);
    if totalMass > 0
        cm_local = sum(x .* lobe) / totalMass;
        S.cm_global = cm_local + actIdx(1) - 1;
    else
        S.cm_global = mean(actIdx);
    end
    S.cm_mm = S.cm_global * opts.cdBinWidth_mm;

    S.width_bins = fwhm(x, lobe);
    S.width_mm = S.width_bins * opts.cdBinWidth_mm;

    S.expectedWidth_mm = opts.actuatorWidth_mm * (1 - S.Linear_Shrinkage);
    S.widthDeviation_pct = (S.width_mm - S.expectedWidth_mm) / S.expectedWidth_mm * 100;

    mid = round(length(lobe)/2);
    leftMass = sum(lobe(1:mid));
    rightMass = sum(lobe(mid+1:end));
    total = leftMass + rightMass;
    S.symmetry_pct = 100 * abs(leftMass - rightMass) / (total + eps);

    S.profile_bins = actIdx;
    S.profile_nm = lobe;

    expected_cm_mm = (opts.actuatorLoOffset + opts.actuatorHiOffset)/2 + opts.scannerLoEdge_cdbin * opts.cdBinWidth_mm;
    com_error_mm = S.cm_mm - expected_cm_mm;
    S.alignmentError_mm = com_error_mm;
    S.recommendedLoOffset = opts.actuatorLoOffset - com_error_mm / 2;
    S.recommendedHiOffset = opts.actuatorHiOffset - com_error_mm / 2;

    S.shrinkage_pct = Linear_Shrinkage * 100;
    S.cdBinWidth_mm = opts.cdBinWidth_mm;

    disp('← analyze_spatial');
end