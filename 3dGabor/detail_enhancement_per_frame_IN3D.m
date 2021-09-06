disp(['Start ', datestr(datetime('now'),'HH:MM:SS')]);

dump_movies = true;
root = getenv('TemporalSegmentation');
addpath(genpath([root,'/utils']));

generatePyrFlag  = false;
numOfScales = 4;
elevationHalfAngle = 60;
resizeFactors = [1/3, 1/3, 1/2];
inFileDir = [root,'\results\3dStd\movie_vid_std_3d.avi'];
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
CCLFParams.activationThreshold = 0.3;
CCLFParams.elevationHalfAngle = atand(tand(elevationHalfAngle) * resizeFactors(1) / resizeFactors(3));
CCLFParams.azimuthNum = 8;
CCLFParams.elevationNum = 7;
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
implay(vidOut);
maintainFitToWindow();
disp(['Done ' datestr(datetime('now'),'HH:MM:SS')]);
if (dump_movies)
    writeVideoToFile(abs(detail_enhanced), 'movie_detail_enhanced_3d', [root,'\results\3dGabor']);
    saveParams([root,'\results\3dGabor'], generatePyrFlag, inFileDir, resizeFactors, elevationHalfAngle, CCLFParams);
end
