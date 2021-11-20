function [vidScaleTot, vidScalesPyr,threshold_data] = computeCombinedLF_IN3D(vidIn, nAzimuths ...
    , nElevations, elHalfAngle, eccentricity, nScales, activationThreshold, baseFacilitationLengths ...
    , alpha, m1, m2, normQ)
w = waitbar(0, 'starting per-resolution LF computation');
progressCounter = 0;
vidIn = PadVideoReplicate(vidIn,2*nScales);

vidScaleTot = zeros(size(vidIn));
vidScalesPyr = cell(nScales);
%halfAngle parsing
%TODO: might want to change input format
if(length(elHalfAngle) == 2)
    minAngle = elHalfAngle(1);
    maxAngle = elHalfAngle(2);
elseif(length(elHalfAngle) == 1)
    minAngle = 0;
    maxAngle = elHalfAngle;
else
    error('Invalid parameter length, elHalfAngle needs to be of length 1 or 2');
end
if(length(baseFacilitationLengths) == 2)
    minFacilitationLength = baseFacilitationLengths(1);
    maxFacilitationLength = baseFacilitationLengths(2);
elseif(length(baseFacilitationLengths) == 1)
    minFacilitationLength = baseFacilitationLengths;
    maxFacilitationLength = baseFacilitationLengths;
else
    error('Invalid parameter length, baseFacilitationLengths needs to be of length 1 or 2');
end
%creating elevations + norm factors
elevations = linspace(minAngle, maxAngle, nElevations);
if length(elevations) > 1 %single elevation norm factor
    dElevation = elevations(2)- elevations(1);
else
    dElevation = nan;
end
if(minAngle == 0) %0 elev handling
    elevations = elevations(2:end);
    elevationNorm0Factor = computeElevationNormFactor(0, dElevation, ...
        eccentricity, minAngle, maxAngle, nAzimuths);
end
elevationNormFactors = computeElevationNormFactor(elevations, dElevation, ...
    eccentricity, minAngle, maxAngle, nAzimuths);
%creating azimuths
azimuths = linspace(0,360,nAzimuths+1);
azimuths = azimuths(1:end-1);

totalOrientationNumber = length(azimuths) * length(elevations) + 1;
totalIterationNumber = 2 * nScales * totalOrientationNumber;

threshold_data = zeros(5,totalIterationNumber/2);

for k = 1:nScales
    vidS = imresize3(vidIn,[1/k, 1/k, 1/k] .* size(vidIn),'Antialiasing',true);
    vidOriTot_n = zeros(size(vidS));
    vidOriTot_p = zeros(size(vidS));
    CnArr = zeros([size(vidS), totalOrientationNumber]);
    CpArr = zeros([size(vidS), totalOrientationNumber]);
    primaryFL = max(3, maxFacilitationLength/k);
    secondaryFL = max(3, minFacilitationLength/k);
    facilitationLengths = computeEllipsoidRadius(elevations, primaryFL, secondaryFL);
    if(minAngle == 0) %0 elev handling
        L = BuildGabor3D(0, 0);
        Co = convn(vidS, L,'same');
        CpArr(:,:,:,end) = max(Co,0);
        CnArr(:,:,:,end) = max(-Co,0);
    end
    for i = 1:length(azimuths)
        for j = 1:length(elevations)
            currOrientationIndex = (i-1) * length(elevations) + j;
            L = BuildGabor3D(azimuths(i), elevations(j));
            Co = convn(vidS, L,'same');
            CpArr(:,:,:,currOrientationIndex) = max(Co,0);
            CnArr(:,:,:,currOrientationIndex) = max(-Co,0);
            
            progressCounter = progressCounter + 1;
            waitbar(progressCounter / totalIterationNumber, w);
        end
    end
    
    CpTotalPowerSum = sum(abs(CpArr).^normQ, 4);
    CnTotalPowerSum = sum(abs(CnArr).^normQ, 4);
    
    [~,CpArgmax] = max(CpArr,[],4);
    [~,CnArgmax] = max(CnArr,[],4);
    if(minAngle == 0) %0 elev handling
%         CpNormFactor = 1 + (CpTotalPowerSum - abs(CpArr(:,:,:, end)).^normQ).^(1/normQ);
%         CnNormFactor = 1 + (CnTotalPowerSum - abs(CnArr(:,:,:, end)).^normQ).^(1/normQ);
%         Cp = CpArr(:,:,:, totalOrientationNumber) ./ CpNormFactor;
%         Cn = CnArr(:,:,:, totalOrientationNumber) ./ CnNormFactor;
        Cp = CpArr(:,:,:, totalOrientationNumber).*double(CpArgmax==totalOrientationNumber);
        Cn = CnArr(:,:,:, totalOrientationNumber).*double(CnArgmax==totalOrientationNumber);        
        [LF_n, LF_p,threshold_data_local] = Gabor3DActivation(Cp,Cn, 0, 0, activationThreshold, primaryFL, alpha);
        threshold_data(:,k*totalOrientationNumber) = [1/k,threshold_data_local];
        vidOriTot_n = vidOriTot_n+(LF_n*elevationNorm0Factor).^m1;
        vidOriTot_p = vidOriTot_p+(LF_p*elevationNorm0Factor).^m1;
    end
    for i = 1:length(azimuths)
        for j = 1:length(elevations)
            currOrientationIndex = (i-1) * length(elevations) + j;
%             CnNormFactor = 1 + (CnTotalPowerSum - abs(CnArr(:,:,:, currOrientationIndex)).^normQ).^(1/normQ);
%             CpNormFactor = 1 + (CpTotalPowerSum - abs(CpArr(:,:,:, currOrientationIndex)).^normQ).^(1/normQ);
            
%             Cp = CpArr(:,:,:, currOrientationIndex) ./ CpNormFactor;
%             Cn = CnArr(:,:,:, currOrientationIndex) ./ CnNormFactor;
            Cp = CpArr(:,:,:, currOrientationIndex).*double(CpArgmax==currOrientationIndex);
            Cn = CnArr(:,:,:, currOrientationIndex).*double(CnArgmax==currOrientationIndex);
            
            [LF_n, LF_p,threshold_data_local] = Gabor3DActivation(Cp,Cn, azimuths(i), elevations(j), ...
                activationThreshold, facilitationLengths(j), alpha);
            threshold_data(:,(k-1)*totalOrientationNumber+currOrientationIndex) = [1/k,threshold_data_local];
            %combining angles
            vidOriTot_p = vidOriTot_p+(LF_p*elevationNormFactors(j)).^m1;
            vidOriTot_n = vidOriTot_n+(LF_n*elevationNormFactors(j)).^m1;
            %waitbar handling
            progressCounter = progressCounter + 1;
            waitbar(progressCounter / totalIterationNumber, w);
        end
    end
    
    vidOriTot_p = vidOriTot_p.^(1/m1);
    vidOriTot_n = vidOriTot_n.^(1/m1);
    
    vidScaled = imresize3(vidOriTot_p.^m2 - vidOriTot_n.^m2,size(vidIn));
    vidScaled = vidScaled/(k^m2);
    vidScalesPyr{k} = vidScaled;
    vidScaleTot = vidScaleTot + vidScaled;
    %waitbar handling
    waitbar(progressCounter / totalIterationNumber, w, ['finished scale ', num2str(k)]);
end
%rooting scales
vidScaleTot = sign(vidScaleTot).*abs(vidScaleTot).^(1/m2);

%removing margins
vidScaleTot = stripVideo(vidScaleTot, 2*nScales);
vidScaleTot = vidScaleTot/max(abs(vidScaleTot(:)));

close(w);
end