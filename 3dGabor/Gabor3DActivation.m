function [LF_p, LF_n] = Gabor3DActivation(Cp, Cn, Azimuth, Elevation, padding, ...
    CpSupport, CnSupport, activationThreshold, FacilitationLength, alpha, snapshotDir, snapshotFrames)

threshold_p = activationThreshold(1);
threshold_n = activationThreshold(2);

CpOriginalSupport = Cp > threshold_p;
CnOriginalSupport = Cn > threshold_n;

Cp(~CpOriginalSupport) = 0;
Cn(~CnOriginalSupport) = 0;

LF_p_mask = LFsc3D_binarized(CpSupport, Azimuth, Elevation, FacilitationLength, 'erode');
LF_n_mask = LFsc3D_binarized(CnSupport, Azimuth, Elevation ,FacilitationLength, 'erode');

if (strcmp(snapshotDir, '') == false)
    saveSnapshots(gather(Cp(padding + 1:end-padding, padding + 1:end-padding, :)), snapshotDir, ['Cp_after_threshold', '_az_', num2str(Azimuth), '_el_', num2str(Elevation)], snapshotFrames);
    saveSnapshots(gather(Cn(padding + 1:end-padding, padding + 1:end-padding, :)), snapshotDir, ['Cn_after_threshold', '_az_', num2str(Azimuth), '_el_', num2str(Elevation)], snapshotFrames);
end

[LF_p ,NR_p] = LFsc3D(Cp, Azimuth, Elevation, FacilitationLength);
[LF_n ,NR_n] = LFsc3D(Cn, Azimuth, Elevation ,FacilitationLength);
% 
% LF_p_threshold = activationThreshold * max(abs(LF_p(3:end-2,3:end-2,3:end-2)), [], 'all');
% LF_n_threshold = activationThreshold * max(abs(LF_n(3:end-2,3:end-2,3:end-2)), [], 'all');
% LF_p(LF_p < LF_p_threshold) = 0;
% LF_n(LF_n < LF_n_threshold) = 0;


LF_p = LF_p .* LF_p_mask + NR_p .* (1 - LF_p_mask);
LF_n = LF_n .* LF_n_mask + NR_n .* (1 - LF_n_mask);

LF_p(abs(LF_p) < threshold_p) = NR_p(abs(LF_p) < threshold_p);
LF_n(abs(LF_n) < threshold_n) = NR_n(abs(LF_n) < threshold_n);

LF_p=0.5*max(0,LF_p-alpha*NR_p);
LF_n=0.5*max(0,LF_n-alpha*NR_n);

if (strcmp(snapshotDir, '') == false)
    saveSnapshots(gather(LF_p(padding + 1:end-padding, padding + 1:end-padding, :)), snapshotDir, ['LF_p', '_az_', num2str(Azimuth), '_el_', num2str(Elevation)], snapshotFrames);
    saveSnapshots(gather(LF_n(padding + 1:end-padding, padding + 1:end-padding, :)), snapshotDir, ['LF_n', '_az_', num2str(Azimuth), '_el_', num2str(Elevation)], snapshotFrames);
    
    saveSnapshots(gather(NR_p(padding + 1:end-padding, padding + 1:end-padding, :)), snapshotDir, ['NR_p', '_az_', num2str(Azimuth), '_el_', num2str(Elevation)], snapshotFrames);
    saveSnapshots(gather(NR_n(padding + 1:end-padding, padding + 1:end-padding, :)), snapshotDir, ['NR_n', '_az_', num2str(Azimuth), '_el_', num2str(Elevation)], snapshotFrames);
end

end

