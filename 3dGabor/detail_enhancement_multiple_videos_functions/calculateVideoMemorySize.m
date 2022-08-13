function [required_memory,resize_factors,video_frames] = calculateVideoMemorySize(input_video_dir,target_height)
bit_depth = 8; %double prescision
video_in = VideoReader(input_video_dir);
%resize_factors = target_height/video_in.Height*[1, 1, 0.6];
resize_factors = [1,1,1];
resize_factors = min(resize_factors ,1); %video is only scaled down
video_frames = video_in.Duration*video_in.FrameRate;
video_size = video_in.Height * video_in.Width * video_frames;
required_memory = ceil(video_size*(prod(resize_factors)+1)) *bit_depth; %required memory for original and scaled video as a huristic
end

