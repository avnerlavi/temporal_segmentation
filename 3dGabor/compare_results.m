root = getenv('TemporalSegmentation');
addpath(genpath([root,'/utils']));

folders_list = {
    [root,'/results/material_from_ynon_19_1_22_edited_results/filtered_lower_dynamic_range/'],...
    [root,'/results/material_from_ynon_19_1_22_edited_results/filtered_base/'],...
    [root,'/results/material_from_ynon_19_1_22_edited_results/filtered_higher_dynamic_range/']};
%vid_name = 'movie_detail_enhanced_3d_abs.avi';
%vid_name = 'movie_detail_enhanced_3d_minmax.avi';
%vid_name = 'movie_combined_norm.avi';
vid_name = 'movie_combined_clipped.avi';
out_dir = [root,'/results/material_from_ynon_19_1_22_edited_results/dynamic_range_comparisons/'];
for i = 1:length(folders_list)
    file_list = dir(fullfile(folders_list{i}, '**\',vid_name));
    file_list = file_list(~[file_list.isdir]);
    sub_folders = {file_list.folder};
    curr_relative_paths = cellfun(@(x) x(length(folders_list{i}):end),sub_folders,'UniformOutput',false);
    if(i==1)
        relative_paths = curr_relative_paths;
    else
        relative_paths = intersect(curr_relative_paths,relative_paths);
    end
end
for j = 1:length(relative_paths)
    videos = cell(length(folders_list)+1,1);
    for i = 1:length(folders_list)
        videos{i+1} = readVideoFromFile(fullfile(folders_list{i},relative_paths{j},vid_name),false);
        if(i == 1)
            params = readcell(fullfile(folders_list{1},relative_paths{j},'params.xls'));
            videos{1} = readVideoFromFile(params{1,2},false);
            videos{1} = safeResize(videos{1},size(videos{2}));
        end
    end
    [total_vid] = compareNVids(videos,'verbose',false);
    writeVideoToFile(total_vid, ...
        vid_name, fullfile(out_dir,relative_paths{j}));
end