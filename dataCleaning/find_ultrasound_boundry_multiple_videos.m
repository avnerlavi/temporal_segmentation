disp(['Start ', datestr(datetime('now'),'HH:MM:SS')]);
root = getenv('TemporalSegmentation');
addpath(genpath([root,'/utils']));
addpath(genpath([root,'/3dGabor/detail_enhancement_multiple_videos_functions']));
explicit_filenames = true;
video_in_folder = [root ,'/resources/material_from_ynon_19_1_22/filtered_new/heart_malformation/'];
video_cropped_folder = [root ,'/resources/material_from_ynon_19_1_22/filtered_new/cropped/heart_malformation/'];
masks_folder = [root ,'/resources/material_from_ynon_19_1_22/filtered_new/masks/heart_malformation/'];
mkdir(masks_folder);
upper_size_limit = 3*10^9;
chunk_size = 3*10^9;
if(explicit_filenames)
    %     video_names = {'arm-movements-712-716.mp4', ...
    %         'front.mp4', ...
    %         'front2.mp4', ...
    %         'general_movement3.mp4', ...
    %         'general-movement-130-134.mp4', ...
    %         'general-movement-648-657.mp4', ...
    %         'heartbeat-309-312.mp4', ...
    %         'jumping.mp4', ...
    %         'ultrasound_1_cropped.avi'};
    video_names = {%'eye_c.c/0258_0352.mp4', ...
        %'eye_c.c/0407_0411.mp4', ...
        %'eye_c.c/1543_1632.mp4',...
        %'obesity/obesity 1_17.avi',...
        %'obesity/obesity 1_20.avi',...
       % 'heart_malformation/0858_0906.avi',...
       % 'heart_malformation/1018_1029.avi',...
       % 'heart_malformation/1401_1409.avi',...
        '1627_1746.avi'}%,...
       % 'heart_malformation/1756_1832.avi',...
       % 'heart_malformation/2711_2737.avi',...
        %'heart_malformation/2805_2818.avi',...
       % 'eve_c_c/0258_0352.avi',
        %'eve_c_c/1543_1632.avi'};
else
    listing = dir(video_in_folder);
    for i = 1:length(listing)
        listing(i).isvideo = length(listing(i).name)>4 && ...
            (strcmp(listing(i).name(end-3:end),'.mp4')||strcmp(listing(i).name(end-3:end),'.avi'));
    end
        video_names = {listing([listing.isvideo]).name};
end

for i = 1:length(video_names)
    disp(['started on ',video_names{i},' vid:',num2str(i),'\',num2str(length(video_names))...
        ,' ', datestr(datetime('now'),'HH:MM:SS')]);
    in_file_dir = [video_in_folder,video_names{i}];
    [required_memory,~,video_frames] = calculateVideoMemorySize(in_file_dir,0);
     if(required_memory > upper_size_limit)
         num_chunks = ceil(required_memory/chunk_size);
         chunk = readVideoFromFile(in_file_dir, false,[1,round(video_frames/num_chunks)]);
         [mask,bbox] = find_ultrasound_boundry(chunk);
         cropped_video_factor = (bbox(3)-bbox(1))*(bbox(2)-bbox(2))/numel(mask);
         cropped_num_chunks = max(ceil(required_memory*cropped_video_factor/chunk_size),1);
         for j = 1:cropped_num_chunks
             chunk = readVideoFromFile(in_file_dir, false,[round((j-1)*video_frames/cropped_num_chunks)+1,round(j*video_frames/cropped_num_chunks)]);
             chunk = chunk(bbox(2):bbox(4)+bbox(2),bbox(1):bbox(3)+bbox(1),:);
             new_vid_name = [video_names{i}(1:end-4),'_chunk_',num2str(j),'.avi'];
             writeVideoToFile(chunk,new_vid_name,video_cropped_folder);
             imwrite(mask,[masks_folder,'/',new_vid_name(1:end-4),'.png']);
         end
     else
         vid = readVideoFromFile(in_file_dir, false);
         [mask,bbox] = find_ultrasound_boundry(vid);
         vid = vid(bbox(2):bbox(4)+bbox(2),bbox(1):bbox(3)+bbox(1),:);
         writeVideoToFile(vid,video_names{i}(1:end-4),video_cropped_folder);
         imwrite(mask,[masks_folder,'/',video_names{i}(1:end-4),'.png']);
     end
end


         