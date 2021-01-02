dump_movies = true;
generatePyrFlag  = false;
addpath(genpath('../utils'));
disp(['Start ', datestr(datetime('now'),'HH:MM:SS')]);
numOfScales = 4;
elevationHalfAngle = 60;
resizeFactors = [2/3, 2/3, 2/2];
inFileDir = '..\results\no-grid\movie_stdPyramid_noGrid.avi';
%%
if(generatePyrFlag)
    vid_matrix_orig = readVideoFromFile('../captcha_running.avi', true);
    vid_matrix_resized = imresize(vid_matrix_orig, 0.25);
    vid_matrix = StdUsingPyramidFunc(vid_matrix_resized);
else
    vid_matrix = readVideoFromFile(inFileDir, false);
end
vid_matrix = safeResize(vid_matrix, resizeFactors);
elevationHalfAngle = atand(tand(elevationHalfAngle) * resizeFactors(1) / resizeFactors(3));

detail_enhanced = ...
    computeCombinedLF_IN3D(vid_matrix, ...
    4, ... Azimuths number
    3, ... elevations number
    elevationHalfAngle, ... elevation half angle
    numOfScales , ... scale number
    20, ... base facilitation length
    0, ... alpha
    1, ... m1
    2  ... m2
    );

vidOut = abs(detail_enhanced);
implay(vidOut);
maintainFitToWindow();
disp(['Done ' datestr(datetime('now'),'HH:MM:SS')]);
if (dump_movies)
    writeVideoToFile(abs(detail_enhanced), 'movie_detail_enhanced_3d', '..\results\3dGabor');
end
