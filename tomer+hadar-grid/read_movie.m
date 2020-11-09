function vid_matrix = read_movie(file_path,out_type)

    InVid = VideoReader(file_path);
    numFrames = ceil(InVid.FrameRate*InVid.Duration);

    if islogical(out_type)
        vid_matrix = false(InVid.Height, InVid.Width, numFrames);
    else
        vid_matrix = zeros(InVid.Height, InVid.Width, numFrames);
    end

    for n = 1:numFrames
        frame = readFrame(InVid);
        frame = imbinarize(rgb2gray(frame));
        if ~islogical(out_type)
            frame = double(frame);
        end
        vid_matrix(:,:,n) = frame;
    end

end