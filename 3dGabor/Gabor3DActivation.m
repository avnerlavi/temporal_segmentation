function [LF_n, LF_p] = Gabor3DActivation(vidS, Azimuth, Elevation, FacilitationLength, alpha)
L = BuildGabor3D(Azimuth, Elevation);
Co = convn(vidS, L, 'same');
threshold = 0.3 * max(abs(Co(3:end-2,3:end-2,3:end-2)), [], 'all');
Co(abs(Co) < threshold) = 0;
Cp = max(Co,0);
Cn = max(-Co,0);

[LF_n ,NR_n] = LFsc3D(Cn, Azimuth, Elevation ,FacilitationLength);
[LF_p ,NR_p] = LFsc3D(Cp, Azimuth, Elevation, FacilitationLength);
LF_n=0.5*max(0,LF_n-alpha*NR_n);
LF_p=0.5*max(0,LF_p-alpha*NR_p);
end

