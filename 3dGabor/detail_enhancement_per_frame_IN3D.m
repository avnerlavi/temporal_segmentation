dump_movies = true;
disp(['Start ', datestr(datetime('now'),'HH:MM:SS')]);

vid_matrix = readVideoFromFile('../results/no-grid/movie_stdPyramid_noGrid.avi', false);
vid_matrix = imresize(vid_matrix, 0.3);
vid_matrix(vid_matrix > 1) = 1;
vid_matrix(vid_matrix < 0) = 0;

numOfScales = 8;
temp = vid_matrix;
for i=1:3
    s = size(temp);
    vid_padded = zeros([s(1) + 2*numOfScales, s(2), s(3)]);
    vid_padded(numOfScales+1:end-numOfScales, :, :) = temp;
    vid_padded(1:numOfScales,:,:) = repmat(temp(1,:,:), [numOfScales, 1, 1]);
    vid_padded(end-numOfScales+1:end,:,:) = repmat(temp(end,:,:), [numOfScales, 1, 1]);
    temp = permute(vid_padded, [2, 3, 1]);
end
vid_matrix = temp;

detail_enhanced = ...
    computeCombinedLF_IN3D(vid_matrix, ...
    2, ... Azimuths number
    6, ... elevations number
    60, ... elevation half angle
    4 , ... scale number
    10, ... base facilitation length
    0, ... alpha
    2, ... m1
    2  ... m2
    );

detail_enhanced = detail_enhanced(numOfScales+1:end-numOfScales, numOfScales+1:end-numOfScales, numOfScales+1:end-numOfScales);
detail_enhanced = detail_enhanced/max(abs(detail_enhanced(:)));

disp(['Done ' datestr(datetime('now'),'HH:MM:SS')]);
if (dump_movies)
    writeVideoToFile(abs(detail_enhanced), 'movie_detail_enhanced_3d', '..\results\3dGabor');
end
