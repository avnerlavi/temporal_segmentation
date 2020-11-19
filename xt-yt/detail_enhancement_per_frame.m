dump_movies = true;
disp(['Start ', datestr(datetime('now'),'HH:MM:SS')]);

vid_matrix = readVideoFromFile('../results/no-grid/movie_stdPyramid_noGrid.avi', false);
vid_matrix = imresize(vid_matrix, 0.3);
vid_matrix(vid_matrix > 1) = 1;
vid_matrix(vid_matrix < 0) = 0;

permutedAxis = 'y';
if permutedAxis == 'y'
    permuted = permute(vid_matrix, [2,3,1]);
else
    permuted = permute(vid_matrix, [1,3,2]);
end

if (dump_movies)
    writeVideoToFile(permuted, ['movie_permuted_',permutedAxis,'-t'], '..\results\xt-yt');
end

detail_enhanced_permuted = zeros(size(permuted));
detail_enhanced = zeros(size(vid_matrix));
for i=1:size(permuted,3)
    detail_enhanced_permuted(:,:,i) = ...
        computeCombinedLF(permuted(:,:,i), ...
        12, ... orientation number
        4, ... scale number
        10, ... base facilitation length
        0, ... alpha
        2, ... m1
        2, ... m2
        false... isSteerableGaussian
        );
    
    if permutedAxis == 'y'
        detail_enhanced(i,:,:) = detail_enhanced_permuted(:,:,i);
    else
        detail_enhanced(:,i,:) = detail_enhanced_permuted(:,:,i);
    end
end

% detail_enhanced_permuted = (detail_enhanced_permuted + 1) / 2;
% detail_enhanced = (detail_enhanced + 1) / 2;
disp(['Done ' datestr(datetime('now'),'HH:MM:SS')]);
if (dump_movies)
    writeVideoToFile(abs(detail_enhanced_permuted), ['movie_detail_enhanced_permuted_', permutedAxis, '-t'], '..\results\xt-yt');
end

if (dump_movies)
    writeVideoToFile(abs(detail_enhanced), ['movie_detail_enhanced_', permutedAxis, '-t'], '..\results\xt-yt');
end
