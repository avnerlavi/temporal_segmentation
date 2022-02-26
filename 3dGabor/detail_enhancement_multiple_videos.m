disp(['Start ', datestr(datetime('now'),'HH:MM:SS')]);
root = getenv('TemporalSegmentation');
addpath(genpath([root,'/utils']));
explicit_filenames = false;
video_in_folder = [root ,'/resources/material_from_ynon_19_1_22/edited/eye_2_c_c/'];
video_out_folder = [root ,'/results/material_from_ynon_19_1_22_results/eye_2_c_c/'];
if(explicit_filenames)
    video_names = {'arm-movements-712-716.mp4', ...
        'front.mp4', ...
        'front2.mp4', ...
        'general_movement3.mp4', ...
        'general-movement-130-134.mp4', ...
        'general-movement-648-657.mp4', ...
        'heartbeat-309-312.mp4', ...
        'jumping.mp4', ...
        'ultrasound_1_cropped.avi'};
else
    listing = dir(video_in_folder);
    for i = 1:length(listing)
        listing(i).isvideo = length(listing(i).name)>4 && ...
            (strcmp(listing(i).name(end-3:end),'.mp4')||strcmp(listing(i).name(end-3:end),'.avi'));
    end
    video_names = {listing([listing.isvideo]).name};
end
beta = 1.5;
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
for i = 1:length(video_names)
    disp(['started on ',video_names{i},' vid:',num2str(i),'\',num2str(length(video_names))...
        ,' ', datestr(datetime('now'),'HH:MM:SS')]);
    in_file_dir = [video_in_folder,video_names{i}];
    vid_matrix = readVideoFromFile(in_file_dir, false);
    DE_params.resizeFactors = target_height/size(vid_matrix,1)*[1, 1, 1];
    num_orientations = DE_params.azimuthNum*DE_params.elevationNum;
    if(any(DE_params.elevationHalfAngle==0))
        num_orientations = DE_params.azimuthNum*(DE_params.elevationNum-1)+1;
    end
    req_memory = ceil(numel(vid_matrix)*prod(DE_params.resizeFactors))*8;
    upper_size_limit = 5*10^9;
    chunk_size = 2.5*10^9;
    if(req_memory > upper_size_limit)
        disp('video too big - splitting to chunks:')
        num_chunks = ceil(req_memory/chunk_size);
        for j = 1:num_chunks
            disp(['chunk:',num2str(j),'\',num2str(num_chunks),...
                ' of vid:',num2str(i),'\',num2str(length(video_names))...
                ,' ' , datestr(datetime('now'),'HH:MM:SS')]);
            chunk = vid_matrix(:,:,round((j-1)*end/num_chunks)+1:round(j*end/num_chunks));
            [vid_matrix_resized,activation] = detailEnhancement3Dfunc(chunk,DE_params,false);
            video_combined = additiveCombination(vid_matrix_resized, activation, beta, gain);
            [~,t_c] = compareVids(vid_matrix_resized,video_combined,'verbose',false);
            [~,t_n] = compareVids(vid_matrix_resized,minMaxNorm(video_combined),'verbose',false);
            minVideoValue = min(activation(:));
            maxVideoValue = max(activation(:));
            writeVideoToFile(minMaxNorm(activation), ...
                'movie_detail_enhanced_3d_minmax', [video_out_folder,video_names{i}(1:end-4),'_chunk_',num2str(j)]);
            writeVideoToFile(abs(activation), ...
                'movie_detail_enhanced_3d_abs', [video_out_folder,video_names{i}(1:end-4),'_chunk_',num2str(j)]);
            writeVideoToFile(minMaxNorm(video_combined), ...
                'movie_combined_norm', [video_out_folder,video_names{i}(1:end-4),'_chunk_',num2str(j)]);
            writeVideoToFile(max(min(video_combined,1),0), ...
                'movie_combined_clipped', [video_out_folder,video_names{i}(1:end-4),'_chunk_',num2str(j)]);
            writeVideoToFile(minMaxNorm(t_n), ...
                'comparison_norm', [video_out_folder,video_names{i}(1:end-4),'_chunk_',num2str(j)]);
            writeVideoToFile(max(min(t_c,1),0), ...
                'comparison_clipped', [video_out_folder,video_names{i}(1:end-4),'_chunk_',num2str(j)]);
            saveParams([video_out_folder,'\',video_names{i}(1:end-4),'_chunk_',num2str(j)], ...
                in_file_dir, DE_params, ...
                minVideoValue, maxVideoValue,beta,gain);
            clear t_c t_n vid_matrix_resized activation
            memory
        end
        
    else
        [vid_matrix_resized,activation] = detailEnhancement3Dfunc(vid_matrix,DE_params,false);
        video_combined = additiveCombination(vid_matrix_resized, activation, beta, gain);
        [~,t_c] = compareVids(vid_matrix_resized,video_combined,'verbose',false);
        [~,t_n] = compareVids(vid_matrix_resized,minMaxNorm(video_combined),'verbose',false);
        minVideoValue = min(activation(:));
        maxVideoValue = max(activation(:));
        writeVideoToFile(minMaxNorm(activation), ...
            'movie_detail_enhanced_3d_minmax', [video_out_folder,video_names{i}(1:end-4)]);
        writeVideoToFile(abs(activation), ...
            'movie_detail_enhanced_3d_abs', [video_out_folder,video_names{i}(1:end-4)]);
        writeVideoToFile(minMaxNorm(video_combined), ...
            'movie_combined_norm', [video_out_folder,video_names{i}(1:end-4)]);
        writeVideoToFile(max(min(video_combined,1),0), ...
            'movie_combined_clipped', [video_out_folder,video_names{i}(1:end-4)]);
        writeVideoToFile(minMaxNorm(t_n), ...
            'comparison_norm', [video_out_folder,video_names{i}(1:end-4)]);
        writeVideoToFile(max(min(t_c,1),0), ...
            'comparison_clipped', [video_out_folder,video_names{i}(1:end-4)]);
        saveParams([video_out_folder,'\',video_names{i}(1:end-4)], ...
            in_file_dir, DE_params, ...
            minVideoValue, maxVideoValue,beta,gain);
        clear t_c t_n vid_matrix_resized activation
        memory
    end
    
end
disp(['Finish ', datestr(datetime('now'),'HH:MM:SS')]);
