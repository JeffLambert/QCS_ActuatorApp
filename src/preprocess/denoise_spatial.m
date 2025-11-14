function M_smooth = denoise_spatial(M_filt, sigma_mm, binWidth_mm)
    sigma_bins = sigma_mm / binWidth_mm;
    halfW = ceil(3*sigma_bins);
    xg = -halfW:halfW;
    h = exp(-0.5*(xg/sigma_bins).^2); h = h/sum(h);
    Apad = [repmat(M_filt(:,1),1,halfW), M_filt, repmat(M_filt(:,end),1,halfW)];
    M_smooth = conv2(Apad, h', 'valid');
end