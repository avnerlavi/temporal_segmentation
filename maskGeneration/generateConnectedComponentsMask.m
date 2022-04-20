function ccMask = generateConnectedComponentsMask(vidIn, boundryMaskWidth ...
    , percentileThreshold, thresholdAreaOfCC, maskBlurFilt, snapshotDir, snapshotFrames)
    vidTrimmed = zeros(size(vidIn));
    boundryMask = zeros(size(vidIn));
    boundryMask(boundryMaskWidth+1 : end-boundryMaskWidth...
            ,boundryMaskWidth+1 : end-boundryMaskWidth...
            ,boundryMaskWidth+1 : end-boundryMaskWidth) = 1;
        
    vidTrimmed(boundryMask == 1) = vidIn(boundryMask == 1);
    vidTrimmed = minMaxNorm(vidTrimmed);

    cutoffThreshold = prctile(vidTrimmed(boundryMaskWidth+1 : end-boundryMaskWidth...
            ,boundryMaskWidth+1 : end-boundryMaskWidth...
            ,boundryMaskWidth+1 : end-boundryMaskWidth), percentileThreshold, 'all');
        
%     vidThresholded = vidTrimmed > thresholdCC;
    vidThresholded = vidTrimmed < cutoffThreshold;
    vidThresholded(boundryMask == 0) = 0;
    saveSnapshots(vidThresholded, snapshotDir, 'thresholded', snapshotFrames);
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
    saveSnapshots(vidCC, snapshotDir, 'connected_components_binary', snapshotFrames);

    %% create mask 
    ccMask = conv3FFT(vidCC, maskBlurFilt);
end

