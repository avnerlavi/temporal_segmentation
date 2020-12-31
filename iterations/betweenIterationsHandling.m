vid_matrix = readVideoFromFile('..\results\3dGabor\movie_detail_enhanced_3d.avi', false);
sizeRef = readVideoFromFile('..\results\no-grid\movie_stdPyramid_noGrid.avi', false);
facilitationLength = 10;
vid_trimmed = zeros(size(vid_matrix));
sizeMask = zeros(size(vid_matrix));
sizeMask(ceil(facilitationLength/4)+1:end-ceil(facilitationLength/4)...
        ,ceil(facilitationLength/4)+1:end-ceil(facilitationLength/4)...
        ,ceil(facilitationLength/4)+1:end-ceil(facilitationLength/4)) =1;

vid_trimmed(sizeMask == 1) = vid_matrix(sizeMask == 1);
vid_trimmed = minMaxNorm(vid_trimmed);
threshold = 0.2;
CC = bwconncomp(vid_trimmed>threshold);
numOfPixels = cellfun(@numel,CC.PixelIdxList);
numOfCC2keep = 1;
[AreasofMax,indexOfMax] =  maxk(numOfPixels , numOfCC2keep);
vid_CC = zeros(size(vid_trimmed));

for i= 1:numOfCC2keep
    vid_CC(CC.PixelIdxList{indexOfMax(i)}) = 1;
end
vid_CC = minMaxNorm(vid_CC);
g = Gaussian3dIso(3,11);
g = minMaxNorm(g)/4;
mask = convn(vid_CC,g,'same');
vid_CC = imresize3(vid_CC,size(sizeRef));
vid_CC(vid_CC > 1) = 1;
vid_CC(vid_CC < 0) = 0;
%mask = convn(vid_CC,g,'same');
mask = imresize3(mask,size(sizeRef));
mask(mask > 1) = 1;
mask(mask < 0) = 0;
implay(mask.*sizeRef+0.1*sizeRef)
