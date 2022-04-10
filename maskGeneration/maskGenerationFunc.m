function [totalMask, maskPyr, detailEnhancementPyr] = maskGenerationFunc(vidIn ...
    , maskParams, cclfParams)

boundryMaskWidth = ceil(cclfParams.facilitationLength/4);

totalMask = ones(size(vidIn));
detailEnhancementPyr = cell(1,maskParams.iterationNumber);
maskPyr = cell(1,maskParams.iterationNumber);

for i = maskParams.iterationNumber:-1:1
    %% detail enhancement
    
    cclfParams.resizeFactors = maskParams.baseResizeFactors * ((i-1)*maskParams.resizeIncrement + 1);
    vidMasked = vidIn .* safeResize(totalMask,size(vidIn));
    detailEnhanced = detailEnhancement3Dfunc(vidMasked,cclfParams,false);
%     detailEnhanced = detailEnhancement3Dfunc(vidIn,cclfParams,false);
    detailEnhanced = minMaxNorm(abs(detailEnhanced));
%     detailEnhanced = detailEnhanced .* safeResize(totalMask,size(detailEnhanced));
    detailEnhancementPyr{i} = detailEnhanced;
    
    %% connected components 
    
    maskBlurFilt = Gaussian3DIso(i, 3*i + 1 - mod(i, 2));
    maskBlurFilt = minMaxNorm(maskBlurFilt) * maskParams.gaussianMaxVal;

    currMask = generateConnectedComponentsMask(detailEnhanced, boundryMaskWidth ...
        , maskParams.percentileThreshold, maskParams.thresholdAreaOfCC, maskBlurFilt);
    currMask = safeResize(currMask,size(vidIn));
    
    maskPyr{i} = currMask;
    totalMask = maskParams.alpha * currMask + (1 - maskParams.alpha) * totalMask;
end
end