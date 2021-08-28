function [out, vidNR] = LFsc3D(vid,Az,El,Fac)
sigmaNR = sqrt(0.1);
vidNR = NakaRushton(vid, sigmaNR, 0, 2);
%g0 = Gaussian3D([Az,El],0,[0.01,0.01,Fac],[]); %LF without width
g0 = Gaussian3D([Az,El],0,[1,1,0.05]*(20/Fac),[1.5, 1.5, 1.5]*Fac); %with width
g0_normed = g0/max(g0(:));
out = convn(vidNR,g0_normed,'same');
end