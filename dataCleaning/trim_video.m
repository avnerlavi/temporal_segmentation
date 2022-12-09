dir_in = "F:\Matlab\docs\temporal_segmentation\resources\corpus_callosum_case_11_11_22\21_3\מור סקירה 2.mp4";
dir_out = 'F:\Matlab\docs\temporal_segmentation\resources\corpus_callosum_case_11_11_22\21_3\';
max_frame_limit = 3000;
vid_data = VideoReader(dir_in);
frame_rate = vid_data.FrameRate;
video_frames = vid_data.Duration*vid_data.FrameRate;
%frame_ranges = [1,min(max_frame_limit,video_frames)];
%vid_matrix = readVideoFromFile(dir_in, false,frame_ranges);
implay(dir_in)
cont = true;
state = 'frame_start';
trim_dir = mkdir(fullfile(dir_out,'trimmed'));
crop_dir = mkdir(fullfile(dir_out,'cropped'));
mask_dir = mkdir(fullfile(dir_out,'masks'));
while cont
    switch(state)
        case 'frame_start'
            start_frame = input("enter start time:  ");
            if(strcmp(start_frame,'exit'))
                cont = false;
                break;
            end
            %start_frame = str2double(x);
            state = 'frame_end';
        case 'frame_end'
            end_frame = input("enter end time:  ");
            if(strcmp(end_frame,'exit'))
                cont = false;
                break;
            end
            %end_frame = str2double(x);
            middle_frame = floor((end_frame+start_frame)/2);
            vid_matrix = readVideoFromFile(dir_in, false,[middle_frame,middle_frame+1]);
            
            [~,rect] = imcrop(vid_matrix(:,:,1));
            close
            vid_matrix = readVideoFromFile(dir_in, false,[start_frame,end_frame],rect);
            start_time_minutes = floor(start_frame/(frame_rate*60));
            start_time_seconds = floor(mod(start_frame/(frame_rate),60));
            end_time_minutes = floor(end_frame/(frame_rate*60));
            end_time_seconds = floor(mod(end_frame/(frame_rate),60));
            strings = {num2str(start_time_minutes,"%.2d"), ...
                num2str(start_time_seconds,"%.2d"), ...
                num2str(end_time_minutes,"%.2d"), ...
                num2str(end_time_seconds,"%.2d")};
            file_name = join(strings,["","_",""]);
            
            file_name = convertStringsToChars(file_name{1});
            out_file_dir = fullfile(dir_out,'trimmed');
            %implay(vid_matrix)
            writeVideoToFile(vid_matrix,file_name,out_file_dir);
            [mask,bbox] = find_ultrasound_boundry(vid_matrix);
            k = input("keep trim?  ",'s');
            close
            if(k == 'y')
                imwrite(mask,fullfile(dir_out,'masks',[file_name,'.png']));
                vid_matrix = vid_matrix(bbox(2):bbox(2)+bbox(4),bbox(1):bbox(1)+bbox(3),:);
                writeVideoToFile(vid_matrix,join(file_name),fullfile(dir_out,'cropped'));
            end
            state = 'frame_start';
    end
end
