dir_in = 'F:\Matlab\docs\temporal_segmentation\resources\material_from_ynon_19_1_22\raw_data\eve_2_c_c\יפעת סקירה 3.mp4';
dir_out = 'F:\Matlab\docs\temporal_segmentation\resources\material_from_ynon_19_1_22\filtered_new\eve_c_c';
name = '0258_0352';
frame_rate = 30;
minutes_timerange = [02,03];
seconds_timerange = [58,52];
%%
time_ranges = minutes_timerange*60+seconds_timerange;
frame_ranges = frame_rate*time_ranges;
vid_matrix = readVideoFromFile(dir_in, false,frame_ranges);
[~,rect] = imcrop(vid_matrix(:,:,(frame_ranges(2)-frame_ranges(1))/2));
vid_matrix = vid_matrix(rect(2):rect(2)+rect(4),rect(1):rect(1)+rect(3),:);
%implay(vid_matrix)
writeVideoToFile(vid_matrix,name,dir_out);
