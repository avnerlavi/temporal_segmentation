disp(['Start ', datestr(datetime('now'),'HH:MM:SS')]);

dump_movies = true;
root = getenv('TemporalSegmentation');
addpath(genpath([root, '/utils']));

generatePyrFlag  = false;
elevationHalfAngle = 90;
resizeFactors = [1,1,1];
videoName = 'verticalLine_dotted.avi';
videoPath = [root, '\resources\ImpulseCheckingVids\', videoName];%"F:\Matlab\docs\temporal_segmentation\??ImpulseCheckingVids\detail_enhancement_movingDot_dilate\movingDot_dilate.avi"

if strcmp(videoName(end-3:end), '.avi') == true
        videoName = videoName(1: end-4);
end
resultsDir = [root, '\results\ImpulseCheckingVids\', videoName];
mkdir(resultsDir);
%%
if(generatePyrFlag)
    videoPath = [root, '/captcha_running.avi'];
    vid_matrix_orig = readVideoFromFile(videoPath, true);
    vid_matrix = imresize(vid_matrix_orig, 0.25);
    [vid_matrix] = StdUsingPyramidFunc(vid_matrix);
else
    vid_matrix = readVideoFromFile(videoPath, false);
end

vid_matrix = safeResize(vid_matrix, resizeFactors.*size(vid_matrix));
vid_matrix = vid_matrix-0.5;
CCLFParams = struct;
CCLFParams.numOfScales = 1;
CCLFParams.elevationHalfAngle = atand(tand(elevationHalfAngle) * resizeFactors(1) / resizeFactors(3));
CCLFParams.azimuthNum = 4;
CCLFParams.elevationNum = 4;
CCLFParams.activationThreshold = 0.03; %for running man - 0.3
CCLFParams.facilitationLength = 16;
CCLFParams.alpha = 0;
CCLFParams.m1 = 1;
CCLFParams.m2 = 1;

detail_enhanced = ...
    computeCombinedLF_IN3D(vid_matrix, ...
    CCLFParams.azimuthNum, ...
    CCLFParams.elevationNum, ...
    CCLFParams.elevationHalfAngle, ...
    CCLFParams.numOfScales , ...
    CCLFParams.activationThreshold, ...
    CCLFParams.facilitationLength, ...
    CCLFParams.alpha, ...
    CCLFParams.m1, ...
    CCLFParams.m2,  ...
    resultsDir);

vidOut = abs(detail_enhanced);
minVideoValue = min(detail_enhanced(:));
maxVideoValue = max(detail_enhanced(:));
implay(minMaxNorm(detail_enhanced));
maintainFitToWindow();
disp(['Done ' datestr(datetime('now'), 'HH:MM:SS')]);
if (dump_movies)
    writeVideoToFile(minMaxNorm(detail_enhanced), ...
        'movie_detail_enhanced_3d_minmax', resultsDir);
    writeVideoToFile(abs(detail_enhanced), ...
        'movie_detail_enhanced_3d_abs', resultsDir);
    saveParams(resultsDir, ...
        generatePyrFlag, videoPath, resizeFactors, elevationHalfAngle, CCLFParams, ...
        minVideoValue, maxVideoValue);
end
