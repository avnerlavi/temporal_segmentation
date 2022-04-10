function [LF_p, LF_n] = Gabor3DActivation(Cp, Cn, Azimuth, Elevation, padding, percentileThreshold ...
    , FacilitationLength, alpha)
% threshold = activationThreshold * max(abs(Co(3:end-2,3:end-2,3:end-2)), [], 'all');
% Co(abs(Co) < threshold) = 0;
Cp_threshold = prctile(Cp(padding + 1:end-padding,padding + 1:end-padding,padding + 1:end-padding), percentileThreshold, 'all');%activationThreshold * max(Cp(3:end-2,3:end-2,3:end-2), [], 'all');
Cn_threshold = prctile(Cn(padding + 1:end-padding,padding + 1:end-padding,padding + 1:end-padding), percentileThreshold, 'all');%activationThreshold * max(Cn(3:end-2,3:end-2,3:end-2), [], 'all');
Cp(Cp < Cp_threshold) = 0;
Cn(Cn < Cn_threshold) = 0;

[LF_p ,NR_p] = LFsc3D(Cp, Azimuth, Elevation, FacilitationLength);
[LF_n ,NR_n] = LFsc3D(Cn, Azimuth, Elevation ,FacilitationLength);
% 
% LF_p_threshold = activationThreshold * max(abs(LF_p(3:end-2,3:end-2,3:end-2)), [], 'all');
% LF_n_threshold = activationThreshold * max(abs(LF_n(3:end-2,3:end-2,3:end-2)), [], 'all');
% LF_p(LF_p < LF_p_threshold) = 0;
% LF_n(LF_n < LF_n_threshold) = 0;

LF_p = max(0,LF_p-alpha*NR_p) .* (Cp > Cp_threshold);
LF_n = max(0,LF_n-alpha*NR_n) .* (Cn > Cn_threshold);
end

