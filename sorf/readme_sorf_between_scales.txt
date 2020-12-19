gauss_local = Gaussian3D([0, 0], 0, [1,1,1], []);
c_local_curr = ones(size(vidIn));
c_local_prev = ones(size(vidIn));

for each scale, from largest (original size) to smallest:
...
    vidScaled = imresize3(vidOriTot_p.^m2 - vidOriTot_n.^m2,size(vidIn));
    vidScaled = vidScaled/(k^m2);
    c_local_prev = c_local_curr;
    c_local_curr = computeContrast(vidScaled, gauss_local);
    gf = (c_local_curr + beta)./(c_local_prev + beta);
    vidScaled = vidScaled .* gf;
    vidScaleTot = vidScaleTot + vidScaled;
...