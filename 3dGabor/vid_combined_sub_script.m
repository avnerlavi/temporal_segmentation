out_dir = [root,'\results\3dGabor\combining_expiriments\linear_stitcing_and_gamma_075\'];
%maintainFitToWindow();
beta = 5;
gamma = 0.75;
gain = 1;
detail_enhanced_gamma = sign(detail_enhanced).*(abs(detail_enhanced).^gamma);
[vidCombined] = additiveCombination(detail_enhanced_gamma), beta, gain);
compareVids(vid_matrix,vidCombined);
compareVids(vid_matrix,minMaxNorm(vidCombined));
    writeVideoToFile(minMaxNorm(detail_enhanced), ...
        'movie_detail_enhanced_3d_minmax', out_dir);
    writeVideoToFile(abs(detail_enhanced), ...
        'movie_detail_enhanced_3d_abs', out_dir);
     writeVideoToFile(minMaxNorm(vidCombined), ...
        'movie_combined_norm', out_dir);
         writeVideoToFile(max(min(vidCombined,1),0), ...
        'movie_combined_clipped', out_dir);
    saveParams(out_dir, ...
        generatePyrFlag, inFileDir, resizeFactors, elevationHalfAngle, CCLFParams, ...
        minVideoValue, maxVideoValue,beta,gain);
