vid_matrix = readVideoFromFile('captcha_running.avi',true);
SE = strel('cube',2);
vid_matrix = imdilate(vid_matrix,SE);
CC = bwconncomp(~vid_matrix,18);
CC_matrix = zeros(size(vid_matrix));
for i=1:length(CC.PixelIdxList)
    CC_matrix(CC.PixelIdxList{i}) = length([CC.PixelIdxList{i}]);
end
CC_matrix = CC_matrix/max(CC_matrix,[],'all');
implay(CC_matrix)