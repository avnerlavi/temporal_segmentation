function [out, vidNR] = LFsc3D(vid,Az,El,Fac)
c50 = 0.1;
vidNR = vid.^2./(vid.^2+c50);
g0 = 1.75*Gaussian3D([Az,El],0,[0.1,0.1,Fac],[]); %coefficient was empirically set
out = convn(vidNR,g0,'same');
end