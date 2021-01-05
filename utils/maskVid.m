function [masked] = maskVid(vidInRaw,MaskRaw)
if(isstring(vidInRaw))
    vidIn = readVideoFromFile(vidInRaw, false);
else
    vidIn = vidInRaw;
end
if(isstring(MaskRaw))
    mask = readVideoFromFile(MaskRaw, false);
else
    mask =MaskRaw;
end
mask = safeResize(mask,size(vidIn));
masked = mask.*vidIn;
%[~, masked] = overlayVids(vidIn,mask,'method','Multiply','verbose',false);
end

