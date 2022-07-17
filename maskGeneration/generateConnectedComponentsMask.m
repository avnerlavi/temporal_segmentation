function ccMask = generateConnectedComponentsMask(vidIn, boundryMaskWidth, cutoffPercentage ...
    , percentileThreshold, thresholdAreaOfCC, maskBlurFilt, snapshotDir, snapshotFrames)
    vidTrimmed = zeros(size(vidIn));
    boundryMask = zeros(size(vidIn));
    boundryMask(boundryMaskWidth+1 : end-boundryMaskWidth...
            ,boundryMaskWidth+1 : end-boundryMaskWidth...
            ,boundryMaskWidth+1 : end-boundryMaskWidth) = 1;
        
    vidTrimmed(boundryMask == 1) = vidIn(boundryMask == 1);
    vidTrimmed = minMaxNorm(vidTrimmed);
    vidTrimmedCenter = vidTrimmed(boundryMaskWidth+1 : end-boundryMaskWidth...
            ,boundryMaskWidth+1 : end-boundryMaskWidth...
            ,boundryMaskWidth+1 : end-boundryMaskWidth);

%     thresholdCC = cutoffPercentage * max(vidTrimmedCenter(:));
    thresholdCC = prctile(vidTrimmedCenter, percentileThreshold, 'all');
        
    vidThresholded = vidTrimmed > thresholdCC;
    saveSnapshots(vidThresholded, snapshotDir, 'thresholded', snapshotFrames);
    CC = bwconncomp(vidThresholded);
    numOfPixels = cellfun(@numel,CC.PixelIdxList);
    largestCCArea = max(numOfPixels);

    largestCCIdx = find(numOfPixels > thresholdAreaOfCC * largestCCArea);
    numOfCC2keep = length(largestCCIdx);
    vidCC = zeros(size(vidTrimmed));
    for j = 1:numOfCC2keep
        vidCC(CC.PixelIdxList{largestCCIdx(j)}) = numOfPixels(largestCCIdx(j)) / largestCCArea;
    end
    vidCC = minMaxNorm(vidCC);
    saveSnapshots(vidCC, snapshotDir, 'connected_components_binary', snapshotFrames);

    %% create mask 
    ccMask = conv3FFT(vidCC, maskBlurFilt);
end

