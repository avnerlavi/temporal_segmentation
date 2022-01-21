function [mask_out] = LFsc3D_binarized(mask_in,Az,El,Fac)
g0 = Gaussian3D([Az,El],0,[0.01,0.01,Fac],[]); %TODO - change to <0.05 to avoid aliasing
g0_normed = g0/max(g0(:));
SE = strel(g0_normed>0.01); % TODO - calculate threshold according to support length
mask_out = imclose(mask_in,SE);
end