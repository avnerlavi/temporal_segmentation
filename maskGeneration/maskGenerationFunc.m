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
%     vidMasked = vidIn .* safeResize(totalMask,size(vidIn));
%     detailEnhanced = detailEnhancement3Dfunc(vidMasked,cclfParams,false);
    detailEnhanced = detailEnhancement3Dfunc(vidIn,cclfParams,false);
    detailEnhanced = minMaxNorm(abs(detailEnhanced));
    detailEnhanced = detailEnhanced .* safeResize(totalMask,size(detailEnhanced));
    detailEnhancementPyr{i} = detailEnhanced;
    %% connected components 
    currMask = generateConnectedComponentsMask(detailEnhanced, boundryMaskWidth ...
        , maskParams.percentileThreshold, maskParams.thresholdAreaOfCC, maskBlurFilt);
    currMask = safeResize(currMask,size(vidIn));
    
    maskPyr{i} = currMask;
    totalMask = maskParams.alpha * currMask + (1 - maskParams.alpha) * totalMask;
end