function vid_matrix = readVideoFromFile(file_path,isBinary,frame_range)

    InVid = VideoReader(file_path);
    
    if exist('frame_range','var')
        InVid.CurrentTime = frame_range(1)/InVid.FrameRate;
        end_time = frame_range(2)/InVid.FrameRate;
        numFrames = frame_range(2) - frame_range(1);
    else
        end_time = InVid.Duration;
        numFrames = ceil(InVid.FrameRate*InVid.Duration);
    end
    if isBinary
        vid_matrix = false(InVid.Height, InVid.Width, numFrames);
    else
        vid_matrix = zeros(InVid.Height, InVid.Width, numFrames);
    end
    
    n = 1;
    while InVid.CurrentTime < end_time
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