function [LF_n, LF_p,threshold_data] = Gabor3DActivation(Cp,Cn, Azimuth, Elevation, activationThreshold, FacilitationLength, alpha)

[LF_n ,NR_n] = LFsc3D(Cn, Azimuth, Elevation ,FacilitationLength);
[LF_p ,NR_p] = LFsc3D(Cp, Azimuth, Elevation, FacilitationLength);

threshold_p = activationThreshold * max(LF_p(8:end-7,8:end-7,8:end-7), [], 'all');
threshold_n = activationThreshold * max(LF_n(8:end-7,8:end-7,8:end-7), [], 'all');

threshold_data = [Azimuth,Elevation];
threshold_data(end,3) = mean(double(abs(LF_n) > threshold_n),'all');
threshold_data(end,4) = mean(double(abs(LF_p) > threshold_p),'all');
LF_n(abs(LF_n) < threshold_n) = NR_n(abs(LF_n) < threshold_n);
LF_p(abs(LF_p) < threshold_p) = NR_p(abs(LF_p) < threshold_p);

LF_n=0.5*max(0,LF_n-alpha*NR_n);
LF_p=0.5*max(0,LF_p-alpha*NR_p);

end

