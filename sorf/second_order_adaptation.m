vid_matrix = readVideoFromFile('C:\Users\Avner\Documents\Elec. Eng. II\Project\temporal_segmentation\results\3dGabor\movie_detail_enhanced_3d_m1_1.avi', false);
beta = 0.4;
gf = computeGainFactor(vid_matrix, beta);
%gf_test = (vid_matrix + beta)./(c_local + beta);

out = gf .* vid_matrix;