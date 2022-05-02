function [totalMask, maskPyr, detailEnhancementPyr] = maskGenerationFunc(vidIn ...
    , maskParams, cclfParams)

boundryMaskWidth = ceil(cclfParams.facilitationLength/4);

totalMask = ones(size(vidIn));
detailEnhancementPyr = cell(1,maskParams.iterationNumber);
maskPyr = cell(1,maskParams.iterationNumber);
facilitationSnapshotDir = cclfParams.snapshotDir;

for i = 1:maskParams.iterationNumber
    %% detail enhancement
    
    cclfParams.resizeFactors = maskParams.baseResizeFactors * ((i-1)*maskParams.resizeIncrement + 1);
    
    tempSnapshotDir = '';
    cclfParams.snapshotDir = '';
    if i == maskParams.iterationNumber
        cclfParams.snapshotDir = facilitationSnapshotDir;
        tempSnapshotDir = maskParams.snapshotDir;
    end
    
    snapshotFrames = [60 * cclfParams.resizeFactors(3), 120 * cclfParams.resizeFactors(3)];
    
    vidMasked = vidIn .* safeResize(totalMask,size(vidIn));
    detailEnhanced = detailEnhancement3Dfunc(vidMasked,cclfParams,false);
%     detailEnhanced = detailEnhancement3Dfunc(vidIn,cclfParams,false);
    saveSnapshots(detailEnhanced, cclfParams.snapshotDir, ['detail_enhancement_output_scale_', num2str(i)], ...
        snapshotFrames);
    detailEnhanced = minMaxNorm(abs(detailEnhanced));
%     detailEnhanced = detailEnhanced .* safeResize(totalMask,size(detailEnhanced));
    detailEnhancementPyr{i} = detailEnhanced;
    
    %% connected components 
    
    maskBlurFilt = Gaussian3DIso(i, maskParams.gaussianShape);
    maskBlurFilt = minMaxNorm(maskBlurFilt) * maskParams.gaussianMaxVal;

    currMask = generateConnectedComponentsMask(detailEnhanced, boundryMaskWidth ...
        , maskParams.percentileThreshold, maskParams.thresholdAreaOfCC, maskBlurFilt, ...
        tempSnapshotDir, snapshotFrames);
    currMask = safeResize(currMask,size(vidIn));
    
    saveSnapshots(currMask, tempSnapshotDir, 'connected_components_blurred', snapshotFrames);

    
    maskPyr{i} = currMask;
    totalMask = maskParams.alpha * currMask + (1 - maskParams.alpha) * totalMask;
end
end