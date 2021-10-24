function [LF_n, LF_p] = Gabor3DActivation(vidS, Azimuth, Elevation, activationThreshold, FacilitationLength, alpha)
L = BuildGabor3D(Azimuth, Elevation);
Co = convn(vidS, L, 'same');
%threshold = activationThreshold * max(abs(Co(8:end-7,8:end-7,8:end-7)), [], 'all');
%Co(abs(Co) < threshold) = 0;
Cp = max( Co,0);
Cn = max(-Co,0);

%Cp(Cp < threshold_p) = 0;
%Cn(Cn < threshold_n) = 0;

[LF_n ,NR_n] = LFsc3D(Cn, Azimuth, Elevation ,FacilitationLength);
[LF_p ,NR_p] = LFsc3D(Cp, Azimuth, Elevation, FacilitationLength);

threshold_p = activationThreshold * max(LF_p(8:end-7,8:end-7,8:end-7), [], 'all');
threshold_n = activationThreshold * max(LF_n(8:end-7,8:end-7,8:end-7), [], 'all');
LF_n(abs(LF_n) < threshold_n) = NR_n(abs(LF_n) < threshold_n);
LF_p(abs(LF_p) < threshold_p) = NR_p(abs(LF_p) < threshold_p);

LF_n=0.5*max(0,LF_n-alpha*NR_n);
LF_p=0.5*max(0,LF_p-alpha*NR_p);
end

