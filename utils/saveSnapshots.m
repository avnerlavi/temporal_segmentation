function saveSnapshots(vidIn, fileDir, fileName, frames, framesInSnapshot, frameTitle)
if isempty(fileDir)
    return
end

if fileDir(end) ~= '\'
    fileDir = [fileDir, '\'];
end

mkdir(fileDir);

if ~exist('frames', 'var')
    frames = [60, 120];
end

dims = size(vidIn);
frameCount = dims(end);
otherdims = repmat({':'}, 1, ndims(vidIn)-1);
images = cell(1, 2 * length(frames));
for i=1:length(frames)
    if (frames(i) > frameCount)
        disp(['frame ', num2str(frames(i)), ' is out of range']);
        return;
    end
    
    frame = vidIn(otherdims{:}, frames(i));
    hFig = figure;
    set(hFig, 'color', 'white');
    imagesc(frame);
    if exist('frameTitle', 'var')
        title([frameTitle, ', Frame ', num2str(frames(i))]);
    end
    axis off;
    colorbar;
    colormap gray;
    set(gca,'position',[0.05 0.05 0.82 0.9]);
    [cdata, ~] = getframe(hFig);
    imwrite(cdata, [fileDir, fileName, '_frame', num2str(frames(i)), '.jpg']);
    images{2*i-1} = cdata;
    if (i < length(frames))
        images{2*i} = 255*ones(size(cdata,1), 10, 3, 'uint8');
    end
    close(hFig);
end

if ~exist('framesInSnapshot', 'var')
    framesInSnapshot = 2;
end

for i=1:floor(length(frames)/framesInSnapshot)
    concatImages = cell(1, 2*framesInSnapshot-1);
    k = 1;
    concatImageName = [fileDir, fileName, '_concatenated'];
    for j=2*framesInSnapshot*(i-1)+1:2*framesInSnapshot*i-1
        concatImages{k} = images{j};
        if mod(k,2) == 1
            frameNumber = (i-1)*framesInSnapshot + ceil(k/2);
            concatImageName = [concatImageName, '_', num2str(frames(frameNumber))];
        end
        
        k = k + 1;
    end
    
    concatImages = cell2mat(concatImages);
    imwrite(concatImages, [concatImageName, '.jpg']);
end

if (mod(length(frames), framesInSnapshot) > 0) 
    firstRemainingFrameIndex = framesInSnapshot*floor(length(frames)/framesInSnapshot) + 1;
    concatImages = cell(1, 2*(length(frames) - firstRemainingFrameIndex + 1) - 1);
    k = 1;
    concatImageName = [fileDir, fileName, '_concatenated'];
    for j=2*firstRemainingFrameIndex - 1:length(images) - 1
        concatImages{k} = images{j};
        if mod(k,2) == 1
            frameNumber = firstRemainingFrameIndex - 1 + ceil(k/2);
            concatImageName = [concatImageName, '_', num2str(frames(frameNumber))];
        end
        
        k = k + 1;
    end

    concatImages = cell2mat(concatImages);
    imwrite(concatImages, [concatImageName, '.jpg']);
end
end