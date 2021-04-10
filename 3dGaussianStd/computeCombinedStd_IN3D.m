function [vidScaleTot] = computeCombinedStd_IN3D(vidIn, nAzimuths, nElevations, elHalfAngle, nScales, sigmaSpatial ,sigmaTemporal ,m1, m2)
vidIn = PadVideoReplicate(vidIn,2*nScales);
vidScaleTot = zeros(size(vidIn));

if(length(elHalfAngle) == 2)
    minAngle = elHalfAngle(1);
    maxAngle = elHalfAngle(2);
elseif(length(elHalfAngle) == 1)
    minAngle = 0;
    maxAngle = elHalfAngle;
else
    error('Invalid Parameter length, elHalfAngle needs to be of length 1 or 2');
end

vidScaleTot = zeros(size(vidIn));
Elevations = linspace(minAngle, maxAngle, nElevations);
if(minAngle == 0)
    Elevations = Elevations(2:end);
end

Azimuths = linspace(0,360,nAzimuths+1);
Azimuths = Azimuths(1:end-1);

Gshort = Gaussian3D([0,0],0,sigmaSpatial,[]);

w = waitbar(0, 'starting per-resolution STD computation');
progressCounter = 0;
totalIterationNumber = nScales * nElevations * nAzimuths + nScales;

for k = nScales:-1:1
    vidS = imresize3(vidIn,1/k,'Antialiasing',true);
    vidStd = Gaussian3dStd(vidS,Gshort);
    vidOriTot=zeros(size(vidS));
    
    if(minAngle == 0)
        %0 elev handling
        [std_out] = Std3DActivation(vidStd,sigmaTemporal, 0, 0);
        elevationNormFactor = 1;%1 - cosd(Elevations(1)/2);
        vidOriTot = vidOriTot+(std_out*elevationNormFactor).^m1;
    end
    
    for i = 1:length(Azimuths)
        for j = 1:length(Elevations)
            [std_out] = Std3DActivation(vidStd, sigmaTemporal, Azimuths(i), Elevations(j));
            
            elevationStart = Elevations(j) - Elevations(1)/2;
            elevationEnd = min(Elevations(j) + Elevations(1)/2, Elevations(end));
            elevationNormFactor = 1;%cosd(elevationStart) - cosd(elevationEnd);
            vidOriTot = min(vidOriTot,elevationNormFactor.*(std_out.^m1));
            
            progressCounter = progressCounter + 1;
            waitbar(progressCounter / totalIterationNumber, w);
        end
    end
    
    vidOriTot = vidOriTot.^(1/m1);
    vidStdDiff = vidStd - vidOriTot;
    vidScaled = imresize3(vidStdDiff.^m2,size(vidIn));
    vidScaled = vidScaled/(k^m2);
    vidScaleTot = vidScaleTot + vidScaled;
    
    waitbar(progressCounter / totalIterationNumber, w, ['finished scale ', num2str(k)]);
end
vidScaleTot = sign(vidScaleTot).*(abs(vidScaleTot).^(1/m2));
vidScaleTot = stripVideo(vidScaleTot, 2*nScales);

close(w);
end