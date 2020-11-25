dump_movies=true;
verbose = true;
disp(['Start ', datestr(datetime('now'),'HH:MM:SS')]);

% % % % % % % % % % % % % %
%    Read movie to matrix %
% % % % % % % % % % % % % %

vid_matrix_orig = readVideoFromFile('../captcha_running.avi', true);

% % % % % % % % % % % %
%    Downscale video  %
% % % % % % % % % % % %
vid_matrix = imresize(vid_matrix_orig, 0.25);
%%

disp(['Running Pyramid ', datestr(datetime('now'),'HH:MM:SS')]);
seq_size = 9;
pyr_lvl = 0;
vid_pyr = zeros([ceil(size(vid_matrix,1)/2^pyr_lvl),ceil(size(vid_matrix,2)/2^pyr_lvl),size(vid_matrix,3)]);
for i = ceil(seq_size/2):size(vid_matrix,3) - ceil(seq_size/2)
    temp = GenerateStdImagePyramid2(vid_matrix(:,:,i-ceil(seq_size/2)+1:i+floor(seq_size/2)),5);
    %vid_pyr(:,:,i) = temp{pyr_lvl+2};
    vid_pyr(:,:,i) = temp{end};
%     vid_pyr(:,:,i) = vid_pyr(:,:,i)- min(vid_pyr(:,:,i),[],'all');
%     vid_pyr(:,:,i) = vid_pyr(:,:,i)/max(vid_pyr(:,:,i),[],'all');
end
vid_pyr = vid_pyr(:,:,ceil(seq_size/2):size(vid_matrix,3) - ceil(seq_size/2));
vid_pyr = vid_pyr - min(vid_pyr(:));
vid_pyr = vid_pyr/max(vid_pyr(:));

if (dump_movies)
    writeVideoToFile(vid_pyr, 'movie_stdPyramid_noGrid', '..\results\no-grid');
end

disp(['Done ' datestr(datetime('now'),'HH:MM:SS')]);
if(verbose)
    implay(vid_pyr);
end