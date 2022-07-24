vidFileName = 'man_running';
inFileDir = [root,'\resources\', vidFileName, '.avi'];
vidMatrixOrig = readVideoFromFile(inFileDir, false);
groundTruth = readVideoFromFile([root, '\resources\', vidFileName, '_gt.avi'], true);
masked = groundTruth .* vidMatrixOrig;
repetitionLength = 8;
repetitionCount = floor(size(vidMatrixOrig, 3) / repetitionLength);
outputLength = repetitionLength * repetitionCount;
slowerNoise = zeros(size(vidMatrixOrig, 1), size(vidMatrixOrig, 2), outputLength);
GTFrames = false(size(vidMatrixOrig, 1), size(vidMatrixOrig, 2), outputLength);
shuffled = zeros(size(vidMatrixOrig, 1), size(vidMatrixOrig, 2), outputLength);
randomFrameIndices = randi([1 size(vidMatrixOrig, 3)], repetitionCount);

for i=1:repetitionCount
    frame = vidMatrixOrig(:, :, randomFrameIndices(i));
    GTFrames(:, :, repetitionLength*(i-1)+1:repetitionLength*i) = ...
        repmat(groundTruth(:, :, (repetitionLength-1)*i+1), 1, 1, repetitionLength);
    shuffled(:, :, repetitionLength*(i-1)+1:repetitionLength*i) = ...
        repmat(frame, 1, 1, repetitionLength);
end

for i=1:repetitionCount
    frame = vidMatrixOrig(:, :, (repetitionLength-1)*i+1);
    slowerNoise(:, :, repetitionLength*(i-1)+1:repetitionLength*i) = ...
        repmat(frame, 1, 1, repetitionLength);
    %     slowerGTPosition = repmat(gtFrame, 1, 1, repetitionLength);
%     slowerNoise(gtFrame > 0, repetitionLength*(i-1)+1:repetitionLength*i) = 1;
end

slowerNoise(groundTruth(:, :, 1:outputLength)) = masked(groundTruth(:, :, 1:outputLength));

slowerNoise(and(GTFrames, ~groundTruth(:, :, 1:outputLength))) = ...
    shuffled(and(GTFrames, ~groundTruth(:, :, 1:outputLength)));