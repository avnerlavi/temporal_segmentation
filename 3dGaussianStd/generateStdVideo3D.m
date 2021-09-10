disp(['Start ', datestr(datetime('now'),'HH:MM:SS')]);

dump_movies = true;
root = getenv('TemporalSegmentation');
addpath(genpath([root,'/utils']));

elevationHalfAngle = 60;
resizeFactors = [1/4, 1/4, 1];

inFileDir = [root,'/resources/man_running.avi'];
vid_matrix_orig = readVideoFromFile(inFileDir, false);
vid_matrix = safeResize(vid_matrix_orig, resizeFactors.*size(vid_matrix_orig));

CCLFParams = struct;
CCLFParams.numOfScales = 4;
CCLFParams.elevationHalfAngle = atand(tand(elevationHalfAngle) * resizeFactors(1) / resizeFactors(3));
CCLFParams.azimuthNum = 4;
CCLFParams.elevationNum = 4;
CCLFParams.sigmaSpatial =  [  3,  3,0.1];
CCLFParams.sigmaTemporal = [0.1,0.1,  7];
CCLFParams.m1 = 1;
CCLFParams.m2 = 2;

vid_std = ...
    computeCombinedStd_IN3D(vid_matrix, ...
    CCLFParams.azimuthNum, ...
    CCLFParams.elevationNum, ...
    CCLFParams.elevationHalfAngle, ...
    CCLFParams.numOfScales, ...
    CCLFParams.sigmaSpatial, ...
    CCLFParams.sigmaTemporal, ...
    CCLFParams.m1, ...
    CCLFParams.m2, ...
    2 ...
    );

vid_std_squared = sign(vid_std).*(vid_std.^2);
vidOut = minMaxNorm(vid_std_squared);
implay(vidOut);
maintainFitToWindow();
disp(['Done ' datestr(datetime('now'),'HH:MM:SS')]);
if (dump_movies)
    writeVideoToFile(vidOut, 'movie_vid_std_3d', [root,'\results\3dStd']);
    max_val = max(vid_std, [], 'all');
    min_val = min(vid_std, [], 'all');
    max_val_squared = max(vid_std_squared, [], 'all');
    min_val_squared = min(vid_std_squared, [], 'all');
    saveParams([root,'\results\3dStd'], inFileDir, CCLFParams, min_val, max_val, min_val_squared, max_val_squared);
    save([root,'\results\3dStd\params.mat'], 'inFileDir', 'CCLFParams', 'min_val', 'max_val', 'min_val_squared', 'max_val_squared');
end
