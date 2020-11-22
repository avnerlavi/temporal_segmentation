sigma1 = 0.5;
sigma2 = sigma1*1.85;
sigma3 = sigma1*3.9;
sigmaT = 2.5;
theta = 90;
Gaus3d_1 = Gaussian3D([theta,90],0,[sigma1, sigma1 ,sigmaT],5);
Gaus3d_2 = Gaussian3D([theta,90],0,[sigma2, sigma2, sigmaT],5);
Gaus3d_3 = Gaussian3D([theta,90],0,[sigma3, sigma3, sigmaT],5);
GausDiff = Gaus3d_1 - 2*Gaus3d_2 + Gaus3d_3;
Gab3d  = GausDiff/max(abs(GausDiff),[],'all');
implay((Gab3d+1)/2)
Gab2d = buildGabor(deg2rad(theta));
Gab2d = Gab2d/max(Gab2d,[],'all');
figure()
subplot(2,2,1)
imshow(Gab2d,[])
subplot(2,2,2)
imshow(Gab3d(ceil(end/2)-2:ceil(end/2)+2,ceil(end/2)-2:ceil(end/2)+2,ceil(end/2)),[])
subplot(2,2,3.5)
imshow(Gab3d(ceil(end/2)-2:ceil(end/2)+2,ceil(end/2)-2:ceil(end/2)+2,ceil(end/2))-Gab2d,[])

figure()
 plot(1:size(Gaus3d_1,1),Gaus3d_1(ceil(end/2),:,ceil(end/2)),...
     1:size(Gaus3d_2,1),Gaus3d_2(ceil(end/2),:,ceil(end/2)),...
     1:size(Gaus3d_3,1),Gaus3d_3(ceil(end/2),:,ceil(end/2)),...
     1:size(GausDiff,1),GausDiff(ceil(end/2),:,ceil(end/2)))
 legend('Gauss3d_1','Gauss3d_2','Gauss3d_3','Diff')
 