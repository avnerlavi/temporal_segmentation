function [vid_pyr] = StdUsingPyramidFunc(vid_matrix)
seq_size = 9;
pyr_lvl = 0;
vid_pyr = zeros([ceil(size(vid_matrix,1)/2^pyr_lvl),ceil(size(vid_matrix,2)/2^pyr_lvl),size(vid_matrix,3)]);
for i = ceil(seq_size/2):size(vid_matrix,3) - ceil(seq_size/2)
    temp = GenerateStdImagePyramid2(vid_matrix(:,:,i-ceil(seq_size/2)+1:i+floor(seq_size/2)),5);
    vid_pyr(:,:,i) = temp{end};
end

vid_pyr = vid_pyr(:,:,ceil(seq_size/2):size(vid_matrix,3) - ceil(seq_size/2));
vid_pyr = minMaxNorm(vid_pyr);
end

