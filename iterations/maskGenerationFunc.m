function [totalMask, maskPyr, detailEnhancementPyr] = maskGenerationFunc(vidIn ...
    , maskParams, cclfParams)

boundryMaskWidth = ceil(cclfParams.facilitationLength/4);
maskBlurFilt = Gaussian3DIso(maskParams.gaussianSigma, maskParams.gaussianShape);
maskBlurFilt = minMaxNorm(maskBlurFilt) * maskParams.gaussianMaxVal;

totalMask = ones(size(vidIn));
detailEnhancementPyr = cell(1,maskParams.iterationNumber);
maskPyr = cell(1,maskParams.iterationNumber);

for i=1:maskParams.iterationNumber 
    %% detail enhancement
    cclfParams.resizeFactors = maskParams.baseResizeFactors * ((i-1)*maskParams.resizeIncrement + 1);
    vidMasked = vidIn .* safeResize(totalMask,size(vidIn));
    detailEnhanced = detailEnhancement3Dfunc(vidMasked,cclfParams,false);
    detailEnhanced = minMaxNorm(abs(detailEnhanced));
    detailEnhancementPyr{i} = detailEnhanced;
    %% connected components 
    vidTrimmed = zeros(size(detailEnhanced));
    boundryMask = zeros(size(detailEnhanced));
    boundryMask(boundryMaskWidth+1 : end-boundryMaskWidth...
            ,boundryMaskWidth+1 : end-boundryMaskWidth...
            ,boundryMaskWidth+1 : end-boundryMaskWidth) = 1;
        
    vidTrimmed(boundryMask == 1) = detailEnhanced(boundryMask == 1);
    vidTrimmed = minMaxNorm(vidTrimmed);

    vidThresholded = vidTrimmed > maskParams.thresholdCC;
    CC = bwconncomp(vidThresholded);
    numOfPixels = cellfun(@numel,CC.PixelIdxList);
    largestCCArea = max(numOfPixels);

    largestCCIdx = find(numOfPixels > maskParams.thresholdAreaOfCC * largestCCArea);
    numOfCC2keep = length(largestCCIdx);
    vidCC = zeros(size(vidTrimmed));
    for j = 1:numOfCC2keep
        vidCC(CC.PixelIdxList{largestCCIdx(j)}) = 1;
    end
    vidCC = minMaxNorm(vidCC);
    %% create mask 
    currMask = conv3FFT(vidCC,maskBlurFilt);
    currMask = safeResize(currMask,size(vidIn));
    maskPyr{i} = currMask;
    totalMask = maskParams.alpha * currMask + (1 - maskParams.alpha) * totalMask;
end
end

