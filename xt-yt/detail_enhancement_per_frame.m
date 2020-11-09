dump_movies = true;

captcha_running_v = VideoReader('../captcha_running.avi');
i=1;
while hasFrame(captcha_running_v)
    captcha_running_mat(:,:,:,i) = readFrame(captcha_running_v);
    i=i+1;
end
vid_matrix = uint8(captcha_running_mat(:,:,:,:));

squeezed = squeeze(vid_matrix(:,:,1,:));
permuted = permute(squeezed, [1,3,2]);
if (dump_movies)
    aviobj = VideoWriter('new\movie_permuted_x-t.avi');
    aviobj.Quality = 80;
    open(aviobj);
    for i =1:size(permuted,3)
       writeVideo(aviobj,permuted(:,:,i));   
    end
    close(aviobj);
end
detail_enhanced_permuted = zeros(size(permuted));
detail_enhanced = zeros(size(squeezed));
for i=1:size(permuted,3)
    detail_enhanced_permuted(:,:,i) = computeCombinedLF(permuted(:,:,i), 8, 4, 0, 2, 2);
    detail_enhanced(:,i,:) = detail_enhanced_permuted(:,:,i);
end

detail_enhanced_permuted = (detail_enhanced_permuted + 1) / 2;
detail_enhanced = (detail_enhanced + 1) / 2;

if (dump_movies)
    aviobj = VideoWriter('new\movie_detail_enhanced_permuted_x-t.avi');
    aviobj.Quality = 80;
    open(aviobj);
    for i =1:size(detail_enhanced_permuted,3)
       writeVideo(aviobj,detail_enhanced_permuted(:,:,i));   
    end
    close(aviobj);
end

if (dump_movies)
    aviobj = VideoWriter('new\movie_detail_enhanced_x-t.avi');
    aviobj.Quality = 80;
    open(aviobj);
    for i =1:size(detail_enhanced,3)
       writeVideo(aviobj,detail_enhanced(:,:,i));   
    end
    close(aviobj);
end
