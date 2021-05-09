function [vidScaleTot, vidScalesPyr] = computeCombinedLF_IN3D(vidIn, nAzimuths, nElevations, elHalfAngle, eccentricity, nScales, activationThreshold, baseFacilitationLength, alpha, m1, m2)
%waitbar handling
w = waitbar(0, 'starting per-resolution LF computation');
progressCounter = 0;
totalIterationNumber = nScales * nElevations * nAzimuths + nScales;
%input handling
vidIn = PadVideoReplicate(vidIn,2*nScales); %adding margin to avoid edge effects
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
    error('Invalid Parameter length, elHalfAngle needs to be of length 1 or 2');
end
%creating elevations + norm factors
Elevations = linspace(minAngle, maxAngle, nElevations);
if length(Elevations) > 1 %single elevation norm factor
    dElevation = Elevations(2)- Elevations(1);
else
    dElevation = nan;
end
if(minAngle == 0) %0 elev handling
    Elevations = Elevations(2:end);
    elevationNorm0Factor = computeElevationNormFactor(0, dElevation, eccentricity, minAngle, maxAngle, nAzimuths);
end
elevationNormFactors = computeElevationNormFactor(Elevations, dElevation, eccentricity, minAngle, maxAngle, nAzimuths);
%creating azimuths
Azimuths = linspace(0,360,nAzimuths+1);
Azimuths = Azimuths(1:end-1);

for k = 1:nScales %main loop
    
    vidS = imresize3(vidIn,[1/k, 1/k, 1/k] .* size(vidIn),'Antialiasing',true);
    vidOriTot_n=zeros(size(vidS));
    vidOriTot_p=zeros(size(vidS));
    FacilitationLength=max(3, baseFacilitationLength/k);
    if(minAngle == 0) %0 elev handling
        [LF_n, LF_p] = Gabor3DActivation(vidS, 0, 0, activationThreshold, FacilitationLength, alpha);
        vidOriTot_n = vidOriTot_n+(LF_n*elevationNorm0Factor).^m1;
        vidOriTot_p = vidOriTot_p+(LF_p*elevationNorm0Factor).^m1;
    end
    for i = 1:length(Azimuths)
        for j = 1:length(Elevations)
            [LF_n, LF_p] = Gabor3DActivation(vidS, Azimuths(i), Elevations(j), activationThreshold, FacilitationLength, alpha);
            %combining angles
            vidOriTot_n = vidOriTot_n+(LF_n*elevationNormFactors(j)).^m1;
            vidOriTot_p = vidOriTot_p+(LF_p*elevationNormFactors(j)).^m1;
            %waitbar handling
            progressCounter = progressCounter + 1;
            waitbar(progressCounter / totalIterationNumber, w);
        end
    end
    %rooting angles
    vidOriTot_n = vidOriTot_n.^(1/m1);
    vidOriTot_p = vidOriTot_p.^(1/m1);
    %combining scales
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