function [aggregatedTotalResponse, aggregatedOrientations] = computeCombinedLF_IN3D(vidIn, nAzimuths ...
    , nElevations, elHalfAngle, nScales, percentileThreshold, baseFacilitationLength ...
    , alpha, m1, m2, normQ, snapshotDir)

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
    frames = [60/k + relativePaddingSize, 120/k + relativePaddingSize];    
    facilitationLength = max(3, baseFacilitationLength/k);
    
    %% total contrast power norm caclculation
    %0 elev handling
    [cp, cn] = calculateGaborResponse(vidScaled, 0, 0);
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
            [cp, cn] = calculateGaborResponse(vidScaled, azimuths(i), elevations(j));
            cpTotalPowerSum = cpTotalPowerSum + cp.^normQ;
            cnTotalPowerSum = cnTotalPowerSum + cn.^normQ;
            
            progressCounter = progressCounter + 1;
            waitbar(progressCounter / totalIterationNumber, w);
        end
    end
    
%     %% total activation threshold calculation
%     [cp,cn] = calculateGaborResponse(vidScaled, 0, 0);
%     cpNormFactor = 1 + (cpTotalPowerSum - cp.^normQ).^(1/normQ);
%     cnNormFactor = 1 + (cnTotalPowerSum - cn.^normQ).^(1/normQ);
%     cpNormed = cp ./ cpNormFactor;
%     cnNormed = cn ./ cnNormFactor;
%     
%     if k == 1 && strcmp(snapshotDir, '') == false
%         saveSnapshots(gather(cpNormed(relativePaddingSize + 1:end-relativePaddingSize, ...
%             relativePaddingSize + 1:end-relativePaddingSize, :)), snapshotDir, 'Cp_after_norm', frames);
%         saveSnapshots(gather(cnNormed(relativePaddingSize + 1:end-relativePaddingSize, ...
%             relativePaddingSize + 1:end-relativePaddingSize, :)), snapshotDir, 'Cn_after_norm', frames);
%     end
%     
%     totalActivationThreshold_p = max(cpNormed(relativePaddingSize+1:end-relativePaddingSize, ...
%         relativePaddingSize+1:end-relativePaddingSize, ...
%         relativePaddingSize+1:end-relativePaddingSize),[],'all');
%     totalActivationThreshold_n = max(cnNormed(relativePaddingSize+1:end-relativePaddingSize, ...
%         relativePaddingSize+1:end-relativePaddingSize, ...
%         relativePaddingSize+1:end-relativePaddingSize),[],'all');
%     
%     progressCounter = progressCounter + 1;
%     waitbar(progressCounter / totalIterationNumber, w);
%     
%     for i = 1:length(azimuths)
%         for j = 1:length(elevations)
%             [cp,cn] = calculateGaborResponse(vidScaled, azimuths(i), elevations(j));
%             cnNormFactor = 1 + (cnTotalPowerSum - abs(cn).^normQ).^(1/normQ);
%             cpNormFactor = 1 + (cpTotalPowerSum - abs(cp).^normQ).^(1/normQ);
%             cpNormed = cp ./ cpNormFactor;
%             cnNormed = cn ./ cnNormFactor;
%             totalActivationThreshold_p = max(max(cpNormed(relativePaddingSize+1:end-relativePaddingSize, ...
%                 relativePaddingSize+1:end-relativePaddingSize, ...
%                 relativePaddingSize+1:end-relativePaddingSize)), totalActivationThreshold_p);
%             totalActivationThreshold_n = max(max(cnNormed(relativePaddingSize+1:end-relativePaddingSize, ...
%                 relativePaddingSize+1:end-relativePaddingSize, ...
%                 relativePaddingSize+1:end-relativePaddingSize)), totalActivationThreshold_n);
%             
%             progressCounter = progressCounter + 1;
%             waitbar(progressCounter / totalIterationNumber, w);
%         end
%     end
%     
%     totalActivationThreshold_p = activationThreshold * totalActivationThreshold_p;
%     totalActivationThreshold_n = activationThreshold * totalActivationThreshold_n;
%     totalActivationThreshold = [totalActivationThreshold_p, totalActivationThreshold_n];
    
    %% lateral facilitation    
    tempSnapshotDir = '';
    if k == 1
        tempSnapshotDir = snapshotDir;
    end

    %0 elev handling
    [cp,cn] = calculateGaborResponse(vidScaled, 0,0);
    cpNormFactor = 1 + (cpTotalPowerSum - cp.^normQ).^(1/normQ);
    cnNormFactor = 1 + (cnTotalPowerSum - cn.^normQ).^(1/normQ);
    cpNormed = cp ./ cpNormFactor;
    cnNormed = cn ./ cnNormFactor;    
    [lf_n, lf_p] = Gabor3DActivation(cpNormed,cnNormed, 0, 0, relativePaddingSize, ...
        percentileThreshold, facilitationLength, alpha, tempSnapshotDir, frames);
    
    vidOriTot_n = lf_n.^m1;
    vidOriTot_p = lf_p.^m1;
                
    progressCounter = progressCounter + 1;
    waitbar(progressCounter / totalIterationNumber, w);
 
    for i = 1:length(azimuths)
        for j = 1:length(elevations)
            [cp,cn] = calculateGaborResponse(vidScaled, azimuths(i), elevations(j));
            cpNormFactor = 1 + (cpTotalPowerSum - cp.^normQ).^(1/normQ);
            cnNormFactor = 1 + (cnTotalPowerSum - cn.^normQ).^(1/normQ);
            cpNormed = cp ./ cpNormFactor;
            cnNormed = cn ./ cnNormFactor;
            [lf_n, lf_p] = Gabor3DActivation(cpNormed, cnNormed, azimuths(i), elevations(j), relativePaddingSize, ...
                percentileThreshold, facilitationLength, alpha, '', frames);

            vidOriTot_p = vidOriTot_p+lf_p.^m1;
            vidOriTot_n = vidOriTot_n+lf_n.^m1;
            
            progressCounter = progressCounter + 1;
            waitbar(progressCounter / totalIterationNumber, w);
        end
    end
    
    %% per scale aggregation
    vidOriTot_p = vidOriTot_p.^(1/m1);
    vidOriTot_n = vidOriTot_n.^(1/m1);
    vidOriTotDiff = vidOriTot_p - vidOriTot_n;
    
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