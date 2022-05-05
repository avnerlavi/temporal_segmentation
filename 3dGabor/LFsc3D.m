function [out, vidNR] = LFsc3D(vid,Az,El,Fac)
sigmaNR = sqrt(0.1);
vidNR = NakaRushton(vid, sigmaNR, 0, 2);
g0 = Gaussian3D([Az,El],0,[0.01,0.01,Fac],[1.5, 1.5, 1.5]*Fac + mod(1.5*Fac + 1, 2)); %LF without width
% g0 = Gaussian3D([Az,El],0,[0.05,0.05,1]*Fac,[1.5, 1.5, 1.5]*Fac); %with width
% g0 = Gaussian3DRemote([Az,El],0,[0.05,0.05,1]*Fac,[1.5, 1.5, 1.5]*Fac,0.5*Fac); %without center
g0_normed = g0/max(g0(:));
additiveSignal = conv3FFT(vidNR,g0_normed);
% p = prctile(additiveSignal, 95, 'all');
% additiveSignal(additiveSignal < p) = 0;
% out = vidNR + additiveSignal;
out = additiveSignal;
end