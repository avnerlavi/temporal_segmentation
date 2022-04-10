function [vidScaleTot, vidScalesPyr] = computeCombinedLF_IN3D(vidIn, nAzimuths ...
    , nElevations, elHalfAngle, nScales, percentileThreshold, baseFacilitationLength ...
    , alpha, m1, m2, normQ)

w = waitbar(0, 'starting per-resolution LF computation');
progressCounter = 0;
vidIn = PadVideoReplicate(vidIn,2*baseFacilitationLength);

vidScaleTot = zeros(size(vidIn));
Elevations = linspace(0,elHalfAngle,nElevations);
Elevations = Elevations(2:end);
Azimuths = linspace(0,360,nAzimuths+1);
Azimuths = Azimuths(1:end-1);
vidScalesPyr = cell(nScales);

totalOrientationNumber = length(Azimuths) * length(Elevations) + 1;
totalIterationNumber = 2 * nScales * totalOrientationNumber;

for k = 1:nScales
    vidS = imresize3(vidIn,[1/k, 1/k, 1/k] .* size(vidIn),'Antialiasing',true);
    paddingSize = floor(2 * baseFacilitationLength / k);
    vidOriTot_n = zeros(size(vidS));
    vidOriTot_p = zeros(size(vidS));
    
    CnArr = zeros([size(vidS), totalOrientationNumber]);
    CpArr = zeros([size(vidS), totalOrientationNumber]);
    
    FacilitationLength = max(3, baseFacilitationLength/k);
    
    %0 elev handling
    L = gpuArray(BuildGabor3D(0, 0));
    Co = gather(conv3FFT(vidS, L));
    CpArr(:,:,:,end) = max(Co,0);
    CnArr(:,:,:,end) = max(-Co,0);
    
    for i = 1:length(Azimuths)
        for j = 1:length(Elevations)
            currOrientationIndex = (i-1) * length(Elevations) + j;
            L = gpuArray(BuildGabor3D(Azimuths(i), Elevations(j)));
            Co = gather(conv3FFT(vidS, L));
            CpArr(:,:,:,currOrientationIndex) = max(Co,0);
            CnArr(:,:,:,currOrientationIndex) = max(-Co,0);
            
            progressCounter = progressCounter + 1;
            waitbar(progressCounter / totalIterationNumber, w);
        end
    end
    
    CpTotalPowerSum = sum(abs(CpArr).^normQ, 4);
    CnTotalPowerSum = sum(abs(CnArr).^normQ, 4);

    %0 elev handling
    CpNormFactor = 1 + (CpTotalPowerSum - abs(CpArr(:,:,:, totalOrientationNumber)).^normQ).^(1/normQ);
    CnNormFactor = 1 + (CnTotalPowerSum - abs(CnArr(:,:,:, totalOrientationNumber)).^normQ).^(1/normQ);
    Cp = gpuArray(CpArr(:,:,:, totalOrientationNumber) ./ CpNormFactor);
    Cn = gpuArray(CnArr(:,:,:, totalOrientationNumber) ./ CnNormFactor);

    [LF_p, LF_n] = Gabor3DActivation(Cp, Cn, 0, 0, paddingSize, percentileThreshold, FacilitationLength, alpha);
    vidOriTot_p = vidOriTot_p+(gather(LF_p)).^m1;
    vidOriTot_n = vidOriTot_n+(gather(LF_n)).^m1;
    
    for i = 1:length(Azimuths)
        for j = 1:length(Elevations)
            currOrientationIndex = (i-1) * length(Elevations) + j;
            CpNormFactor = 1 + (CpTotalPowerSum - abs(CpArr(:,:,:, currOrientationIndex)).^normQ).^(1/normQ);
            CnNormFactor = 1 + (CnTotalPowerSum - abs(CnArr(:,:,:, currOrientationIndex)).^normQ).^(1/normQ);

            Cp = gpuArray(CpArr(:,:,:, currOrientationIndex) ./ CpNormFactor);
            Cn = gpuArray(CnArr(:,:,:, currOrientationIndex) ./ CnNormFactor);
            
            [LF_p, LF_n] = Gabor3DActivation(Cp, Cn, Azimuths(i), Elevations(j), paddingSize, percentileThreshold, FacilitationLength, alpha);
            
            vidOriTot_p = vidOriTot_p+(gather(LF_p)).^m1;
            vidOriTot_n = vidOriTot_n+(gather(LF_n)).^m1;
            
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
    
    waitbar(progressCounter / totalIterationNumber, w, ['finished scale ', num2str(k)]);
end

vidScaleTot = sign(vidScaleTot).*abs(vidScaleTot).^(1/m2);

vidScaleTot = stripVideo(vidScaleTot, 2*baseFacilitationLength);
vidScaleTot = vidScaleTot/max(abs(vidScaleTot(:)));

close(w);
end