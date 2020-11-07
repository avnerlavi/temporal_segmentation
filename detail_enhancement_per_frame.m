captcha_running_v = VideoReader('captcha_running.avi');
i=1;
while hasFrame(captcha_running_v)
    captcha_running_mat(:,:,:,i) = readFrame(captcha_running_v);
    i=i+1;
end
vid_matrix = uint8(captcha_running_mat(:,:,:,:));

squeezed = squeeze(vid_matrix(:,:,1,:));
permuted = permute(squeezed, [1,3,2]);
detail_enhanced = zeros(size(squeezed));
for i=1:size(permuted,3)
    detail_enhanced(:,i,:)  = detailEnhancement(permuted(:,:,i), 8, 4, false);
end
implay(detail_enhanced);