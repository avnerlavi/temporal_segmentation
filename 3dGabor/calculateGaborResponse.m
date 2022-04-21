function [Cp, Cn] = calculateGaborResponse(vidIn, azimuth, elevation)
L = gpuArray(BuildGabor3D(azimuth, elevation));
Co = conv3FFT(vidIn, L);
Cp = max(Co,0);
Cn = max(-Co,0);
end

