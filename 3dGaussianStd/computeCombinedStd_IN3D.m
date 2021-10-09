function [vidScaleTot] = computeCombinedStd_IN3D(vidIn, nAzimuths, nElevations ...
    , elHalfAngle, nScales, sigmaSpatial ,sigmaTemporal ,m1, m2, normQ)
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

for k = nScales:-1:1
    vidS = safeResize(vidIn,1/k * size(vidIn));
    spatialStd = gpuArray(Gaussian3dStd(vidS,Gshort));
%     vidOriTot = zeros(size(vidS));
    vidOriSTDDiffs = zeros([size(vidS), totalOrientationNumber]);

    %0 elev handling
    temporalStd = Std3DActivation(spatialStd, sigmaTemporal, 0, 0);
%     elevationNormFactor = 1;%1 - cosd(Elevations(1)/2);
%     vidOriTot = vidOriTot + stdOut;%(stdOut*elevationNormFactor).^m1;
    vidOriSTDDiffs(:,:,:,end) = gather(spatialStd - temporalStd);

    for i = 1:length(Azimuths)
        for j = 1:length(Elevations)
            currOrientationIndex = (i-1) * length(Elevations) + j;
%             Gshort = Gaussian3D([Azimuths(i), Elevations(j)],0,sigmaSpatial,[]);
%             vidStd = gpuArray(Gaussian3dStd(vidS, Gshort));

            temporalStd = Std3DActivation(spatialStd, sigmaTemporal, Azimuths(i), Elevations(j));
            
%             elevationStart = Elevations(j) - Elevations(1)/2;
%             elevationEnd = min(Elevations(j) + Elevations(1)/2, Elevations(end));
%             elevationNormFactor = 1;%cosd(elevationStart) - cosd(elevationEnd);
%             currVidOri = elevationNormFactor.*(stdOut.^m1);
%             vidOriTot = vidOriTot + stdOut;%min(vidOriTot, currVidOri);
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
    
    vidStdDiff = sum(vidOriSTDDiffs.^m1, 4).^(1/m1);
    reset(gpuDevice(1));
%     vidOriTot = vidOriTot.^(1/m1);
%     vidStdDiff = vidStd - vidOriTot;
    vidScaled = (imresize3(vidStdDiff,size(vidIn))).^m2;
    vidScaled = vidScaled/(k^m2);
    vidScaleTot = vidScaleTot + vidScaled;
    
    waitbar(progressCounter / totalIterationNumber, w, ['finished scale ', num2str(k)]);
end
vidScaleTot = sign(vidScaleTot).*(abs(vidScaleTot).^(1/m2));
vidScaleTot = stripVideo(vidScaleTot, 2*nScales);

close(w);
end