function [aggregatedTotalResponse] = computeCombinedStd_IN3D(vidIn, nAzimuths, nElevations ...
    , elHalfAngle, nScales, sigmaSpatial ,sigmaTemporal ,m1, m2, normQ, snapshotDir)
%% initialization
w = waitbar(0, 'starting per-resolution STD computation');
progressCounter = 0;

basePaddingSize = 2 * nScales;
vidIn = PadVideoReplicate(vidIn, basePaddingSize);
aggregatedTotalResponse = zeros(size(vidIn));
elevations = linspace(0, elHalfAngle, nElevations);
elevations = elevations(2:end);
azimuths = linspace(0, 360, nAzimuths+1);
azimuths = azimuths(1:end-1);
totalOrientationNumber = length(azimuths) * length(elevations) + 1;
totalIterationNumber = 2 * nScales * totalOrientationNumber;

Gshort = Gaussian3D([0,0], 0, sigmaSpatial, []);

for k = 1:nScales
    vidScaled = gpuArray(safeResize(vidIn, 1/k * size(vidIn)));
    relativePaddingSize = basePaddingSize / k;
    frames = [60/k + relativePaddingSize, 120/k + relativePaddingSize];    
    spatialStd = gpuArray(Gaussian3dStd(vidScaled, Gshort));

    %% total STD difference power norm caclculation
    %0 elev handling
    temporalStd = Std3DActivation(spatialStd, sigmaTemporal, 0, 0);
    stdDiff = minMaxNorm(spatialStd) - minMaxNorm(temporalStd);
    stdTotalPowerSum = abs(stdDiff).^normQ;
    
    if k == 1 || k == 2
        saveSnapshots(gather(spatialStd(relativePaddingSize+1:end-relativePaddingSize, ...
            relativePaddingSize+1:end-relativePaddingSize, :)), snapshotDir, ['spatial_std_k_', num2str(k)], frames);
        saveSnapshots(gather(temporalStd(relativePaddingSize+1:end-relativePaddingSize, ...
            relativePaddingSize+1:end-relativePaddingSize, :)), snapshotDir, ['temporal_std_k_', num2str(k)], frames);
    end
    
    progressCounter = progressCounter + 1;
    waitbar(progressCounter / totalIterationNumber, w);

    for i = 1:length(azimuths)
        for j = 1:length(elevations)
            temporalStd = Std3DActivation(spatialStd, sigmaTemporal, azimuths(i), elevations(j));
            stdDiff = minMaxNorm(spatialStd) - minMaxNorm(temporalStd);
            stdTotalPowerSum = stdTotalPowerSum + abs(stdDiff).^normQ;
            
            progressCounter = progressCounter + 1;
            waitbar(progressCounter / totalIterationNumber, w);   
        end
    end

    %% STD difference normalization
    %0 elev handling
    temporalStd = Std3DActivation(spatialStd, sigmaTemporal, 0, 0);
    stdDiff = minMaxNorm(spatialStd) - minMaxNorm(temporalStd);
    stdDiffNormFactor = 1 + (stdTotalPowerSum - abs(stdDiff).^normQ).^(1/normQ);
    stdDiffNormed = stdDiff ./ stdDiffNormFactor;
    stdDiffOriTot = sign(stdDiffNormed) .* (abs(stdDiffNormed).^m1);
    
    if k == 1 || k == 2
        saveSnapshots(gather(stdDiff(relativePaddingSize+1:end-relativePaddingSize, ...
            relativePaddingSize+1:end-relativePaddingSize, :)), snapshotDir, ['std_diff_before_norm_k_', num2str(k)], frames);
        saveSnapshots(gather(stdDiffNormed(relativePaddingSize+1:end-relativePaddingSize, ...
            relativePaddingSize+1:end-relativePaddingSize, :)), snapshotDir, ['std_diff_after_norm_k_', num2str(k)], frames);
    end
    
    progressCounter = progressCounter + 1;
    waitbar(progressCounter / totalIterationNumber, w);
            
    for i = 1:length(azimuths)
        for j = 1:length(elevations)
            temporalStd = Std3DActivation(spatialStd, sigmaTemporal, azimuths(i), elevations(j));
            stdDiff = minMaxNorm(spatialStd) - minMaxNorm(temporalStd);
            stdDiffNormFactor = 1 + (stdTotalPowerSum - abs(stdDiff).^normQ).^(1/normQ);
            stdDiffNormed = stdDiff ./ stdDiffNormFactor;
            stdDiffOriTot = stdDiffOriTot + sign(stdDiffNormed) .* (abs(stdDiffNormed).^m1);
            
            progressCounter = progressCounter + 1;
            waitbar(progressCounter / totalIterationNumber, w);   
        end
    end
    
    %% per-scale aggregation
    stdDiffOriTot = sign(stdDiffOriTot) .* (abs(stdDiffOriTot).^(1/m1));
    
    if k == 1 || k == 2
        saveSnapshots(stdDiffOriTot(relativePaddingSize+1:end-relativePaddingSize, ...
            relativePaddingSize+1:end-relativePaddingSize, :), snapshotDir, ...
            ['extracted_feature_ori_summed_k_', num2str(k)], frames);
    end
    
    vidStdDiffRaised = gather(sign(stdDiffOriTot).*((abs(stdDiffOriTot)).^m2));
    aggregatedOrientationsResponse = imresize3(vidStdDiffRaised, size(vidIn));
    aggregatedOrientationsResponse = aggregatedOrientationsResponse/(k^m2);
    aggregatedTotalResponse = aggregatedTotalResponse + aggregatedOrientationsResponse;
    
    waitbar(progressCounter / totalIterationNumber, w, ['finished scale ', num2str(k)]);
end

aggregatedTotalResponse = sign(aggregatedTotalResponse) .* (abs(aggregatedTotalResponse).^(1/m2));
aggregatedTotalResponse = stripVideo(aggregatedTotalResponse, basePaddingSize);

close(w);
end