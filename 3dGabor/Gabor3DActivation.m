function [LF_n, LF_p,threshold_data] = Gabor3DActivation(Cp,Cn, Azimuth, Elevation, ...
    CpSupport, CnSupport, activationThreshold, FacilitationLength, alpha)

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

threshold_p = activationThreshold * max(LF_p(8:end-7,8:end-7,8:end-7), [], 'all');
threshold_n = activationThreshold * max(LF_n(8:end-7,8:end-7,8:end-7), [], 'all');

threshold_data = [Azimuth,Elevation];
threshold_data(end,4) = mean(double(abs(LF_p) > threshold_p),'all');
threshold_data(end,3) = mean(double(abs(LF_n) > threshold_n),'all');

LF_p(abs(LF_p) < threshold_p) = NR_p(abs(LF_p) < threshold_p);
LF_n(abs(LF_n) < threshold_n) = NR_n(abs(LF_n) < threshold_n);

LF_p=0.5*max(0,LF_p-alpha*NR_p);
LF_n=0.5*max(0,LF_n-alpha*NR_n);


end

