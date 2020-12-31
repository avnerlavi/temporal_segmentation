function [vidOut] = minMaxNorm(vidIn)
vidOut = vidIn - min(vidIn, [], 'all');
vidOut = vidOut / max(vidOut, [], 'all');
end
