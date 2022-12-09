dir_in = 'F:\Matlab\docs\temporal_segmentation\resources\ultrasound_1_cropped.avi';
dir_out = 'F:\Matlab\docs\temporal_segmentation\resources\';
name = 'ultrasound_1_cropped_new';
frame_rate = 30;
minutes_timerange = [0,0];
seconds_timerange = [0,7];
%%
time_ranges = minutes_timerange*60+seconds_timerange;
frame_ranges = frame_rate*time_ranges;
vid_matrix = readVideoFromFile(dir_in, false,frame_ranges);
[~,rect] = imcrop(vid_matrix(:,:,1));
vid_matrix = vid_matrix(rect(2):rect(2)+rect(4),rect(1):rect(1)+rect(3),:);
%implay(vid_matrix)
writeVideoToFile(vid_matrix,name,dir_out);
