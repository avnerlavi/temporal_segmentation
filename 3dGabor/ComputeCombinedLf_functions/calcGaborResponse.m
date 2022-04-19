function [Cp,Cn] = calcGaborResponse(vid_in,azimuth, elevation)
L = BuildGabor3D(azimuth, elevation);
Co = convn(vid_in, L,'same');
Cp = max(Co,0);
Cn = max(-Co,0);
end

