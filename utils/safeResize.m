function [vidOut ] = safeResize(vidIn , newSize)
vidOut = imresize3(vidIn,  newSize);
vidOut(vidOut > 1) = 1;
vidOut(vidOut < 0) = 0;
end