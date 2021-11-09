function [LF_n, LF_p] = Gabor3DActivation(Cp,Cn, Azimuth, Elevation, activationThreshold, FacilitationLength, alpha)

%Cp(Cp < threshold_p) = 0;
%Cn(Cn < threshold_n) = 0;

[LF_n ,NR_n] = LFsc3D(Cn, Azimuth, Elevation ,FacilitationLength);
[LF_p ,NR_p] = LFsc3D(Cp, Azimuth, Elevation, FacilitationLength);

threshold_p = activationThreshold * max(LF_p(8:end-7,8:end-7,8:end-7), [], 'all');
threshold_n = activationThreshold * max(LF_n(8:end-7,8:end-7,8:end-7), [], 'all');

%threshold_p = prctile(LF_p(8:end-7,8:end-7,8:end-7),100*(activationThreshold),'all');
%threshold_n = prctile(LF_n(8:end-7,8:end-7,8:end-7),100*(activationThreshold),'all');

%disp(mean(double(abs(LF_n) < threshold_n),'all'))%debug for data proccesing
LF_n(abs(LF_n) < threshold_n) = NR_n(abs(LF_n) < threshold_n);
LF_p(abs(LF_p) < threshold_p) = NR_p(abs(LF_p) < threshold_p);

LF_n=0.5*max(0,LF_n-alpha*NR_n);
LF_p=0.5*max(0,LF_p-alpha*NR_p);

end

