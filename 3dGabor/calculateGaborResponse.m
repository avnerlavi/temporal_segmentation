function [Cp, Cn] = calculateGaborResponse(vidIn, azimuth, elevation, size, lambda)
L = gpuArray(BuildGabor3D(azimuth, elevation, size, lambda));
Co = conv3FFT(vidIn, L);
Cp = max(Co,0);
Cn = max(-Co,0);
end

