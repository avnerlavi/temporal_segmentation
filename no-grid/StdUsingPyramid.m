dump_movies=true;
verbose = true;
disp(['Start ', datestr(datetime('now'),'HH:MM:SS')]);

% % % % % % % % % % % % % %
%    Read movie to matrix %
% % % % % % % % % % % % % %
root = getenv('TemporalSegmentation');
vid_matrix_orig = readVideoFromFile([root,'/captcha_running.avi'], true);

% % % % % % % % % % % %
%    Downscale video  %
% % % % % % % % % % % %
vid_matrix = imresize(vid_matrix_orig, 0.25);

[vid_pyr] = StdUsingPyramidFunc(vid_matrix);
%%
if (dump_movies)
    writeVideoToFile(vid_pyr, 'movie_stdPyramid_noGrid', [root,'\results\no-grid']);
end

disp(['Done ' datestr(datetime('now'),'HH:MM:SS')]);
if(verbose)
    implay(vid_pyr);
end