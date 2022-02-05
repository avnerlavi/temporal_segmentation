function [LF_p, LF_n] = Gabor3DActivation(Cp, Cn, Azimuth, Elevation, ...
    CpSupport, CnSupport, activationThreshold, supportThreshold, FacilitationLength, alpha)

CpOriginalSupport = Cp > supportThreshold;
CnOriginalSupport = Cn > supportThreshold;

threshold_p = activationThreshold * max(Cp(8:end-7,8:end-7,8:end-7), [], 'all');
threshold_n = activationThreshold * max(Cn(8:end-7,8:end-7,8:end-7), [], 'all');

mask_p = abs(Cp) > threshold_p;
mask_n = abs(Cn) > threshold_n;
Cp(~mask_p) = 0;
Cn(~mask_n) = 0;

LF_p_mask = LFsc3D_binarized(CpSupport, Azimuth, Elevation, FacilitationLength, 'erode');
LF_n_mask = LFsc3D_binarized(CnSupport, Azimuth, Elevation ,FacilitationLength, 'erode');

[LF_p ,NR_p] = LFsc3D(Cp, Azimuth, Elevation, FacilitationLength);
[LF_n ,NR_n] = LFsc3D(Cn, Azimuth, Elevation ,FacilitationLength);
% 
% LF_p_threshold = activationThreshold * max(abs(LF_p(3:end-2,3:end-2,3:end-2)), [], 'all');
% LF_n_threshold = activationThreshold * max(abs(LF_n(3:end-2,3:end-2,3:end-2)), [], 'all');
% LF_p(LF_p < LF_p_threshold) = 0;
% LF_n(LF_n < LF_n_threshold) = 0;

LF_p_mask = (LF_p_mask - CpOriginalSupport) > 0;
LF_n_mask = (LF_n_mask - CnOriginalSupport) > 0;

LF_p = LF_p .* LF_p_mask + NR_p .* (1 - LF_p_mask);
LF_n = LF_n .* LF_n_mask + NR_n .* (1 - LF_n_mask);

% LF_p(abs(LF_p) < threshold_p) = NR_p(abs(LF_p) < threshold_p);
% LF_n(abs(LF_n) < threshold_n) = NR_n(abs(LF_n) < threshold_n);

LF_p=0.5*max(0,LF_p-alpha*NR_p);
LF_n=0.5*max(0,LF_n-alpha*NR_n);

end

