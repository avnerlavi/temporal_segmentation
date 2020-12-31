dump_movies = true;
generatePyrFlag  = true;
addpath(genpath('../utils'));
disp(['Start ', datestr(datetime('now'),'HH:MM:SS')]);
numOfScales = 4;
elevationHalfAngle = 60;
resizeFactors = [1/3, 1/3, 1/2];
inFileDir = '..\results\no-grid\movie_stdPyramid_noGrid.avi';
%%
if(generatePyrFlag)
    vid_matrix_orig = readVideoFromFile('../captcha_running.avi', true);
    vid_matrix = imresize(vid_matrix_orig, 0.25);
    [vid_pyr] = StdUsingPyramidFunc(vid_matrix);
else
    vid_matrix = readVideoFromFile(inFileDir, false);
end
vid_matrix = safeResize(vid_matrix, resizeFactors);
vid_matrix = PadVideoReplicate(vid_matrix,2*numOfScales);
elevationHalfAngle = atand(tand(elevationHalfAngle) * resizeFactors(1) / resizeFactors(3));
detail_enhanced = ...
    computeCombinedLF_IN3D(vid_matrix, ...
    8, ... Azimuths number
    6, ... elevations number
    elevationHalfAngle, ... elevation half angle
    numOfScales , ... scale number
    10, ... base facilitation length
    0, ... alpha
    1, ... m1
    2  ... m2
    );

detail_enhanced = stripVideo(detail_enhanced,2*numOfScales);
detail_enhanced = detail_enhanced/max(abs(detail_enhanced(:)));
vidOut = abs(detail_enhanced);
implay(vidOut);
maintainFitToWindow();
disp(['Done ' datestr(datetime('now'),'HH:MM:SS')]);
if (dump_movies)
    writeVideoToFile(abs(detail_enhanced), 'movie_detail_enhanced_3d', '..\results\3dGabor');
end
