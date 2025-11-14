function w = fwhm(x, y)
    halfMax = max(y)/2;
    idx = find(y >= halfMax);
    if length(idx) < 2
        w = 1;
    else
        w = idx(end) - idx(1) + 1;
    end
end