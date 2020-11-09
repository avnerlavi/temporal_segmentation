dump_movies = true;
verbose = true;
disp(['Start ', datestr(datetime('now'),'HH:MM:SS')]);

% % % % % % % % % % % % % %
%    Read movie to matrix %
% % % % % % % % % % % % % %

vid_matrix_orig = read_movie('../captcha_running.avi', true);

% % % % % % % % % % % %
%    Downscale video  %
% % % % % % % % % % % %
vid_matrix = imresize(vid_matrix_orig, 0.3);
save('vid_matrix.mat','vid_matrix');
load('vid_matrix.mat','vid_matrix');
%%

disp(['Running Pyramid ', datestr(datetime('now'),'HH:MM:SS')]);
seq_size = 9;
vid_pyr = zeros(size(vid_matrix));
for i = ceil(seq_size/2):size(vid_matrix,3) - ceil(seq_size/2)
    temp = GenerateStdImagePyramid2(vid_matrix(:,:,i-ceil(seq_size/2)+1:i+floor(seq_size/2)),5);
    temp{end} = temp{end} - min(temp{end}(:));
    temp{end} = temp{end}/max(temp{end}(:));
    vid_pyr(:,:,i) = temp{end};
end
vid_pyr = vid_pyr(:,:,ceil(seq_size/2):size(vid_matrix,3) - ceil(seq_size/2));

if (dump_movies)
    aviobj = VideoWriter('..\results\no-grid\movie_stdPyramid2_noGrid.avi');
    aviobj.Quality = 80;
    open(aviobj);
    for i =1:size(vid_pyr,3)
       writeVideo(aviobj,vid_pyr(:,:,i));   
    end
    close(aviobj);
end

disp(['Done ' datestr(datetime('now'),'HH:MM:SS')]);
if(verbose)
    implay(vid_pyr(10:end-10,10:end-10,:));
end