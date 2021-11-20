disp(['Start ', datestr(datetime('now'),'HH:MM:SS')]);
baby  = true;
dump_movies = true;
root = getenv('TemporalSegmentation');
addpath(genpath([root,'/utils']));

generatePyrFlag  = false;
elevationHalfAngle = [0, 90];
resizeFactors = [1/4, 1/4, 1/4];
inFileDir = [root ,'/resources/ultrasound_1_cropped.avi'];
%%
if(generatePyrFlag)
    inFileDir = [root,'/captcha_running.avi'];
    vid_matrix_orig = readVideoFromFile(inFileDir, true);
    vid_matrix = imresize(vid_matrix_orig, 0.25);
    [vid_matrix] = StdUsingPyramidFunc(vid_matrix);
else
    vid_matrix = readVideoFromFile(inFileDir, false);
end

vid_matrix = safeResize(vid_matrix, resizeFactors.*size(vid_matrix));
    
CCLFParams = struct;
CCLFParams.numOfScales = 4;
CCLFParams.elevationHalfAngle = atand(tand(elevationHalfAngle) * resizeFactors(1) / resizeFactors(3));
CCLFParams.azimuthNum = 8;
CCLFParams.elevationNum = 7;
CCLFParams.eccentricity = sqrt(1);
CCLFParams.activationThreshold = 0.03; %for running man - 0.3
CCLFParams.facilitationLengths = [10, 5];
CCLFParams.alpha = 0;
CCLFParams.m1 = 1;
CCLFParams.m2 = 2;
CCLFParams.m2 = 2;
CCLFParams.normQ = 2;


[detail_enhanced, detail_enhanced_pyr,threshold_data] = ...
    computeCombinedLF_IN3D(vid_matrix, ...
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
implay(vidOut);
maintainFitToWindow();
beta = 1;
gain = 1;

if(baby)
[vidCombined] = additiveCombination(vid_matrix, detail_enhanced, beta, gain);
compareVids(vid_matrix,vidCombined);
compareVids(vid_matrix,minMaxNorm(vidCombined));
end
disp(['Done ' datestr(datetime('now'),'HH:MM:SS')]);
if (dump_movies)
    writeVideoToFile(minMaxNorm(detail_enhanced), ...
        'movie_detail_enhanced_3d_minmax', [root,'\results\3dGabor\detail_enhancement']);
    writeVideoToFile(abs(detail_enhanced), ...
        'movie_detail_enhanced_3d_abs', [root,'\results\3dGabor\detail_enhancement']);
     writeVideoToFile(minMaxNorm(vidCombined), ...
        'movie_combined_norm', [root,'\results\3dGabor\detail_enhancement']);
         writeVideoToFile(max(min(vidCombined,1),0), ...
        'movie_combined_clipped', [root,'\results\3dGabor\detail_enhancement']);
    saveParams([root,'\results\3dGabor\detail_enhancement'], ...
        generatePyrFlag, inFileDir, resizeFactors, elevationHalfAngle, CCLFParams, ...
        minVideoValue, maxVideoValue,beta,gain);
end
