function noise = pink_noise(nTime, nQCS)
    white = randn(nTime, nQCS);
    freq = (1:nTime/2)';
    pink = white;
    pink(2:end-1,:) = white(2:end-1,:) ./ sqrt(freq);
    noise = ifft([pink; flipud(conj(pink(2:end-1,:)))], 'symmetric');
    noise = real(noise(1:nTime,:));
    noise = noise / std(noise(:));
end