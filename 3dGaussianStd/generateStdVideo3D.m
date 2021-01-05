dump_movies = false;
disp(['Start ', datestr(datetime('now'),'HH:MM:SS')]);
root = getenv('TemporalSegmentation');
vid_matrix = readVideoFromFile([root,'\captcha_running.avi'], false);
vid_matrix = imresize(vid_matrix, 1/3);
vid_matrix(vid_matrix > 1) = 1;
vid_matrix(vid_matrix < 0) = 0;

numOfScales = 1;
vid_matrix = PadVideoReplicate(vid_matrix,2*numOfScales);
detail_enhanced = ...
    computeCombinedStd_IN3D(vid_matrix, ...
    4, ... Azimuths number
    3, ... elevations number
    30, ... elevation half angle
    numOfScales , ... scale number
    1, ... m1
    1  ... m2
    );

detail_enhanced = detail_enhanced(2*numOfScales+1:end-2*numOfScales, 2*numOfScales+1:end-2*numOfScales, 2*numOfScales+1:end-2*numOfScales);
detail_enhanced = minMaxNorm(detail_enhanced);

disp(['Done ' datestr(datetime('now'),'HH:MM:SS')]);
if (dump_movies)
    writeVideoToFile(abs(detail_enhanced), 'movie_std_3d', [root,'\results\3dStd']);
end
vid = abs(detail_enhanced);
implay(vid)