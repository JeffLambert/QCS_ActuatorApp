function [M, sec, info, preIdx, postIdx] = generate_qcs_data(opts, noiseList, qcsOpts)
    arguments
        opts struct
        noiseList cell = {}
        qcsOpts struct = struct('sampleRate',1,'scanPeriod',13,'gain',0.5,'delay',0,'tau',5)      
    end
    
bumpedActuator = [];  % ← EMPTY → AUTO-CENTER
    disp('→ generate_qcs_data');

    try
        % === 1. CD GRID ===
        scnr_lo = opts.scannerLoEdge_cdbin;
        scnr_hi = opts.scannerHiEdge_cdbin;
        NumCDbin = opts.cdBin_numOf;
        nCD = NumCDbin;
        if nCD == 0, error('Empty CD grid'); end

        % === 2. TIME GRID ===
        dt = 1 / qcsOpts.sampleRate;
        prescans = 10; postscans = 10;
        t_total = (prescans + postscans) * qcsOpts.scanPeriod + qcsOpts.delay + qcsOpts.tau * 3;
        nTime = round(t_total / dt);
        sec = (0:nTime-1)' * dt;

        % === 3. INITIALIZE ===
        M = zeros(nTime, nCD);

        % === 4. ZONE MAPPING ===
        Num_Actuators = opts.numActuators;
        if ~isfield(opts, 'numActuators') || Num_Actuators < 1
            Num_Actuators = 1;
        end

               % === 5. DYNAMICS ===
bumpHeight = 10 * qcsOpts.gain;  % ← KEEP ORIGINAL SCALING
t_act_start_sec = prescans * qcsOpts.scanPeriod;
t_resp_start_sec = t_act_start_sec + qcsOpts.delay;
t_resp_duration_sec = qcsOpts.scanPeriod;
t_start = round(t_resp_start_sec / dt);
t_end = round((t_resp_start_sec + t_resp_duration_sec) / dt);
t_start = max(1, min(t_start, nTime));
t_end = max(t_start, min(t_end, nTime));
tau_samples = max(1, round(qcsOpts.tau / dt));

        % === DETERMINE BUMPED ACTUATOR ===
        if isempty(bumpedActuator)
            bumpedActuator = round(Num_Actuators / 2);  % AUTO-CENTER
        end
        bumpedActuator = max(1, min(bumpedActuator, Num_Actuators));

        Actuator_Width_Array = opts.actuatorWidth_mm * ones(Num_Actuators, 1);
        Static_Sheet_Width = (scnr_hi - scnr_lo) * opts.cdBinWidth_mm;
        Sheet_Width_at_Beam = sum(Actuator_Width_Array);
        Sheet_Width_at_Beam_wOffsets = Sheet_Width_at_Beam - opts.actuatorLoOffset - opts.actuatorHiOffset;
        Linear_Shrinkage = max(0, (Sheet_Width_at_Beam_wOffsets - Static_Sheet_Width) / Sheet_Width_at_Beam_wOffsets);

        Distance_Btwn_Zones = (Actuator_Width_Array * (1 - Linear_Shrinkage)) / opts.cdBinWidth_mm;

        Zone_Boundary = zeros(Num_Actuators + 1, 1);
        Zone_Boundary(1) = scnr_lo - (opts.actuatorLoOffset * (1 - Linear_Shrinkage)) / opts.cdBinWidth_mm;
        for k = 2:Num_Actuators+1
            Zone_Boundary(k) = Zone_Boundary(k-1) + Distance_Btwn_Zones(k-1);
        end

        Zone_Boundary_Bins = (Zone_Boundary);
        Zone_Boundary_Bins = max(1, min(Zone_Boundary_Bins, nCD));

        % === BUMP SELECTED ACTUATOR (FRACTIONAL BINS) ===
act_lo = Zone_Boundary(bumpedActuator);      % ← FRACTIONAL (no rounding)
act_hi = Zone_Boundary(bumpedActuator + 1);
act_lo = max(1, min(act_lo, nCD));
act_hi = max(1, min(act_hi, nCD));
act_center = (act_lo + act_hi) / 2;

% Fine grid for Gaussian
act_bins = act_lo : 0.1 : act_hi;
act_bins = act_bins(act_bins >= 1 & act_bins <= nCD);

sigma_bins = opts.actuatorWidth_mm / (2 * sqrt(2*log(2)) * opts.cdBinWidth_mm);
lobe_shape = exp(-0.5 * ((act_bins - act_center)/sigma_bins).^2);
lobe_shape = lobe_shape / max(lobe_shape);

% Map to integer bins
int_bins = round(act_bins);
int_bins = unique(int_bins(int_bins >= 1 & int_bins <= nCD));
profile = zeros(1, nCD);
profile(int_bins) = bumpHeight * interp1(act_bins, lobe_shape, int_bins, 'linear', 0);

% === DIAGNOSTIC: INTEGER BINS FOR INFO ===
act_lo_bin = round(act_lo);
act_hi_bin = round(act_hi);
        actIdx = act_lo_bin : act_hi_bin;
        actIdx = actIdx(actIdx >= 1 & actIdx <= nCD);
        % === DIAGNOSTIC: CHECK BUMP IN SCANNER ===
scanner_lo = opts.scannerLoEdge_cdbin;
scanner_hi = opts.scannerHiEdge_cdbin;
inScanner = any(actIdx >= scanner_lo & actIdx <= scanner_hi);
if ~inScanner
    warning('BUMPED ACTUATOR IS OUTSIDE SCANNER REGION!');
end

        if isempty(actIdx)
            error('Bumped actuator zone is empty');
        end




% === TEMPORAL LOOP ===
for t = 1:nTime
    if t >= t_start && t <= t_end
        age = t - t_start;
        response_factor = 1 - exp(-age / tau_samples);
    else
        response_factor = 0;
    end
    M(t, :) = response_factor * profile;
end

        % === 6. NOISE ===
        for i = 1:length(noiseList)
            n = noiseList{i};
            if ~n.enable, continue; end
            level_nm = n.level / 100 * bumpHeight;
            switch lower(n.type)
                case 'gaussian'
                    noise = level_nm * randn(nTime, nCD);
                case '1/f'
                    noise = level_nm * pink_noise(nTime, nCD);
                case 'drift'
                    noise = level_nm * linspace(0,1,nTime)' * ones(1,nCD);
                otherwise
                    noise = 0;
            end
            M = M + noise;
        end

        % === 7. preIdx / postIdx ===
        pre_samples = round(prescans * qcsOpts.scanPeriod / dt);
        post_start_samples = round((prescans * qcsOpts.scanPeriod + qcsOpts.delay + qcsOpts.scanPeriod) / dt);
        post_end_samples = min(nTime, round((prescans + postscans) * qcsOpts.scanPeriod / dt));

        preIdx  = 1 : min(pre_samples, nTime);
        postIdx = post_start_samples : min(post_end_samples, nTime);
        preIdx  = preIdx(preIdx <= nTime);
        postIdx = postIdx(postIdx <= nTime);

        if numel(preIdx) < 2 || numel(postIdx) < 2
            warning('Not enough samples in pre/post windows');
        end

        % === 8. INFO ===
        info = struct(...
            'generatedOn', datestr(now), ...
            'shrinkage_pct', Linear_Shrinkage*100, ...
            'bumpedActuator', bumpedActuator, ...
            'actuatorZone_cd', [act_lo_bin, act_hi_bin], ...
            'timeRange_sec', [0, t_total], ...
            'preIdx', preIdx, ...
            'postIdx', postIdx, ...
            'Linear_Shrinkage', Linear_Shrinkage, ...
            'Zone_Boundary_Bins', Zone_Boundary_Bins, ...
            'Num_Actuators', Num_Actuators ...           
        );

        disp('← generate_qcs_data');

    catch ME
        disp(['Error in generate_qcs_data: ', ME.message]);
        rethrow(ME);
    end
end