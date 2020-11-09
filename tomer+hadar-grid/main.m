clearvars;
close all;
clc;
dump_movies=1;

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

% vid_matrix = vid_matrix_orig;
%%
% % % % % % % % % % % % % % % % %
%    Masking using Center Mass  %
% % % % % % % % % % % % % % % % %
disp(['Start Masking using Center Mass ', datestr(datetime('now'),'HH:MM:SS')]);

block_size = 8;
cmmask_matrix = cmmask(vid_matrix,block_size,5);

% Apply Masking
vid_after_mask = zeros(size(vid_matrix));
for j=1:size(cmmask_matrix,3)
    % This results in white blocks where the mask is black (a lot of
    % movement - probably noise)
    vid_after_mask(:,:,j) = double(vid_matrix(:,:,j) | ~cmmask_matrix(:,:,j));
end
vid_after_mask(:,:,size(cmmask_matrix,3):size(vid_matrix,3)) = double(vid_matrix(:,:,size(cmmask_matrix,3):size(vid_matrix,3)));
%implay(vid_after_mask);
%%%%%%% FIXME remove this
%vid_after_mask = double(vid_matrix);
%%%%%%% FIXME remove this
%%
disp(['Done ' datestr(datetime('now'),'HH:MM:SS')]);

%save('vid_after_mask.mat','vid_after_mask');
%load('vid_after_mask.mat','vid_after_mask');

if (dump_movies)
    aviobj = VideoWriter(['..\results\tomer+hadar-grid\movie_center_mass_',num2str(block_size),'.avi']);
    aviobj.Quality = 80;
    open(aviobj);
    for i =1:size(vid_after_mask,3)
       writeVideo(aviobj,vid_after_mask(:,:,i));   
    end
    close(aviobj);
end

%%
% % % % % % % % % % % % % % % %
%    Filtering using 3D STD   %
% % % % % % % % % % % % % % % %
disp(['Start Filtering using 3D STD ', datestr(datetime('now'),'HH:MM:SS')]);

ktNum   = 5;
wtNum   = 5;
tNum    = wtNum+ktNum-1;
center  = ceil(tNum/2);
SelT    = center + ( -(ktNum-1)/2-(wtNum-1)/2 : +(ktNum-1)/2+(wtNum-1)/2 );
N = 5;
for i = 1: 1 : size(vid_after_mask,3) - size(SelT,2)
    
    Iseq = vid_after_mask(:,:, SelT + i - 1);

    StdPyramid = GenerateStdImagePyramid(Iseq,N);

    S = StdPyramid{1};
    Msdt(:,:,i) = (S-min(S(:)))./(max(max(S-min(S(:)))) + 1e-6); 
    % added small const to denominator to avoid division by zero
end

disp(['Done ' datestr(datetime('now'),'HH:MM:SS')]);

%save('std_vid.mat','Msdt');
%load('std_vid.mat','Msdt');

if (dump_movies)
    aviobj = VideoWriter(['..\results\tomer+hadar-grid\movie_std_',num2str(block_size),'.avi']);
    aviobj.Quality = 80;
    open(aviobj);
    for i =1:size(Msdt,3)
       writeVideo(aviobj,Msdt(:,:,i));   
    end
    close(aviobj);
end

%%
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%    Taking threshold and find 3D connected-component in the matrix   %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
disp(['Start threshold and connected-component ', datestr(datetime('now'),'HH:MM:SS')]);

bw = logical(Msdt*0);
largest_cc_obj = bw;

for i = 1:size(bw,3)
   bw(:,:,i) = imbinarize(Msdt(:,:,i),'adaptive','ForegroundPolarity','dark','Sensitivity',0);
end

% it might be a good idea to use LI here, as the connectivity map (below)
% regresses to zero for smaller grid sizes

CC = bwconncomp(~bw,6); % it is possible to search also for 18/26-connected Connectivities
numOfPixels = cellfun(@numel,CC.PixelIdxList);
[~,indexOfMax] = max(numOfPixels);
largest_cc_obj(CC.PixelIdxList{indexOfMax}) = 1;

disp(['Done ' datestr(datetime('now'),'HH:MM:SS')]);

if (dump_movies)
    aviobj = VideoWriter(['..\results\tomer+hadar-grid\movie_std_cc_obj_',num2str(block_size),'.avi']);
    aviobj.Quality = 80;
    open(aviobj);
    for i =1:size(largest_cc_obj,3)
       writeVideo(aviobj,uint8(largest_cc_obj(:,:,i))*255);   
    end
    close(aviobj);
end
%%
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
%    Find Boundry of object from Original Image based on location from the connected-component    %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

% TODO Add Code Here
%https://www.mathworks.com/help/images/ref/poly2mask.html
%https://www.mathworks.com/help/matlab/ref/boundary.html
%https://www.mathworks.com/matlabcentral/fileexchange/60690-boundary-extraction-identification-and-tracing-from-point-cloud-data

%%%%
% corners are not good direction:
% new Idea:
% need to build probability map according to:
% 1. most acurate information for this frame is largest_cc_obj(:,:,frame_idx)
%    maybe somehow difuse this information to close pixels 
% 2. we almost positive that the object is not present in (x,y) which (R7(x,y) == 1) because
% we did not find texture at that pixel
% 3. need to build combine map of 4-6 frames (from past and future)
% 4. apply LF on map to reveal under theshold signal
%%%%

disp(['Start prepare probability map ', datestr(datetime('now'),'HH:MM:SS')]);

DISK7 = strel('disk',7);
D7 = single(DISK7.Neighborhood);
H7 = sum(sum(D7.*D7));

sigma = 2;
sz = 5;    % length of gaussFilter vector
x = linspace(-sz / 2, sz / 2, sz);
gaussFilter = exp(-x .^ 2 / (2 * sigma ^ 2));
gaussFilter = gaussFilter / sum (gaussFilter); % normalize

for img_idx =16:size(largest_cc_obj,3)
    [col_s,row_s,col_e,row_e] = find_bounding_box(largest_cc_obj(:,:,img_idx));
    ROI_IMG=(vid_matrix(row_s:row_e,col_s:col_e,img_idx));
    C7 = conv2(single(ROI_IMG),D7,'same');
    R7 = C7==H7;

    low_prob = false(size(largest_cc_obj(:,:,img_idx)));
    low_prob(row_s+6:row_e-6,col_s+6:col_e-6) = ~R7(7:end-6,7:end-6);

    prob_map = single(0.05*low_prob);
    prob_map(largest_cc_obj(:,:,img_idx)==1) = 1;
    p_map(:,:,img_idx)=prob_map;
end
for i =5:size(p_map,3)
   merge_prob(:,:,i-4) = p_map(:,:,i-4)*gaussFilter(1) + p_map(:,:,i-3)*gaussFilter(2) + p_map(:,:,i-2)*gaussFilter(3) + p_map(:,:,i-1)*gaussFilter(4)  + p_map(:,:,i)*gaussFilter(5);
   %merge_prob = (merge_prob - min(merge_prob(:))) / ( max(merge_prob(:)) - min(merge_prob(:)) ); % norm images between 0-1
end

disp(['Done ' datestr(datetime('now'),'HH:MM:SS')]);

if (dump_movies)
    aviobj = VideoWriter(['..\results\tomer+hadar-grid\movie_prob_map_',num2str(block_size),'.avi']);
    aviobj.Quality = 80;
    open(aviobj);
    for i =1:size(merge_prob,3)
       writeVideo(aviobj,uint8(merge_prob(:,:,i)*255));
    end
    close(aviobj);
end

%%
% % % % % % % % % % % % % % % % % % % % % %
%    Combine all results to Final movie   %
% % % % % % % % % % % % % % % % % % % % % %
aviobj = VideoWriter(['..\results\tomer+hadar-grid\movie_final_w_cc_obj_',num2str(block_size),'.avi']);
aviobj.Quality = 80;
open(aviobj);
for i =1:15
   writeVideo(aviobj,uint8(vid_matrix(:,:,i))*255);   
end
%frames = {};
for i =16:1:size(largest_cc_obj,3)
    alpha=0.8;
    mask = cat(3,uint8(zeros(size(vid_matrix(:,:,i)))),uint8(largest_cc_obj(:,:,i)*255),uint8(zeros(size(vid_matrix(:,:,i)))));
    vid  = repmat(uint8(vid_matrix(:,:,i)*255),1,1,3);
    frame = vid*alpha + (1-alpha)*mask;
    %frames{end+1} = frame;
    writeVideo(aviobj,frame);   
end
close(aviobj);
%%
% % % % % % % % % % % % % % % % % % % % % %
%    Combine all results to Final movie   %
% % % % % % % % % % % % % % % % % % % % % %
aviobj = VideoWriter(['..\results\tomer+hadar-grid\movie_final_w_prob_map_',num2str(block_size),'.avi']);
aviobj.Quality = 80;
open(aviobj);
for i =1:15
   writeVideo(aviobj,uint8(vid_matrix(:,:,i))*255);   
end
%frames = {};
for i =16:1:size(vid_matrix,3)-12
    alpha=0.8;
    mask = cat(3,uint8(zeros(size(vid_matrix(:,:,i)))),uint8(merge_prob(:,:,i-2)*255),uint8(zeros(size(vid_matrix(:,:,i)))));
    vid  = repmat(uint8(vid_matrix(:,:,i)*255),1,1,3);
    frame = vid*alpha + (1-alpha)*mask;
    %frames{end+1} = frame;
    writeVideo(aviobj,frame);   
end
for i =size(vid_matrix,3)-2:size(vid_matrix,3)
   writeVideo(aviobj,uint8(vid_matrix(:,:,i))*255);   
end
close(aviobj);

disp(['Done All ' datestr(datetime('now'),'HH:MM:SS')]);
%%% End of main program
