function [LF_n, LF_p,threshold_data] = Gabor3DActivation(Cp, Cn, Azimuth, Elevation, ...
    CpSupport, CnSupport, activationThreshold, FacilitationLength, alpha)

threshold_p = activationThreshold(1);
threshold_n = activationThreshold(2);

CpOriginalSupport = Cp > threshold_p;
CnOriginalSupport = Cn > threshold_n;

Cp(~CpOriginalSupport) = 0;
Cn(~CnOriginalSupport) = 0;

LF_p_mask = LFsc3D_binarized(CpSupport, Azimuth, Elevation, FacilitationLength, 'erode');
LF_n_mask = LFsc3D_binarized(CnSupport, Azimuth, Elevation ,FacilitationLength, 'erode');

[LF_p ,NR_p] = LFsc3D(Cp, Azimuth, Elevation, FacilitationLength);
[LF_n ,NR_n] = LFsc3D(Cn, Azimuth, Elevation ,FacilitationLength);

LF_p_mask = (LF_p_mask - CpOriginalSupport) > 0;
LF_n_mask = (LF_n_mask - CnOriginalSupport) > 0;

LF_p = LF_p .* LF_p_mask + NR_p .* (1 - LF_p_mask);
LF_n = LF_n .* LF_n_mask + NR_n .* (1 - LF_n_mask);

% threshold_p = activationThreshold * max(LF_p(8:end-7,8:end-7,8:end-7), [], 'all');
% threshold_n = activationThreshold * max(LF_n(8:end-7,8:end-7,8:end-7), [], 'all');

LF_p_orig = LF_p;
LF_n_orig = LF_n;

LF_p(abs(LF_p) < threshold_p) = NR_p(abs(LF_p) < threshold_p);
LF_n(abs(LF_n) < threshold_n) = NR_n(abs(LF_n) < threshold_n);

threshold_data = [Azimuth,Elevation];
threshold_data(end,4) = mean(double(abs(LF_p) > threshold_p),'all');
threshold_data(end,3) = mean(double(abs(LF_n) > threshold_n),'all');

% LF_p(abs(LF_p) < threshold_p) = NR_p(abs(LF_p) < threshold_p);
% LF_n(abs(LF_n) < threshold_n) = NR_n(abs(LF_n) < threshold_n);

LF_p=0.5*max(0,LF_p-alpha*NR_p);
LF_n=0.5*max(0,LF_n-alpha*NR_n);


end

