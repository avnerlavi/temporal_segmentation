disp(['Start ', datestr(datetime('now'),'HH:MM:SS')]);
root = getenv('TemporalSegmentation');
addpath(genpath([root,'/utils']));

video_folder = [root ,'/resources/'];
video_names = {'arm-movements-712-716.mp4', ...
    'front.mp4', ...
    'front2.mp4', ...
    'general_movement3.mp4', ...
    'general-movement-130-134.mp4', ...
    'general-movement-648-657.mp4', ...
    'heartbeat-309-312.mp4', ...
    'jumping.mp4', ...
    'ultrasound_1_cropped.avi'};
beta = 1;
gain = 1;
DE_params = struct;
DE_params.numOfScales = 4;
DE_params.elevationHalfAngle = [0, 90];
DE_params.azimuthNum = 8;
DE_params.elevationNum = 7;
DE_params.eccentricity = sqrt(1);
DE_params.activationThreshold = 0.03; %for running man - 0.3
DE_params.facilitationLengths = [10, 5];
DE_params.alpha = 0;
DE_params.m1 = 1;
DE_params.m2 = 2;
DE_params.m2 = 2;
DE_params.normQ = 2;
DE_params.resizeFactors = NaN;
videos = cell(length(video_names),3);
target_height = 186;
for i = 1:length(video_names)
    in_file_dir = [video_folder,video_names{i}];
    vid_matrix = readVideoFromFile(in_file_dir, false);
    DE_params.resizeFactors = target_height/size(vid_matrix,1)*[1, 1, 1];
    videos{i,1} = video_names{i};
    [vid_matrix_resized,videos{i,2}] = detailEnhancement3Dfunc(vid_matrix,DE_params,false);
    videos{i,3} = additiveCombination(vid_matrix_resized, videos{i,2}, beta, gain);
    [~,t_c] = compareVids(vid_matrix_resized,videos{i,3});
    [~,t_n] = compareVids(vid_matrix_resized,minMaxNorm(videos{i,3}));
    minVideoValue = min(videos{i,2}(:));
    maxVideoValue = max(videos{i,2}(:));
    writeVideoToFile(minMaxNorm(videos{i,2}), ...
        'movie_detail_enhanced_3d_minmax', [root,'\results\3dGabor\detail_enhancement\',video_names{i}(1:end-4)]);
    writeVideoToFile(abs(videos{i,2}), ...
        'movie_detail_enhanced_3d_abs', [root,'\results\3dGabor\detail_enhancement\',video_names{i}(1:end-4)]);
     writeVideoToFile(minMaxNorm(videos{i,3}), ...
        'movie_combined_norm', [root,'\results\3dGabor\detail_enhancement\',video_names{i}(1:end-4)]);
         writeVideoToFile(max(min(videos{i,3},1),0), ...
        'movie_combined_clipped', [root,'\results\3dGabor\detail_enhancement\',video_names{i}(1:end-4)]);
    writeVideoToFile(minMaxNorm(t_n), ...
        'comparison_norm', [root,'\results\3dGabor\detail_enhancement\',video_names{i}(1:end-4)]);
         writeVideoToFile(max(min(t_c,1),0), ...
        'comparison_clipped', [root,'\results\3dGabor\detail_enhancement\',video_names{i}(1:end-4)]);
    saveParams([root,'\results\3dGabor\detail_enhancement\',video_names{i}(1:end-4)], ...
        in_file_dir, DE_params, ...
        minVideoValue, maxVideoValue,beta,gain);
    
end