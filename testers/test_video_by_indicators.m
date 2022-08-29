function [video_orig,indicators_table] = test_video_by_indicators(video_orig_dir,video_res_dir,verbose)
root = getenv('TemporalSegmentation');
addpath(genpath([root,'/utils']));
video_orig = readVideoFromFile(video_orig_dir,false);
video_res = readVideoFromFile(video_res_dir,false);
dir_spilted = split(video_orig_dir,'\');
file_name = dir_spilted(end);
file_name = split(file_name,'.');
file_name = join(file_name(1:end-1),'.');
file_name = join([file_name,"tests.xlsx"],'_');
indicators_dir = [dir_spilted(1:end-1);"tests";file_name];
indicators_dir = join(indicators_dir,'\');
indicators_table = readtable(indicators_dir);
half_width = 25;
indicators = cell(size(indicators_table,1),2);
for i = 1:size(indicators_table,1)
    x = indicators_table(i,'x').Variables;
    y = indicators_table(i,'y').Variables;
    t = indicators_table(i,'t').Variables;
    [x,y,loc_x,loc_y] = convert_comparison_cooridinates_to_original(size(video_orig),x,y);
    min_x = max(1,x - half_width);
    min_y = max(1,y - half_width);
    max_x = min(size(video_orig,2),x + half_width);
    max_y = min(size(video_orig,1),y + half_width);
    indicators{i,1} = video_orig(min_y:max_y,min_x:max_x,t);
    indicators{i,2} = video_res(min_y:max_y,min_x:max_x,t);
    if(verbose)
        figure()
        subplot(1,2,1)
        imshow(indicators{i,1})
        title('original')
        subplot(1,2,2)
        imshow(indicators{i,2})
        title('result')
        suptitle(indicators_table(i,'comment').Variables)
    end
end

end

