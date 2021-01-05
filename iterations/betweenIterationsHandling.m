root = getenv('TemporalSegmentation');
vid_matrix = readVideoFromFile([root , '\results\iterations\conf_4\vid_conf_4_masked_large.avi'], false);
sizeRef = readVideoFromFile([root , '\results\no-grid\movie_stdPyramid_noGrid.avi'], false);
facilitationLength = 10;
vid_trimmed = zeros(size(vid_matrix));
sizeMask = zeros(size(vid_matrix));
sizeMask(ceil(facilitationLength/4)+1:end-ceil(facilitationLength/4)...
        ,ceil(facilitationLength/4)+1:end-ceil(facilitationLength/4)...
        ,ceil(facilitationLength/4)+1:end-ceil(facilitationLength/4)) = 1;

vid_trimmed(sizeMask == 1) = vid_matrix(sizeMask == 1);
vid_trimmed = minMaxNorm(vid_trimmed);
threshold = 0.3;
CC = bwconncomp(vid_trimmed>threshold);
numOfPixels = cellfun(@numel,CC.PixelIdxList);
AreaOfLargestCC = max(numOfPixels); 
CC_area_threshold = 0.5;
indexOfMax = find(numOfPixels > CC_area_threshold * AreaOfLargestCC);
numOfCC2keep = length(indexOfMax);
% numOfCC2keep = 3;
% [~,indexOfMax] = maxk(numOfPixels , numOfCC2keep);
vid_CC = zeros(size(vid_trimmed));

for i = 1:numOfCC2keep
    vid_CC(CC.PixelIdxList{indexOfMax(i)}) = 1;
end
vid_CC = minMaxNorm(vid_CC);
%% large gaussian
g = Gaussian3dIso(3,11);
g = minMaxNorm(g)/4;
large_mask = convn(vid_CC,g,'same');
vid_CC = safeResize(vid_CC,size(sizeRef));
vid_CC(vid_CC > 1) = 1;
vid_CC(vid_CC < 0) = 0;
%mask = convn(vid_CC,g,'same');
%large_mask = imresize3(large_mask,size(sizeRef));
large_mask(large_mask > 1) = 1;
large_mask(large_mask < 0) = 0;
%implay(0.9*mask.*sizeRef+0.1*sizeRef);

%% smol gaussian
g = Gaussian3dIso(1,[]);
g = minMaxNorm(g)/4;
vid_CC = safeResize(vid_CC,size(sizeRef));
vid_CC(vid_CC > 1) = 1;
vid_CC(vid_CC < 0) = 0;
small_mask = convn(vid_CC,g,'same');
small_mask(small_mask > 1) = 1;
small_mask(small_mask < 0) = 0;