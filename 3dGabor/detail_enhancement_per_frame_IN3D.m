dump_movies = true;
disp(['Start ', datestr(datetime('now'),'HH:MM:SS')]);

vid_matrix = readVideoFromFile('../results/no-grid/movie_stdPyramid_noGrid.avi', false);
vid_matrix = imresize(vid_matrix, 0.5);
vid_matrix(vid_matrix > 1) = 1;
vid_matrix(vid_matrix < 0) = 0;

numOfScales = 1;
vid_matrix = PadVideoReplicate(vid_matrix,2*numOfScales);

detail_enhanced = ...
    computeCombinedLF_IN3D(vid_matrix, ...
    8, ... Azimuths number
    6, ... elevations number
    60, ... elevation half angle
    numOfScales , ... scale number
    10, ... base facilitation length
    0, ... alpha
    2, ... m1
    2  ... m2
    );

detail_enhanced = detail_enhanced(2*numOfScales+1:end-2*numOfScales, 2*numOfScales+1:end-2*numOfScales, 2*numOfScales+1:end-2*numOfScales);
detail_enhanced = detail_enhanced/max(abs(detail_enhanced(:)));

disp(['Done ' datestr(datetime('now'),'HH:MM:SS')]);
if (dump_movies)
    writeVideoToFile(abs(detail_enhanced), 'movie_detail_enhanced_3d', '..\results\3dGabor');
end
