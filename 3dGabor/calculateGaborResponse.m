function [Cp, Cn] = calculateGaborResponse(vidIn, azimuth, elevation, gaborSize, gaborLambda, paddingSize)
L = gpuArray(BuildGabor3D(azimuth, elevation, gaborSize, gaborLambda));
Co = conv3FFT(vidIn, L);
Cp = max(Co,0);
Cn = max(-Co,0);
end

