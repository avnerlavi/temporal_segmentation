disp(['Start ', datestr(datetime('now'),'HH:MM:SS')]);
baby  = true;
dump_movies = true;
root = getenv('TemporalSegmentation');
addpath(genpath([root,'/utils']));

generatePyrFlag  = false;
elevationHalfAngle = [0, 90];
resizeFactors = [1, 1, 1];
inFileDir = [root ,'/resources/materials_from_lior_1_7_23/10/cropped/0000_0006.avi'];
%%
if(generatePyrFlag)
    inFileDir = [root,'/captcha_running.avi'];
    vid_matrix_orig = readVideoFromFile(inFileDir, true);
    vid_matrix = imresize(vid_matrix_orig, 0.25);
    [vid_matrix] = StdUsingPyramidFunc(vid_matrix);
else
    vid_matrix = readVideoFromFile(inFileDir, false);
    vid_matrix =convn(vid_matrix,1/3*ones(1,1,3),'valid');
end
vid_matrix = safeResize(vid_matrix, resizeFactors.*size(vid_matrix));
CCLFParams = struct;
CCLFParams.numOfScales = 4;
CCLFParams.elevationHalfAngle = atand(tand(elevationHalfAngle) * resizeFactors(1) / resizeFactors(3));
CCLFParams.azimuthNum = 8;
CCLFParams.elevationNum = 7;
CCLFParams.eccentricity = sqrt(1);
CCLFParams.activationThreshold = 0.12; %for running man - 0.3
CCLFParams.facilitationLengths = 11;
CCLFParams.alpha = 0.5;
CCLFParams.m1 = 1;
CCLFParams.m2 = 2;
CCLFParams.normQ = 2;
param_name = 'facilitationLengths';
for param_value = [5]
    disp(['Starting ',param_name,' ',param_value, datestr(datetime('now'),'HH:MM:SS')]);
    CCLFParams = setfield(CCLFParams,param_name,param_value);
    [detail_enhanced, detail_enhanced_pyr,threshold_data] = ...
        computeCombinedLf3d(vid_matrix, ...
        CCLFParams.azimuthNum, ...
        CCLFParams.elevationNum, ...
        CCLFParams.elevationHalfAngle, ...
        CCLFParams.eccentricity, ...
        CCLFParams.numOfScales , ...
        CCLFParams.activationThreshold, ...
        CCLFParams.facilitationLengths, ...
        CCLFParams.alpha, ...
        CCLFParams.m1, ...
        CCLFParams.m2, ...
        CCLFParams.normQ ...
        );
    vidOut = minMaxNorm(detail_enhanced);
    minVideoValue = min(detail_enhanced(:));
    maxVideoValue = max(detail_enhanced(:));
    beta = 9;
    gamma = 0.75;
    gain = 1;
    [vidCombined] = additiveCombination(vid_matrix, detail_enhanced, beta, gamma, gain);
    [diff_clip,total_clip] = compareVids(vid_matrix,vidCombined,'verbose',false);
    [diff_norm,total_norm] = compareVids(vid_matrix,minMaxNorm(vidCombined),'verbose',false);
    disp(['Done ' datestr(datetime('now'),'HH:MM:SS')]);
    if (dump_movies)
        writeVideoToFile(minMaxNorm(detail_enhanced), ...
            'movie_detail_enhanced_3d_minmax', [root,'\results\3dGabor\parameter_sweep_',param_name,'\',num2str(param_value)]);
        writeVideoToFile(abs(detail_enhanced), ...
            'movie_detail_enhanced_3d_abs', [root,'\results\3dGabor\parameter_sweep_',param_name,'\',num2str(param_value)]);
        writeVideoToFile(minMaxNorm(vidCombined), ...
            'movie_combined_norm', [root,'\results\3dGabor\parameter_sweep_',param_name,'\',num2str(param_value)]);
        writeVideoToFile(max(min(vidCombined,1),0), ...
            'movie_combined_clipped', [root,'\results\3dGabor\parameter_sweep_',param_name,'\',num2str(param_value)]);
        writeVideoToFile(max(min(total_clip,1),0), ...
            'comparison_clipped', [root,'\results\3dGabor\parameter_sweep_',param_name,'\',num2str(param_value)]);
        writeVideoToFile(total_norm, ...
            'comparison_norm', [root,'\results\3dGabor\parameter_sweep_',param_name,'\',num2str(param_value)]);
        saveParams([root,'\results\3dGabor\parameter_sweep_',param_name,'\',num2str(param_value)], ...
            generatePyrFlag, inFileDir, resizeFactors, elevationHalfAngle, CCLFParams, ...
            minVideoValue, maxVideoValue,beta,gamma,gain);
    end
    
end