gauss_local = Gaussian3D([0, 0], 0, [1,1,1], []);
gauss_remote = Gaussian3D([0, 0], 0, [3,3,3], []);


for each scale:
...
    vidScaled = imresize3(vidOriTot_p.^m2 - vidOriTot_n.^m2,size(vidIn));
    vidScaled = vidScaled/(k^m2);
    c_local = computeContrast(vidScaled, gauss_local);
    c_remote = computeContrast(c_local, gauss_remote);
    gf = (c_local + beta)./(c_remote + beta);
    vidScaled = vidScaled .* gf;
    vidScaleTot = vidScaleTot + vidScaled;
...