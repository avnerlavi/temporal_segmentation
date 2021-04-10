dump_movies = true;
disp(['Start ', datestr(datetime('now'),'HH:MM:SS')]);
root = getenv('TemporalSegmentation');
addpath(genpath([root,'/utils']));

vid_matrix = readVideoFromFile([root ,'/resources/ultrasound_1_cropped.avi'], false);
resizeFactors = [1/4, 1/4, 1/4];
vid_matrix = safeResize(vid_matrix, resizeFactors.*size(vid_matrix));

permutedAxis = 't';
if permutedAxis == 'y'
    permuted = permute(vid_matrix, [2,3,1]);
elseif permutedAxis == 'x'
    permuted = permute(vid_matrix, [1,3,2]);
else
    permuted = vid_matrix;
end

if (dump_movies)
    writeVideoToFile(permuted, ['movie_permuted_',permutedAxis,'-t'], [root,'\results\xt-yt']);
end

detail_enhanced_permuted = zeros(size(permuted));
detail_enhanced = zeros(size(vid_matrix));
for i=1:size(permuted,3)
    detail_enhanced_permuted(:,:,i) = ...
        computeCombinedLF(permuted(:,:,i), ...
        8, ... orientation number
        1, ... scale number
        5, ... base facilitation length
        0, ... alpha
        1, ... m1
        2, ... m2
        false... isSteerableGaussian
        );
    
    if permutedAxis == 'y'
        detail_enhanced(i,:,:) = detail_enhanced_permuted(:,:,i);
    elseif permutedAxis == 'x'
        detail_enhanced(:,i,:) = detail_enhanced_permuted(:,:,i);
    else
        detail_enhanced(:,:,i) = detail_enhanced_permuted(:,:,i);
    end
end

% detail_enhanced_permuted = (detail_enhanced_permuted + 1) / 2;
% detail_enhanced = (detail_enhanced + 1) / 2;
disp(['Done ' datestr(datetime('now'),'HH:MM:SS')]);
if (dump_movies)
    writeVideoToFile(abs(detail_enhanced_permuted), ['movie_detail_enhanced_permuted_', permutedAxis, '-t'], [root,'\results\xt-yt']);
end

if (dump_movies)
    writeVideoToFile(abs(detail_enhanced), ['movie_detail_enhanced_', permutedAxis, '-t'], [root,'\results\xt-yt']);
end
