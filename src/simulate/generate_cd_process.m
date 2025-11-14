function [M, Sec, binNames] = generate_cd_process(params)
    nBins = params.nBins;
    nScans = params.nScans;
    binWidth_mm = params.binWidth_mm;
    actuatorCenters = params.actuatorCenters;
    actuatorWidths = params.actuatorWidths;
    
    Sec = (0:nScans-1)' * params.scanInterval_sec;
    x_mm = (0:nBins-1) * binWidth_mm;
    baseProfile = 50 + 2*sin(0.5*x_mm);
    
    M = repmat(baseProfile, nScans, 1);
    
    for i = 1:length(actuatorCenters)
        c = actuatorCenters(i); w = actuatorWidths(i);
        idx = max(1, c-floor(w/2)) : min(nBins, c+floor(w/2));
        M(:,idx) = M(:,idx) + params.actuatorOffset_nm(i);
    end
    
    binNames = arrayfun(@(i) sprintf('Bin %d', i), 1:nBins, 'UniformOutput', false);
end