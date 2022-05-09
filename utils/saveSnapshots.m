function saveSnapshots(vidIn, fileDir, fileName, frames, frameTitle)
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
images = cell(1, length(frames));
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
        title([frameTitle, ', Frame ', num2str(i)]);
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

    images = cell2mat(images);
    imwrite(images, [fileDir, fileName, '_concatenated', '.jpg']);
end