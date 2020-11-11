function vid_matrix = read_movie(file_path,isBinary)

    InVid = VideoReader(file_path);
    numFrames = ceil(InVid.FrameRate*InVid.Duration);

    if isBinary
        vid_matrix = false(InVid.Height, InVid.Width, numFrames);
    else
        vid_matrix = zeros(InVid.Height, InVid.Width, numFrames);
    end

    for n = 1:numFrames
        frame = rgb2gray(readFrame(InVid));
        if(isBinary)
        frame = imbinarize(frame);
        else 
            frame = im2double(frame);
        end
        vid_matrix(:,:,n) = frame;
    end

end