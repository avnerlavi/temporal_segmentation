root = getenv('TemporalSegmentation');
addpath(genpath([root,'/utils']));
addpath(genpath([root,'/3dGabor']));
videos_to_load = {
    "F:\Matlab\docs\temporal_segmentation\results-02-01-2023-21_54\corpus_callosum_case_11_11_22_results\cropped\0016_0049_chunk_1",
    "F:\Matlab\docs\temporal_segmentation\results-02-01-2023-21_54\corpus_callosum_case_11_11_22_results\cropped\0110_0123",
    "F:\Matlab\docs\temporal_segmentation\results-02-01-2023-21_54\corpus_callosum_case_11_11_22_results\cropped\0212_0248_chunk_1",
    "F:\Matlab\docs\temporal_segmentation\results-02-01-2023-21_54\corpus_callosum_case_11_11_22_results\cropped\0435_0446",
    "F:\Matlab\docs\temporal_segmentation\results-02-01-2023-21_54\corpus_callosum_case_11_11_22_results\cropped\0515_0600_chunk_1",
    "F:\Matlab\docs\temporal_segmentation\results-02-01-2023-21_54\corpus_callosum_case_11_11_22_results\cropped\0708_0720",
    "F:\Matlab\docs\temporal_segmentation\results-22-04-2023-18_29\corpus_callosum_case_11_11_22_results\21_3\cropped\0212_0248_chunk_1",
    "F:\Matlab\docs\temporal_segmentation\results-22-04-2023-18_29\corpus_callosum_case_11_11_22_results\21_3\cropped\0313_0332_chunk_1",
    "F:\Matlab\docs\temporal_segmentation\results-22-04-2023-18_29\corpus_callosum_case_11_11_22_results\21_3\cropped\1209_1218",
    "F:\Matlab\docs\temporal_segmentation\results-22-04-2023-18_29\corpus_callosum_case_11_11_22_results\25_4\cropped\0059_0108",
    "F:\Matlab\docs\temporal_segmentation\results-22-04-2023-18_29\corpus_callosum_case_11_11_22_results\25_4\cropped\0108_0126_chunk_1",
    "F:\Matlab\docs\temporal_segmentation\results-22-04-2023-18_29\corpus_callosum_case_11_11_22_results\25_4\cropped\0146_0216_chunk_1",
    "F:\Matlab\docs\temporal_segmentation\results-22-04-2023-18_29\corpus_callosum_case_11_11_22_results\25_4\cropped\0216_0252_chunk_1",
    "F:\Matlab\docs\temporal_segmentation\results-22-04-2023-18_29\corpus_callosum_case_11_11_22_results\25_4\cropped\0631_0652_chunk_1"
    
    };

%%
for i = 1:length(videos_to_load)
    vid_dir = videos_to_load{i};
    response = readVideoFromFile(fullfile(vid_dir,"movie_detail_enhanced_3d_minmax.avi"),false);
    params = read_params(fullfile(vid_dir,"params.xls"));
    orig_vid = readVideoFromFile(params.in_file_dir,false);
    response = response*(params.maxVideoValue - params.minVideoValue) + params.minVideoValue;
    orig_vid = orig_vid(:,:,2:size(response,3)+1);
%     if(all(size(response)~=size(orig_vid)))
%         for j = 1:3
%           margin = max(size(response,j),size(orig_vid,j)) - min(size(response,j),size(orig_vid,j));
%           
%         end
%     end
if (i==1)
    [total_hist,edges] = response_histogram(orig_vid,abs(response),true);
else
    [hist,edges] = response_histogram(orig_vid,abs(response),true);
    total_hist = total_hist + hist;
end
end
%%
figure()
bar(edges(1:end-1),total_hist(1:end-1)/length(videos_to_load))
title('Response Strength Statistics')
xlabel('Original Video Intensity')
ylabel('Mean Response Strength')
