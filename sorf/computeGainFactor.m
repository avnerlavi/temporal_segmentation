function gf = computeGainFactor(vidIn, beta)
gauss_local = Gaussian3D([0, 0], 0, [1,1,1], []);
gauss_local = gauss_local / max(gauss_local(:));
c_local = computeContrast(vidIn, gauss_local);

gauss_remote = Gaussian3D([0, 0], 0, [3,3,3], []);
gauss_remote = gauss_remote / max(gauss_remote(:));
c_remote = computeContrast(c_local, gauss_remote);

gf = (c_local + beta)./(c_remote + beta);
end

