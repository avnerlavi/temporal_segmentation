function [vidOut] = Std3DActivation(vidIn,varT,Az,El)
Gtime = gpuArray(Gaussian3D([Az, El], 0, varT, []));
vidOut = Gaussian3dStd(vidIn, Gtime);
end

