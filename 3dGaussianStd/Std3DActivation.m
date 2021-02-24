function [vidOut] = Std3DActivation(vidIn,Az,El)
sigmaT = [0.1,0.1,9];
Gtime = Gaussian3D([Az,El],0,sigmaT,[]);
[vidOut] = stdfilt(vidIn,ones(1,1,9));
%vidOut = vidIn - vidOut;
end

