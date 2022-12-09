function vid_matrix = readVideoFromFile(file_path,isBinary,frame_range,bbox)

InVid = VideoReader(file_path);

if exist('frame_range','var')
    numFrames = frame_range(2) - frame_range(1);
else
    numFrames = ceil(InVid.FrameRate*InVid.Duration);
end

if ~exist('bbox','var')
    bbox = [1,1,InVid.Width-1,InVid.Height-1];
end
bbox = round(bbox);
if isBinary
    vid_matrix = false(bbox(4)+1, bbox(3)+1, numFrames);
else
    vid_matrix = zeros(bbox(4)+1, bbox(3)+1, numFrames);
end

if(exist('frame_range','var'))
    for i= 1:size(vid_matrix,3)
      frame = read(InVid,frame_range(1)+i-1);
      frame = rgb2gray(frame);
      if(isBinary)
            frame = imbinarize(frame);
        else
            frame = im2double(frame);
        end
      vid_matrix(:,:,i) = frame(bbox(2):bbox(2)+bbox(4),bbox(1):bbox(1)+bbox(3));
    end
else
    n = 1;
    while hasFrame(InVid)
        frame = rgb2gray(readFrame(InVid));
        if(isBinary)
            frame = imbinarize(frame);
        else
            frame = im2double(frame);
        end
        vid_matrix(:,:,n) = frame(bbox(2):bbox(2)+bbox(4),bbox(1):bbox(1)+bbox(3));
        n = n + 1;
    end
    
    if numFrames >= n
        vid_matrix = vid_matrix(:, :, 1:n-1);
    end
end
end