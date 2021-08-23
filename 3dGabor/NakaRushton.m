function [vidOut] = NakaRushton(vidIn, sigma, m, n)
vidOut = vidIn.^(m+n) ./ (vidIn.^n + sigma.^n);
end

