function [vidOut] = softTissueEnhancementOverFrames(vidIn,c1,c2,V)
vidOut = zeros(size(vidIn));
for i = 1:size(vidIn, 3)
    vidOut(:,:,i) = softTissueEnhancementPerFrame(vidIn(:,:,i),c1,c2,V);
end
end

