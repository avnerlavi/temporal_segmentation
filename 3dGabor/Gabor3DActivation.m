function [LF_p, LF_n] = Gabor3DActivation(cp, cn, azimuth, elevation, padding, percentileThreshold ...
    , FacilitationLength, alpha, snapshotDir, snapshotFrames, totalActivationThreshold)
% threshold = activationThreshold * max(abs(Co(3:end-2,3:end-2,3:end-2)), [], 'all');
% Co(abs(Co) < threshold) = 0;

% Cp_threshold = prctile(Cp(padding + 1:end-padding,padding + 1:end-padding,padding + 1:end-padding), percentileThreshold, 'all');%activationThreshold * max(Cp(3:end-2,3:end-2,3:end-2), [], 'all');
% Cn_threshold = prctile(Cn(padding + 1:end-padding,padding + 1:end-padding,padding + 1:end-padding), percentileThreshold, 'all');%activationThreshold * max(Cn(3:end-2,3:end-2,3:end-2), [], 'all');
% Cp(Cp < Cp_threshold) = 0;
% Cn(Cn < Cn_threshold) = 0;

sigmaNR = sqrt(0.1);
threshold_p = NakaRushton(totalActivationThreshold(1), sigmaNR, 0, 2);
threshold_n = NakaRushton(totalActivationThreshold(2), sigmaNR, 0, 2);

% Cp_sig = my_sig(Cp - Cp_threshold, 10);
% Cn_sig = my_sig(Cn - Cn_threshold, 10);

% if (strcmp(snapshotDir, '') == false)
%     saveSnapshots(gather(Cp(padding + 1:end-padding, padding + 1:end-padding, :)), snapshotDir, ['Cp_after_threshold', '_az_', num2str(Azimuth), '_el_', num2str(Elevation)], snapshotFrames);
%     saveSnapshots(gather(Cn(padding + 1:end-padding, padding + 1:end-padding, :)), snapshotDir, ['Cn_after_threshold', '_az_', num2str(Azimuth), '_el_', num2str(Elevation)], snapshotFrames);
% end

[LF_p ,NR_p] = LFsc3D(cp, azimuth, elevation, FacilitationLength);
[LF_n ,NR_n] = LFsc3D(cn, azimuth, elevation ,FacilitationLength);

% LF_p_threshold = activationThreshold * max(abs(LF_p(3:end-2,3:end-2,3:end-2)), [], 'all');
% LF_n_threshold = activationThreshold * max(abs(LF_n(3:end-2,3:end-2,3:end-2)), [], 'all');
% LF_p(LF_p < LF_p_threshold) = 0;
% LF_n(LF_n < LF_n_threshold) = 0;

LF_n(abs(LF_n) < threshold_n) = NR_n(abs(LF_n) < threshold_n);
LF_p(abs(LF_p) < threshold_p) = NR_p(abs(LF_p) < threshold_p);

% LF_p = max(0,LF_p-alpha*NR_p) .* Cp_sig;
% LF_n = max(0,LF_n-alpha*NR_n) .* Cn_sig;
% LF_p = max(0,LF_p-alpha*NR_p) .* (Cp > Cp_threshold);
% LF_n = max(0,LF_n-alpha*NR_n) .* (Cn > Cn_threshold);

saveSnapshots(gather(LF_p(padding + 1:end-padding, padding + 1:end-padding, :)), snapshotDir, ['LF_p', '_az_', num2str(azimuth), '_el_', num2str(elevation)], snapshotFrames);
saveSnapshots(gather(LF_n(padding + 1:end-padding, padding + 1:end-padding, :)), snapshotDir, ['LF_n', '_az_', num2str(azimuth), '_el_', num2str(elevation)], snapshotFrames);    
saveSnapshots(gather(NR_p(padding + 1:end-padding, padding + 1:end-padding, :)), snapshotDir, ['NR_p', '_az_', num2str(azimuth), '_el_', num2str(elevation)], snapshotFrames);
saveSnapshots(gather(NR_n(padding + 1:end-padding, padding + 1:end-padding, :)), snapshotDir, ['NR_n', '_az_', num2str(azimuth), '_el_', num2str(elevation)], snapshotFrames);

end

