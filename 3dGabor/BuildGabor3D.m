function [Gab3d] = BuildGabor3D(Azimuth,Elevation)
% sigma1 = 0.5;
% sigma2 = sigma1 * 1.85;
% sigma3 = sigma1 * 3.9;
% sigmaT = 2.5;
% Gaus3d_1 = Gaussian3D([Azimuth,Elevation],0,[sigma1, sigma1, sigmaT],5);
% Gaus3d_2 = Gaussian3D([Azimuth,Elevation],0,[sigma2, sigma2, sigmaT],5);
% Gaus3d_3 = Gaussian3D([Azimuth,Elevation],0,[sigma3, sigma3, sigmaT],5);
% GausDiff = Gaus3d_1 - 2*Gaus3d_2 + Gaus3d_3;
% [distance2D] = PlanarDist([Azimuth,Elevation],5);
% Gab3d = GausDiff./(distance2D +1); 
% Gab3d = Gab3d - mean(Gab3d,'all');
% Gab3d = Gab3d / max(abs(Gab3d),[],'all');

Shape = 5;
sigma=8/5;
lambda=12/5;
w = 2*pi/lambda;
Gaussian = Gaussian3D([Azimuth,Elevation],0,[sigma,sigma,2.5],Shape);
ConeWave = ConeWave3D([Azimuth,Elevation],0,[lambda,lambda],Shape);
Gab3d = Gaussian.*ConeWave;
[distance2D] = PlanarDist([Azimuth,Elevation],5);
Gab3d = Gab3d./(distance2D +1); 
Gab3d = Gab3d - mean(Gab3d,'all');
Gab3d = Gab3d / max(abs(Gab3d),[],'all');

end

