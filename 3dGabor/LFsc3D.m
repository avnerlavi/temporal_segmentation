function [out, vidNR] = LFsc3D(vid,Az,El,Fac)
c50 = 0.1;
vidNR = vid.^2./(vid.^2+c50);
g0 = Gaussian3D([Az,El],0,[0.05,0.05,Fac],[]); %LF without width
%g0 = Gaussian3D([Az,El],0,[0.05,0.05,1]*Fac,[1.5, 1.5, 1.5]*Fac); %with width
%g0_normed = g0/max(g0(:));
out = convn(vidNR,g0,'same');
end