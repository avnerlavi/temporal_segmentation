function [vidOut] = Std3DActivation(vidIn,sigmaT,Az,El)
Gtime = gpuArray(Gaussian3D([Az, El], 0, sigmaT, []));
vidOut = Gaussian3dStd(vidIn, Gtime);
end

