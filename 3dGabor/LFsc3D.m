function [out, vidNR] = LFsc3D(vid,Az,El,Fac)
sigmaNR = sqrt(0.1);
vidNR = NakaRushton(vid, sigmaNR, 0, 2);
g0 = Gaussian3D([Az,El],0,[0.05,0.05,Fac],[]); %LF without width
% g0 = Gaussian3D([Az,El],0,[0.05,0.05,1]*Fac,[1.5, 1.5, 1.5]*Fac); %with width
% g0 = Gaussian3DRemote([Az,El],0,[0.05,0.05,1]*Fac,[1.5, 1.5, 1.5]*Fac,0.5*Fac); %without center
%g0_normed = g0/max(g0(:));
additiveSignal = conv3FFT(vidNR, g0);
out = additiveSignal;
end