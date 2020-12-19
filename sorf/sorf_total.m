dump_movies = true;
addpath(genpath('../3dGabor'));
addpath(genpath('../utils'));
disp(['Start ', datestr(datetime('now'),'HH:MM:SS')]);

vid_matrix = readVideoFromFile('..\results\no-grid\movie_stdPyramid_noGrid.avi', false);
vid_matrix = imresize(vid_matrix, 1/3);
vid_matrix(vid_matrix > 1) = 1;
vid_matrix(vid_matrix < 0) = 0;

numOfScales = 4;
vid_matrix = PadVideoReplicate(vid_matrix,2*numOfScales);

[~, vidScalesPyr] = ...
    computeCombinedLF_IN3D(vid_matrix, ...
    8, ... Azimuths number
    6, ... elevations number
    25, ... elevation half angle
    numOfScales , ... scale number
    10, ... base facilitation length
    0, ... alpha
    1, ... m1
    2  ... m2
    );

c_local_tot = ones(size(vid_matrix));
gauss_local = Gaussian3D([0, 0], 0, [1,1,1], []);
beta = 0.4;

for k=numOfScales:-1:1
    %     c_local_prev = c_local_curr;
    c_local_curr = computeContrast(vidScalesPyr{k}, gauss_local);
    c_local_tot = c_local_tot + c_local_curr;
%     gf = (c_local_curr + beta)./(c_local_prev + beta);
%     vidScaled = vidScaled .* gf;
end

gauss_remote = Gaussian3D([0, 0], 0, [3,3,3], []);
gauss_remote = gauss_remote / max(gauss_remote(:));
c_remote = computeContrast(c_local_tot, gauss_remote);
gf_tot = (c_local_tot + beta)./(c_remote + beta);

vid_scaled_tot = ones(size(vid_matrix));
for k=numOfScales:-1:1
vidScaled = vidScalesPyr{k};
vid_scaled_tot = vid_scaled_tot + vidScaled .* gf_tot;
end

vid_scaled_tot = sign(vid_scaled_tot).*abs(vid_scaled_tot).^(1/2);  %this reuses m2
vid_scaled_tot = vid_scaled_tot / max(abs(vid_scaled_tot(:)));

detail_enhanced = vid_scaled_tot(2*numOfScales+1:end-2*numOfScales, 2*numOfScales+1:end-2*numOfScales, 2*numOfScales+1:end-2*numOfScales);
detail_enhanced = detail_enhanced/max(abs(detail_enhanced(:)));
disp(['Done ' datestr(datetime('now'),'HH:MM:SS')]);
if (dump_movies)
    writeVideoToFile(abs(detail_enhanced), 'movie_detail_enhanced_3d', '..\results\sorf');
end
vid = abs(detail_enhanced);
implay(vid);