disp(['Start ', datestr(datetime('now'),'HH:MM:SS')]);

dump_movies = true;
root = getenv('TemporalSegmentation');
addpath(genpath([root,'/utils']));

inFileDir = [root,'/captcha_running.avi'];
vid_matrix_orig = readVideoFromFile(inFileDir, false);
vid_matrix = imresize(vid_matrix_orig, 0.25);

CCLFParams = struct;
CCLFParams.numOfScales = 1;
CCLFParams.elevationHalfAngle = 0;
CCLFParams.azimuthNum = 4;
CCLFParams.elevationNum = 1;
CCLFParams.m1 = 1;
CCLFParams.m2 = 1;

vid_std = ...
    computeCombinedStd_IN3D(vid_matrix, ...
    CCLFParams.azimuthNum, ...
    CCLFParams.elevationNum, ...
    CCLFParams.elevationHalfAngle, ...
    CCLFParams.numOfScales , ...
    CCLFParams.m1, ...
    CCLFParams.m2  ...
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
    saveParams([root,'\results\3dStd'], inFileDir, CCLFParams, min_val, max_val);
end


% %%
% 
% dump_movies = false;
% disp(['Start ', datestr(datetime('now'),'HH:MM:SS')]);
% root = getenv('TemporalSegmentation');
% vid_matrix = readVideoFromFile([root,'\captcha_running.avi'], false);
% vid_matrix = imresize(vid_matrix, 1/3);
% vid_matrix(vid_matrix > 1) = 1;
% vid_matrix(vid_matrix < 0) = 0;
% 
% numOfScales = 1;
% vid_matrix = PadVideoReplicate(vid_matrix,2*numOfScales);
% detail_enhanced = ...
%     computeCombinedStd_IN3D(vid_matrix, ...
%     4, ... Azimuths number
%     3, ... elevations number
%     30, ... elevation half angle
%     numOfScales , ... scale number
%     1, ... m1
%     1  ... m2
%     );
% 
% detail_enhanced = detail_enhanced(2*numOfScales+1:end-2*numOfScales, 2*numOfScales+1:end-2*numOfScales, 2*numOfScales+1:end-2*numOfScales);
% detail_enhanced = minMaxNorm(detail_enhanced);
% 
% disp(['Done ' datestr(datetime('now'),'HH:MM:SS')]);
% if (dump_movies)
%     writeVideoToFile(abs(detail_enhanced), 'movie_std_3d', [root,'\results\3dStd']);
% end
% vid = abs(detail_enhanced);
% implay(vid)