disp(['Start ', datestr(datetime('now'),'HH:MM:SS')]);
root = getenv('TemporalSegmentation');
addpath(genpath([root,'/utils']));
addpath(genpath('detail_enhancement_multiple_videos_functions'));
explicit_filenames = true;
resource_folder = [root ,'/resources/material_from_ynon_19_1_22/filtered_new/cropped/heart_malformation/'];
response_folder = [root ,'/results/material_from_ynon_19_1_22_edited_results/heart_malformation/cropped/'];
folder_out_prefix = '_gamma_09';
beta = 5;
gamma = 0.9;
gain = 1;

if(explicit_filenames)
    video_names = {
        '2711_2737.avi',...
        '2805_2818.avi',...
        };
else
    listing = dir(resource_folder);
    for i = 1:length(listing)
        listing(i).isvideo = length(listing(i).name)>4 && ...
            (strcmp(listing(i).name(end-3:end),'.mp4')||strcmp(listing(i).name(end-3:end),'.avi'));
    end
    video_names = {listing([listing.isvideo]).name};
end

for i = 1:length(video_names)
    response_dir = fullfile(response_folder,video_names{i}(1:end-4),'movie_detail_enhanced_3d_minmax.avi');
    params_dir = fullfile(response_folder,video_names{i}(1:end-4),'params.xls');
    
    if(~exist(response_dir,'file'))
        error(['could not find file :',response_dir]);
    end
    
    if(~exist(params_dir,'file'))
        error(['could not find file :',params_dir]);
    end
    vid_in = readVideoFromFile(fullfile(resource_folder,video_names{i}),false);
    vid_in = vid_in(:,:,2:end-1);
    response = readVideoFromFile(response_dir,false);
    params = readtable(params_dir,'ReadVariableNames',false);
    min_val_row = find(strcmp(params{:,1},'minVideoValue'));
    max_val_row = find(strcmp(params{:,1},'maxVideoValue'));
    min_val = str2double(params{min_val_row,2}{1});
    max_val = str2double(params{max_val_row,2}{1});
    response = response*(max_val - min_val) + min_val;
    vid_combined = additiveCombination(vid_in, response, beta, gamma, gain);
    out_dir = fullfile(response_folder,[video_names{i}(1:end-4),folder_out_prefix]);
   [minVideoValue,maxVideoValue] = saveResults(vid_in,response,vid_combined,out_dir);
    
end
