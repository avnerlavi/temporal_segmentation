disp(['Start ', datestr(datetime('now'),'HH:MM:SS')]);

dump_movies = true;
root = getenv('TemporalSegmentation');
addpath(genpath([root,'/utils']));

generatePyrFlag  = false;
elevationHalfAngle = 90;
resizeFactors = [1,1,1];
inFileDir = [root ,'\þþImpulseCheckingVids\detail_enhancement_verticalLine_dotted\verticalLine_dotted.avi'];%"F:\Matlab\docs\temporal_segmentation\þþImpulseCheckingVids\detail_enhancement_movingDot_dilate\movingDot_dilate.avi"
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
vid_matrix = vid_matrix-0.5;
CCLFParams = struct;
CCLFParams.numOfScales = 1;
CCLFParams.elevationHalfAngle = atand(tand(elevationHalfAngle) * resizeFactors(1) / resizeFactors(3));
CCLFParams.azimuthNum = 72;
CCLFParams.elevationNum = 19;
CCLFParams.activationThreshold = 0.03;%for runing man - 0.3
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
    CCLFParams.m2  ...
    );

vidOut = abs(detail_enhanced);
minVideoValue = min(detail_enhanced(:));
maxVideoValue = max(detail_enhanced(:));
implay(minMaxNorm(detail_enhanced));
maintainFitToWindow();
disp(['Done ' datestr(datetime('now'),'HH:MM:SS')]);
if (dump_movies)
    writeVideoToFile(minMaxNorm(detail_enhanced), ...
        'movie_detail_enhanced_3d_minmax', [root,'\results\3dGabor\detail_enhancement']);
    writeVideoToFile(abs(detail_enhanced), ...
        'movie_detail_enhanced_3d_abs', [root,'\results\3dGabor\detail_enhancement']);
    saveParams([root,'\results\3dGabor\detail_enhancement'], ...
        generatePyrFlag, inFileDir, resizeFactors, elevationHalfAngle, CCLFParams, ...
        minVideoValue, maxVideoValue);
end
