function [vidOut] = Std3DActivation(vidIn,Az,El)
sigmaT = [0.1,0.1,7];
Gtime = Gaussian3D([Az,El],0,sigmaT,[]);
[vidOut] = Gaussian3dStd(vidIn,Gtime);
%vidOut = vidIn - vidOut;
end

