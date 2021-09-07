function [LF_n, LF_p] = Gabor3DActivation(vidS, Azimuth, Elevation, activationThreshold ...
    , FacilitationLength, alpha)
L = BuildGabor3D(Azimuth, Elevation);
Co = convn(vidS, L, 'same');
threshold = activationThreshold * max(abs(Co(3:end-2,3:end-2,3:end-2)), [], 'all');
Co(abs(Co) < threshold) = 0;
Cp = max(Co,0);
Cn = max(-Co,0);

[LF_n ,NR_n] = LFsc3D(Cn, Azimuth, Elevation ,FacilitationLength);
[LF_p ,NR_p] = LFsc3D(Cp, Azimuth, Elevation, FacilitationLength);

% LF_n_threshold = activationThreshold * max(abs(LF_n(3:end-2,3:end-2,3:end-2)), [], 'all');
% LF_p_threshold = activationThreshold * max(abs(LF_p(3:end-2,3:end-2,3:end-2)), [], 'all');
% LF_n(LF_n < LF_n_threshold) = 0;
% LF_p(LF_p < LF_p_threshold) = 0;

LF_n = max(0,LF_n-alpha*NR_n);
LF_p = max(0,LF_p-alpha*NR_p);
end

