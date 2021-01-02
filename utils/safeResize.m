function [vidOut ] = safeResize(vidIn , resizeFactor)
vidOut = imresize3(vidIn, resizeFactor .* size(vidIn));
vidOut(vidOut > 1) = 1;
vidOut(vidOut < 0) = 0;
end

