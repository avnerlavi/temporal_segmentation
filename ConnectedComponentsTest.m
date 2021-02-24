vid_matrix = readVideoFromFile('captcha_running.avi',true);
mask_name = 'F:\Matlab\docs\temporal_segmentation\results-09-02-2021-21_14\iterativeDetection\iterative_mask\movie_mask_0.222_0.222_0.333.avi';
vid_mask = readVideoFromFile(mask_name,false);
vid_mask = safeResize(vid_mask,size(vid_matrix));
SEType = 'cube';
SEval = 2;
SE = strel(SEType,SEval);
vid_matrix = imdilate(vid_matrix,SE);
connectivity = 18;
CC = bwconncomp(~vid_matrix,connectivity);
CC_matrix = ones(size(vid_matrix));
threshold = 0.5;
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
saveParams('F:\Matlab\docs\temporal_segmentation\results-09-02-2021-21_14\CCtest', threshold, connectivity, SEType, SEval,mask_name);