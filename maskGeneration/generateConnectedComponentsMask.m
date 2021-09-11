function ccMask = generateConnectedComponentsMask(detailEnhanced, boundryMaskWidth ...
    , thresholdCC, thresholdAreaOfCC, maskBlurFilt)
    vidTrimmed = zeros(size(detailEnhanced));
    boundryMask = zeros(size(detailEnhanced));
    boundryMask(boundryMaskWidth+1 : end-boundryMaskWidth...
            ,boundryMaskWidth+1 : end-boundryMaskWidth...
            ,boundryMaskWidth+1 : end-boundryMaskWidth) = 1;
        
    vidTrimmed(boundryMask == 1) = detailEnhanced(boundryMask == 1);
    vidTrimmed = minMaxNorm(vidTrimmed);

    vidThresholded = vidTrimmed > thresholdCC;
    CC = bwconncomp(vidThresholded);
    numOfPixels = cellfun(@numel,CC.PixelIdxList);
    largestCCArea = max(numOfPixels);

    largestCCIdx = find(numOfPixels > thresholdAreaOfCC * largestCCArea);
    numOfCC2keep = length(largestCCIdx);
    vidCC = zeros(size(vidTrimmed));
    for j = 1:numOfCC2keep
        vidCC(CC.PixelIdxList{largestCCIdx(j)}) = 1;
    end
    vidCC = minMaxNorm(vidCC);
    %% create mask 
    ccMask = conv3FFT(vidCC, maskBlurFilt);
    ccMask = safeResize(ccMask,size(vidIn));
end

