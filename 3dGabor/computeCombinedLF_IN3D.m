function [aggregatedTotalResponse, aggregatedOrientations] = computeCombinedLF_IN3D(vidIn, nAzimuths ...
    , nElevations, elHalfAngle, nScales, thresholdFraction, percentileThreshold, gaborSize, gaborWavelength, ...
    baseFacilitationLength, alpha, m1, m2, normQ, snapshotDir, snapshotFrames)

%% initialization
w = waitbar(0, 'starting per-resolution LF computation');
progressCounter = 0;

basePaddingSize = 2 * baseFacilitationLength;
vidIn = PadVideoReplicate(vidIn,basePaddingSize);
aggregatedTotalResponse = zeros(size(vidIn));
elevations = linspace(0,elHalfAngle,nElevations);
elevations = elevations(2:end);
azimuths = linspace(0,360,nAzimuths+1);
azimuths = azimuths(1:end-1);
totalOrientationNumber = length(azimuths) * length(elevations) + 1;
totalIterationNumber = 2 * nScales * totalOrientationNumber;

aggregatedOrientations = cell(1, nScales);

for k = 1:nScales
    vidScaled = gpuArray(imresize3(vidIn, [1/k, 1/k, 1/k] .* size(vidIn), 'Antialiasing', true));
    relativePaddingSize = floor(basePaddingSize / k);
    frames = floor(snapshotFrames/k + relativePaddingSize);    
    facilitationLength = max(3, baseFacilitationLength/k);
    
    %% total contrast power norm caclculation
    %0 elev handling
    [cp, cn] = calculateGaborResponse(vidScaled, 0, 0, gaborSize, gaborWavelength);
    cpTotalPowerSum = cp.^normQ;
    cnTotalPowerSum = cn.^normQ;
    
    if k == 1 && strcmp(snapshotDir, '') == false
        saveSnapshots(gather(cp(relativePaddingSize + 1:end-relativePaddingSize, ...
            relativePaddingSize + 1:end-relativePaddingSize, :)), snapshotDir, 'Cp_before_norm', frames);
        saveSnapshots(gather(cn(relativePaddingSize + 1:end-relativePaddingSize, ...
            relativePaddingSize + 1:end-relativePaddingSize, :)), snapshotDir, 'Cn_before_norm', frames);
    end
    
    progressCounter = progressCounter + 1;
    waitbar(progressCounter / totalIterationNumber, w);
    
    for i = 1:length(azimuths)
        for j = 1:length(elevations)
            [cp, cn] = calculateGaborResponse(vidScaled, azimuths(i), elevations(j), ...
                gaborSize, gaborWavelength);
            cpTotalPowerSum = cpTotalPowerSum + cp.^normQ;
            cnTotalPowerSum = cnTotalPowerSum + cn.^normQ;
            
            progressCounter = progressCounter + 1;
            waitbar(progressCounter / totalIterationNumber, w);
        end
    end
    
    %% total activation threshold calculation
    [cp,cn] = calculateGaborResponse(vidScaled, 0, 0, gaborSize, gaborWavelength);
    cpNormFactor = 1 + (cpTotalPowerSum - cp.^normQ).^(1/normQ);
    cnNormFactor = 1 + (cnTotalPowerSum - cn.^normQ).^(1/normQ);
    cpNormed = cp ./ cpNormFactor;
    cnNormed = cn ./ cnNormFactor;
    
    if k == 1 && strcmp(snapshotDir, '') == false
        saveSnapshots(gather(cpNormed(relativePaddingSize + 1:end-relativePaddingSize, ...
            relativePaddingSize + 1:end-relativePaddingSize, :)), snapshotDir, 'Cp_after_norm', frames);
        saveSnapshots(gather(cnNormed(relativePaddingSize + 1:end-relativePaddingSize, ...
            relativePaddingSize + 1:end-relativePaddingSize, :)), snapshotDir, 'Cn_after_norm', frames);
    end
    
    totalActivationThreshold_p = max(cpNormed(relativePaddingSize+1:end-relativePaddingSize, ...
        relativePaddingSize+1:end-relativePaddingSize, ...
        relativePaddingSize+1:end-relativePaddingSize),[],'all');
    totalActivationThreshold_n = max(cnNormed(relativePaddingSize+1:end-relativePaddingSize, ...
        relativePaddingSize+1:end-relativePaddingSize, ...
        relativePaddingSize+1:end-relativePaddingSize),[],'all');
    
    progressCounter = progressCounter + 1;
    waitbar(progressCounter / totalIterationNumber, w);
    
    for i = 1:length(azimuths)
        for j = 1:length(elevations)
            [cp,cn] = calculateGaborResponse(vidScaled, azimuths(i), elevations(j), ...
                gaborSize, gaborWavelength);
            cnNormFactor = 1 + (cnTotalPowerSum - abs(cn).^normQ).^(1/normQ);
            cpNormFactor = 1 + (cpTotalPowerSum - abs(cp).^normQ).^(1/normQ);
            cpNormed = cp ./ cpNormFactor;
            cnNormed = cn ./ cnNormFactor;
            totalActivationThreshold_p = max(max(cpNormed(relativePaddingSize+1:end-relativePaddingSize, ...
                relativePaddingSize+1:end-relativePaddingSize, ...
                relativePaddingSize+1:end-relativePaddingSize), [], 'all'), totalActivationThreshold_p);
            totalActivationThreshold_n = max(max(cnNormed(relativePaddingSize+1:end-relativePaddingSize, ...
                relativePaddingSize+1:end-relativePaddingSize, ...
                relativePaddingSize+1:end-relativePaddingSize), [], 'all'), totalActivationThreshold_n);
            
            progressCounter = progressCounter + 1;
            waitbar(progressCounter / totalIterationNumber, w);
        end
    end
    
    totalActivationThreshold_p = thresholdFraction * totalActivationThreshold_p;
    totalActivationThreshold_n = thresholdFraction * totalActivationThreshold_n;
    totalActivationThreshold = [totalActivationThreshold_p, totalActivationThreshold_n];
    
    %% lateral facilitation    
    tempSnapshotDir = '';

    %0 elev handling
    [cp, cn] = calculateGaborResponse(vidScaled, 0, 0, gaborSize, gaborWavelength);
    cpNormFactor = 1 + (cpTotalPowerSum - cp.^normQ).^(1/normQ);
    cnNormFactor = 1 + (cnTotalPowerSum - cn.^normQ).^(1/normQ);
    cpNormed = cp ./ cpNormFactor;
    cnNormed = cn ./ cnNormFactor;    
    
    if k == 1
        tempSnapshotDir = snapshotDir;
    end
    
    saveSnapshots(gather(cpNormed(relativePaddingSize + 1:end-relativePaddingSize, ...
    	relativePaddingSize + 1:end-relativePaddingSize, :)), tempSnapshotDir, 'Cp_after_norm_az_0_el_0', frames);
	saveSnapshots(gather(cnNormed(relativePaddingSize + 1:end-relativePaddingSize, ...
        relativePaddingSize + 1:end-relativePaddingSize, :)), tempSnapshotDir, 'Cn_after_norm_az_0_el_0', frames);
            
    [lf_p, lf_n] = Gabor3DActivation(cpNormed,cnNormed, 0, 0, relativePaddingSize, ...
        percentileThreshold, facilitationLength, alpha, tempSnapshotDir, frames, totalActivationThreshold);
    
%     vidOriTot_n = lf_n.^m1;
%     vidOriTot_p = lf_p.^m1;
    vidOriTot_o = sign(lf_p - lf_n) .* (abs(lf_p - lf_n)).^m1;
    
    tempSnapshotDir = '';
    
    progressCounter = progressCounter + 1;
    waitbar(progressCounter / totalIterationNumber, w);
 
    for i = 1:length(azimuths)
        for j = 1:length(elevations)
            [cp, cn] = calculateGaborResponse(vidScaled, azimuths(i), elevations(j), ...
                gaborSize, gaborWavelength);
            cpNormFactor = 1 + (cpTotalPowerSum - cp.^normQ).^(1/normQ);
            cnNormFactor = 1 + (cnTotalPowerSum - cn.^normQ).^(1/normQ);
            cpNormed = cp ./ cpNormFactor;
            cnNormed = cn ./ cnNormFactor;
            
            if azimuths(i) == 90 && j == length(elevations) && k == 1
                tempSnapshotDir = snapshotDir;
            end
            
            saveSnapshots(gather(cpNormed(relativePaddingSize + 1:end-relativePaddingSize, ...
                relativePaddingSize + 1:end-relativePaddingSize, :)), tempSnapshotDir, ['Cp_after_norm_az_', num2str(azimuths(i)), '_el_', num2str(elevations(j))], frames);
            saveSnapshots(gather(cnNormed(relativePaddingSize + 1:end-relativePaddingSize, ...
            	relativePaddingSize + 1:end-relativePaddingSize, :)), tempSnapshotDir, ['Cn_after_norm_az_', num2str(azimuths(i)), '_el_', num2str(elevations(j))], frames);
            
            [lf_p, lf_n] = Gabor3DActivation(cpNormed, cnNormed, azimuths(i), elevations(j), relativePaddingSize, ...
                percentileThreshold, facilitationLength, alpha, tempSnapshotDir, frames, totalActivationThreshold);

%             vidOriTot_p = vidOriTot_p+lf_p.^m1;
%             vidOriTot_n = vidOriTot_n+lf_n.^m1;
            vidOriTot_o = vidOriTot_o + sign(lf_p - lf_n) .* (abs(lf_p - lf_n)).^m1;

            
            tempSnapshotDir = '';
            
            progressCounter = progressCounter + 1;
            waitbar(progressCounter / totalIterationNumber, w);
        end
    end
    
    %% per scale aggregation
%     vidOriTot_p = vidOriTot_p.^(1/m1);
%     vidOriTot_n = vidOriTot_n.^(1/m1);
%     vidOriTotDiff = vidOriTot_p - vidOriTot_n;
    vidOriTotDiff = sign(vidOriTot_o) .* (abs(vidOriTot_o)).^(1/m1);
    
    if k == 1 || k == 2 && strcmp(snapshotDir, '') == false
        saveSnapshots(gather(vidOriTotDiff(relativePaddingSize + 1:end-relativePaddingSize, relativePaddingSize + 1:end-relativePaddingSize, :)), ...
            snapshotDir, ['orientation_summed_diff_k_', num2str(k)], frames);
    end
    
    vidOriTotDiffRaised = gather(sign(vidOriTotDiff).*((abs(vidOriTotDiff)).^m2));
    aggregatedOrientationsResponse = imresize3(vidOriTotDiffRaised, size(vidIn));    
    aggregatedOrientationsResponse = aggregatedOrientationsResponse/(k^m2);
    aggregatedOrientations{k} = aggregatedOrientationsResponse;
    aggregatedTotalResponse = aggregatedTotalResponse + aggregatedOrientationsResponse;
    
    waitbar(progressCounter / totalIterationNumber, w, ['finished scale ', num2str(k)]);
end

%% inter-scale aggregation
aggregatedTotalResponse = sign(aggregatedTotalResponse).*abs(aggregatedTotalResponse).^(1/m2);

aggregatedTotalResponse = stripVideo(aggregatedTotalResponse, basePaddingSize);
aggregatedTotalResponse = aggregatedTotalResponse/max(abs(aggregatedTotalResponse(:)));

close(w);
end