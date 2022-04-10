function [vidScaleTot] = computeCombinedStd_IN3D(vidIn, nAzimuths, nElevations ...
    , elHalfAngle, nScales, sigmaSpatial ,sigmaTemporal ,m1, m2, normQ, snapshotDir)
vidIn = PadVideoReplicate(vidIn,2*nScales);
vidScaleTot = zeros(size(vidIn));
Elevations = linspace(0,elHalfAngle,nElevations);
Elevations = Elevations(2:end);
Azimuths = linspace(0,360,nAzimuths+1);
Azimuths = Azimuths(1:end-1);
Gshort = Gaussian3D([0,0],0,sigmaSpatial,[]);

w = waitbar(0, 'starting per-resolution STD computation');
progressCounter = 0;
totalOrientationNumber = length(Azimuths) * length(Elevations) + 1;
totalIterationNumber = 2 * nScales * totalOrientationNumber;

for k = 1:nScales
    vidS = safeResize(vidIn,1/k * size(vidIn));
    spatialStd = gpuArray(Gaussian3dStd(vidS,Gshort));
    vidOriSTDDiffs = zeros([size(vidS), totalOrientationNumber]);

    %0 elev handling
    temporalStd = Std3DActivation(spatialStd, sigmaTemporal, 0, 0);
    vidOriSTDDiffs(:,:,:,end) = gather(minMaxNorm(spatialStd) - minMaxNorm(temporalStd));
    
    if k == 1
        saveSnapshots(gather(spatialStd), snapshotDir, 'spatial_std');
        saveSnapshots(gather(temporalStd), snapshotDir, 'temporal_std');
    end

    for i = 1:length(Azimuths)
        for j = 1:length(Elevations)
            currOrientationIndex = (i-1) * length(Elevations) + j;
            temporalStd = Std3DActivation(spatialStd, sigmaTemporal, Azimuths(i), Elevations(j));
            vidOriSTDDiffs(:,:,:,currOrientationIndex) = gather(spatialStd - temporalStd);
            
            progressCounter = progressCounter + 1;
            waitbar(progressCounter / totalIterationNumber, w);   
        end
    end

    stdDiffTotalPowerSum = sum(abs(vidOriSTDDiffs).^normQ, 4);

    %0 elev handling
    stdDiffNormFactor = 1 + (stdDiffTotalPowerSum - abs(vidOriSTDDiffs(:,:,:, end)).^normQ).^(1/normQ);
    vidOriSTDDiffs(:,:,:,end) = ...
        vidOriSTDDiffs(:,:,:,end) ./ stdDiffNormFactor;

    for i = 1:length(Azimuths)
        for j = 1:length(Elevations)
            currOrientationIndex = (i-1) * length(Elevations) + j;
            stdDiffNormFactor = 1 + (stdDiffTotalPowerSum - abs(vidOriSTDDiffs(:,:,:, currOrientationIndex)).^normQ).^(1/normQ);
            vidOriSTDDiffs(:,:,:,currOrientationIndex) = ...
                vidOriSTDDiffs(:,:,:,currOrientationIndex) ./ stdDiffNormFactor;
            
            progressCounter = progressCounter + 1;
            waitbar(progressCounter / totalIterationNumber, w);   
        end
    end
    
    if k == 1 || k == 2
        saveSnapshots(vidOriSTDDiffs(:, :, :, end), snapshotDir, ['extracted_feature_k_', num2str(k)], [60/k, 120/k]);
    end
    
    vidStdDiff = sum(vidOriSTDDiffs.^m1, 4).^(1/m1);
    reset(gpuDevice(1));
    vidScaled = (imresize3(vidStdDiff,size(vidIn))).^m2;
    vidScaled = vidScaled/(k^m2);
    vidScaleTot = vidScaleTot + vidScaled;
    
    waitbar(progressCounter / totalIterationNumber, w, ['finished scale ', num2str(k)]);
end
vidScaleTot = sign(vidScaleTot).*(abs(vidScaleTot).^(1/m2));
vidScaleTot = stripVideo(vidScaleTot, 2*nScales);

close(w);
end