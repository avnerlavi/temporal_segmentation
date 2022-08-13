disp(['Start ', datestr(datetime('now'),'HH:MM:SS')]);
root = getenv('TemporalSegmentation');
addpath(genpath([root,'/utils']));
addpath(genpath('detail_enhancement_multiple_videos_functions'));
explicit_filenames = false;
video_in_folder = [root ,'/resources/material_from_ynon_19_1_22/filtered_new/cropped/heart_malformation/'];
video_out_folder = [root ,'/results/material_from_ynon_19_1_22_edited_results/cropped/'];
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
       % 'heart_malformation/1627_1746.avi',...
       % 'heart_malformation/1756_1832.avi',...
       % 'heart_malformation/2711_2737.avi',...
        %'heart_malformation/2805_2818.avi',...
       % 'eve_c_c/0258_0352.avi',
        'eve_c_c/1543_1632.avi'};
else
    listing = dir(video_in_folder);
    for i = 1:length(listing)
        listing(i).isvideo = length(listing(i).name)>4 && ...
            (strcmp(listing(i).name(end-3:end),'.mp4')||strcmp(listing(i).name(end-3:end),'.avi'));
    end
    video_names = {listing([listing.isvideo]).name};
end
beta = 2;
gain = 1;
DE_params = struct;
DE_params.numOfScales = 4;
DE_params.elevationHalfAngle = [0, 90];
DE_params.azimuthNum = 8;
DE_params.elevationNum = 7;
DE_params.eccentricity = sqrt(1);
DE_params.activationThreshold = 0.12; %for running man - 0.3
DE_params.facilitationLengths = [10, 5];
DE_params.alpha = 0.5;
DE_params.m1 = 1;
DE_params.m2 = 2;
DE_params.normQ = 2;
DE_params.resizeFactors = NaN;
videos = cell(length(video_names),3);
target_height = 186;
upper_size_limit = 3*10^9;
chunk_size = 3*10^9;

for i = 1:length(video_names)
    disp(['started on ',video_names{i},' vid:',num2str(i),'\',num2str(length(video_names))...
        ,' ', datestr(datetime('now'),'HH:MM:SS')]);
    in_file_dir = [video_in_folder,video_names{i}];
    [required_memory,DE_params.resizeFactors,video_frames] = calculateVideoMemorySize(in_file_dir,target_height);
    
    if(required_memory > upper_size_limit)
        disp('video too big - splitting to chunks:')
        num_chunks = ceil(required_memory/chunk_size);
        for j = 1:num_chunks
            disp(['chunk:',num2str(j),'\',num2str(num_chunks),...
                ' of vid:',num2str(i),'\',num2str(length(video_names))...
                ,' ' , datestr(datetime('now'),'HH:MM:SS')]);
            chunk = readVideoFromFile(in_file_dir, false,[round((j-1)*video_frames/num_chunks)+1,round(j*video_frames/num_chunks)]);
            chunk =convn(chunk,1/3*ones(1,1,3),'valid'); % CHANGE!!
            [vid_matrix_resized,activation] = detailEnhancement3Dfunc(chunk,DE_params,false);
            video_combined = additiveCombination(vid_matrix_resized, activation, beta, gain);
            save_dir = [video_out_folder,video_names{i}(1:end-4),'_chunk_',num2str(j)];
            [minVideoValue,maxVideoValue] = saveResults(vid_matrix_resized,activation,video_combined,save_dir);
            saveParams(save_dir,in_file_dir, DE_params,minVideoValue, maxVideoValue,beta,gain);
            clear chunk activation vid_matrix_resized
        end
        
    else
        vid_matrix = readVideoFromFile(in_file_dir, false);
        vid_matrix =convn(vid_matrix,1/3*ones(1,1,3),'valid'); % CHANGE!!
        [vid_matrix_resized,activation] = detailEnhancement3Dfunc(vid_matrix,DE_params,false);
        video_combined = additiveCombination(vid_matrix_resized, activation, beta, gain);
        save_dir = [video_out_folder,video_names{i}(1:end-4)];
        [minVideoValue,maxVideoValue] = saveResults(vid_matrix_resized,activation,video_combined,save_dir);
        saveParams(save_dir,in_file_dir, DE_params, minVideoValue, maxVideoValue,beta,gain);
        clear vid_matrix_resized activation vid_matrix
    end
    
end
disp(['Finish ', datestr(datetime('now'),'HH:MM:SS')]);
