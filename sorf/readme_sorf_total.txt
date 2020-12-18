c_local and vidScaled (after normalization) were saved for each resolution

after running through all resolutions, in detail_enhancement:

c_local_tot = ones(size(vid_matrix));
for k=numOfScales:-1:1
c_local_tot = c_local_tot + cLocalScalesPyr{k};
end

gauss_remote = Gaussian3D([0, 0], 0, [3,3,3], []);
gauss_remote = gauss_remote / max(gauss_remote(:));
c_remote = computeContrast(c_local_tot, gauss_remote);
gf_tot = (c_local_tot + beta)./(c_remote + beta);

vid_scaled_tot = ones(size(vid_matrix));
for k=numOfScales:-1:1
vidScaled = vidScalesPyr{k};
vid_scaled_tot = vid_scaled_tot + vidScaled;
end

vidScaleTot = sign(vid_scaled_tot).*abs(vid_scaled_tot).^(1/2);  %this reuses m2
vidScaleTot = vidScaleTot / max(abs(vidScaleTot(:)));

detail_enhanced = vidScaleTot(2*numOfScales+1:end-2*numOfScales, 2*numOfScales+1:end-2*numOfScales, 2*numOfScales+1:end-2*numOfScales);
detail_enhanced = detail_enhanced/max(abs(detail_enhanced(:)));