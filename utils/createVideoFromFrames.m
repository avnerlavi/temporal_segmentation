function vidOut = createVideoFromFrames(frameDirPath)
dirContentData = dir([frameDirPath, '\*.png']);
numberOfFrames = size(dirContentData, 1);

frame = imread([frameDirPath, '\', dirContentData(1).name]);
vidOut = zeros([size(frame), numberOfFrames]);
vidOut(:,:,:,1) = frame;

for i=2:numberOfFrames
    frame = imread([frameDirPath, '\', dirContentData(i).name]);
    vidOut(:,:,:,i) = frame;
end

% vidOut = vidOut(:,:,1,:) > 50 & vidOut(:,:,1,:) < 80 & vidOut(:,:,1,:) ~= vidOut(:,:,2,:);
end

