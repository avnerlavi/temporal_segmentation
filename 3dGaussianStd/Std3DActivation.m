function [vidOut] = Std3DActivation(vidIn,varT,Az,El)
Gtime1 = Gaussian3D([Az, El], 0, 100 * varT, []);
Gsize = size(Gtime1);
Gtime = gpuArray(safeResize(Gtime1, floor(0.1 * Gsize)));
Gtime = Gtime./sum(abs(Gtime),'all');

% Gtime = gpuArray(Gaussian3D([Az, El], 0, varT, []));
vidOut = Gaussian3dStd(vidIn, Gtime);
end

