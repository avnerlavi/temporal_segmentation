function [Gab3d_func] = BuildGabor3D(azimuth, elevation, size, lambda)
% sigma1 = 0.5;
% sigma2 = sigma1 * 1.85;
% sigma3 = sigma1 * 3.9;
% sigmaT = 2.5;
% Gaus3d_1 = Gaussian3D([azimuth, elevation], 0, 0.5*[sigma1, sigma1, sigmaT], size);
% Gaus3d_2 = Gaussian3D([azimuth, elevation], 0, 0.5*[sigma2, sigma2, sigmaT], size);
% Gaus3d_3 = Gaussian3D([azimuth, elevation], 0, 0.5*[sigma3, sigma3, sigmaT], size);
% GausDiff = Gaus3d_1 - 2*Gaus3d_2 + Gaus3d_3;
% Gab3d = GausDiff / max(abs(GausDiff),[],'all');

% Shape = 2;
% sigma = 4/5;
% lambda = 2;
% w = 2*pi/lambda;
% Gaussian = Gaussian3D([Azimuth,Elevation],0,[sigma,sigma,2],Shape);
% ConeWave = ConeWave3D([Azimuth,Elevation],0,[lambda,lambda],Shape);
% Gab3d_func = Gaussian.*ConeWave;
% % Gab3d = Gab3d - mean(Gab3d,'all');
% Gab3d_func  = Gab3d_func / max(abs(Gab3d), [], 'all');
% 
Gab3d_func = gabor3_fwb([1, 0.8], [azimuth, elevation], lambda, 0, lambda, (size - 1) / 2);
Gab3d_func = Gab3d_func - mean(Gab3d_func,'all');
Gab3d_func = Gab3d_func / max(abs(Gab3d_func), [], 'all');
% implay(minMaxNorm(Gab3d_func));
% 
% compareVids(minMaxNorm(Gab3d), minMaxNorm(Gab3d_func));
end