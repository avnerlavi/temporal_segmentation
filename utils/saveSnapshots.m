function saveSnapshots(vidIn, fileDir, fileName, frames)
if fileDir(end) ~= '\'
    fileDir = [fileDir, '\'];
end

mkdir(fileDir);

if ~exist('frames','var')
    frames = [60, 120];
end

dims = size(vidIn);
frameCount = dims(end);
otherdims = repmat({':'},1,ndims(vidIn)-1);
for i=1:length(frames)
    if (frames(i) > frameCount)
        disp(['frame ', frames(i), ' is out of range']);
        return;
    end
    
    frame = vidIn(otherdims{:}, frames(i));
    hFig = figure;
    set(hFig, 'color', 'white');
    imagesc(frame);
    axis off;
    colorbar;
    colormap gray;
    set(gca,'position',[0.05 0.05 0.82 0.9]);
    [cdata, ~] = getframe(hFig);
    imwrite(cdata, [fileDir, fileName, '_frame', num2str(frames(i)) ,'.jpg']);
    close(hFig);
end   

end