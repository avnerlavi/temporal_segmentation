function vid_matrix = readVideoFromFile(file_path,isBinary)

    InVid = VideoReader(file_path);
    numFrames = ceil(InVid.FrameRate*InVid.Duration);

    if isBinary
        vid_matrix = false(InVid.Height, InVid.Width, numFrames);
    else
        vid_matrix = zeros(InVid.Height, InVid.Width, numFrames);
    end

    n = 1;
    while hasFrame(InVid)
        frame = rgb2gray(readFrame(InVid));
        if(isBinary)
            frame = imbinarize(frame);
        else 
            frame = im2double(frame);
        end
        vid_matrix(:,:,n) = frame;
        n = n + 1;
    end
    
    if numFrames >= n
        vid_matrix = vid_matrix(:, :, 1:n-1);
    end
end