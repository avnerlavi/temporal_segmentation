function [minVideoValue,maxVideoValue] = SaveResults(input_video,response,enhaced_video,save_dir)

[~,comparison_clipped] = compareVids(input_video,enhaced_video,'verbose',false);
[~,conparison_normed] = compareVids(input_video,minMaxNorm(enhaced_video),'verbose',false);
minVideoValue = min(response(:));
maxVideoValue = max(response(:));
writeVideoToFile(minMaxNorm(response), ...
    'movie_detail_enhanced_3d_minmax', save_dir);
writeVideoToFile(abs(response), ...
    'movie_detail_enhanced_3d_abs', save_dir);
writeVideoToFile(minMaxNorm(enhaced_video), ...
    'movie_combined_norm', save_dir);
writeVideoToFile(max(min(enhaced_video,1),0), ...
    'movie_combined_clipped', save_dir);
writeVideoToFile(minMaxNorm(conparison_normed), ...
    'comparison_norm', save_dir);
writeVideoToFile(max(min(comparison_clipped,1),0), ...
    'comparison_clipped', save_dir);
end

