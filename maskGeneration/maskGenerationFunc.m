function [totalMask, maskPyr, detailEnhancementPyr] = maskGenerationFunc(vidIn ...
    , maskParams, cclfParams)

boundryMaskWidth = ceil(cclfParams.facilitationLength/4);

totalMask = ones(size(vidIn));
detailEnhancementPyr = cell(1,maskParams.iterationNumber);
maskPyr = cell(1,maskParams.iterationNumber);
facilitationSnapshotDir = cclfParams.snapshotDir;
baseSnapshotFrames = [60, 120];

for i = 1:maskParams.iterationNumber
    %% detail enhancement
    
    cclfParams.resizeFactors = maskParams.baseResizeFactors * ((i-1)*maskParams.resizeIncrement + 1);
    
    cclfParams.snapshotDir = [facilitationSnapshotDir, '/scale_', num2str(i)];
    tempSnapshotDir = [maskParams.snapshotDir, '/scale_', num2str(i)];
    relativeSnapshotFrames = floor(baseSnapshotFrames .* cclfParams.resizeFactors(3));
    
%     vidMasked = vidIn .* safeResize(totalMask, size(vidIn));
%     detailEnhanced = detailEnhancement3Dfunc(vidMasked, cclfParams, relativeSnapshotFrames, false);
    detailEnhanced = detailEnhancement3Dfunc(vidIn, cclfParams, relativeSnapshotFrames, false);
    saveSnapshots(detailEnhanced, cclfParams.snapshotDir, ['detail_enhancement_output_scale_', num2str(i)], ...
        relativeSnapshotFrames);
    
    detailEnhanced = minMaxNorm(abs(detailEnhanced));
    saveSnapshots(detailEnhanced, cclfParams.snapshotDir, ['detail_enhancement_output_abs_normed_scale_', num2str(i)], ...
        relativeSnapshotFrames);
    
%     detailEnhanced = detailEnhanced .* safeResize(totalMask,size(detailEnhanced));
    detailEnhancementPyr{i} = detailEnhanced;
    
    %% connected components 
    
    maskBlurFilt = Gaussian3DIso(1, maskParams.gaussianShape);
    maskBlurFilt = minMaxNorm(maskBlurFilt) * maskParams.gaussianMaxVal;

    currMask = generateConnectedComponentsMask(detailEnhanced, boundryMaskWidth ...
        , maskParams.cutoffPercentage, maskParams.percentileThreshold, ...
        maskParams.thresholdAreaOfCC, maskBlurFilt, tempSnapshotDir, relativeSnapshotFrames);
    currMask = safeResize(currMask,size(vidIn));
    
    saveSnapshots(currMask, tempSnapshotDir, 'connected_components_blurred', baseSnapshotFrames);
    
    maskPyr{i} = currMask;
    totalMask = maskParams.alpha * currMask + (1 - maskParams.alpha) * totalMask;
end
end