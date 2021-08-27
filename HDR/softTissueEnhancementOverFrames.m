function [vidOut] = softTissueEnhancementOverFrames(vidIn)
vidOut = zeros(size(vidIn));
for i = 1:size(vidIn, 3)
    vidOut(:,:,i) = softTissueEnhancementPerFrame(vidIn(:,:,i));
end
end

