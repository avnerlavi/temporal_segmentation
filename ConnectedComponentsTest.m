vid_matrix = readVideoFromFile('captcha_running.avi',true);
vid_mask = readVideoFromFile('F:\Matlab\docs\temporal_segmentation\results\iterativeDetection\iterative_mask\movie_total_mask.avi',false);
vid_mask = safeResize(vid_mask,size(vid_matrix));
SE = strel('cube',2);
vid_matrix = imdilate(vid_matrix,SE);
CC = bwconncomp(~vid_matrix,26);
CC_matrix = ones(size(vid_matrix));
threshold = 0.1;
for i=1:length(CC.PixelIdxList)
    totalweight  = sum(vid_mask(CC.PixelIdxList{i}));
    if(totalweight  > threshold*length([CC.PixelIdxList{i}]))
      CC_matrix(CC.PixelIdxList{i}) = 0;  
    end
%    CC_matrix(CC.PixelIdxList{i}) = length([CC.PixelIdxList{i}]);
    
end
%CC_matrix = CC_matrix/max(CC_matrix,[],'all');
CC_matrix = imerode(CC_matrix,SE);
implay(CC_matrix)