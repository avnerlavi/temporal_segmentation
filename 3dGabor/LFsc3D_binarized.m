function [mask_out] = LFsc3D_binarized(mask_in, Az, El, Fac, morphologicalFunction)
g0 = Gaussian3D([Az,El],0,[0.05,0.05,Fac],[]); %TODO - change to <0.05 to avoid aliasing
SE = strel(g0 > exp(-4.5)*max(g0(:))); % 3 stds
% mask_in_binarized = mask_in > supportThreshold;
mask_in_binarized = mask_in;
if strcmp(morphologicalFunction, 'dilate')
    mask_out = imdilate(mask_in_binarized, SE);
elseif strcmp(morphologicalFunction, 'erode')
    mask_out = imerode(mask_in_binarized, SE);
elseif strcmp(morphologicalFunction, 'close')
    mask_out = imclose(mask_in_binarized, SE);
else
    error('invalid morphological function');
end

end