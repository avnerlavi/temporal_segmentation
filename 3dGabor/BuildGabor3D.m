function [Gab3d] = BuildGabor3D(Azimuth,Elevation)
% sigma1 = 0.5;
% sigma2 = sigma1 * 1.85;
% sigma3 = sigma1 * 3.9;
% sigmaT = 2.5;
% Gaus3d_1 = Gaussian3D([Azimuth,Elevation],0,[sigma1, sigma1, sigmaT],5);
% Gaus3d_2 = Gaussian3D([Azimuth,Elevation],0,[sigma2, sigma2, sigmaT],5);
% Gaus3d_3 = Gaussian3D([Azimuth,Elevation],0,[sigma3, sigma3, sigmaT],5);
% GausDiff = Gaus3d_1 - 2*Gaus3d_2 + Gaus3d_3;
% Gab3d  = GausDiff / max(abs(GausDiff),[],'all');

Shape = 5;
sigma=8/5;
lambda=12/5;
w = 2*pi/lambda;
Gaussian = Gaussian3D([Azimuth,Elevation],0,[sigma,sigma,2],Shape);
ConeWave = ConeWave3D([Azimuth,Elevation],0,[lambda,lambda],Shape);
Gab3d  = Gaussian.*ConeWave;
Gab3d  = Gab3d./sqrt(sum((Gab3d).^2,'all'));

end

