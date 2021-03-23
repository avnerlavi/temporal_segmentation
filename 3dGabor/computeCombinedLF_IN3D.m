function [vidScaleTot, vidScalesPyr] = computeCombinedLF_IN3D(vidIn, nAzimuths, nElevations, elHalfAngle, nScales, activationThreshold, baseFacilitationLength, alpha, m1, m2)
Nvals = zeros(3,nScales * nElevations * nAzimuths + nScales);
Pvals = zeros(3,nScales * nElevations * nAzimuths + nScales);
w = waitbar(0, 'starting per-resolution LF computation');
progressCounter = 0;
totalIterationNumber = nScales * nElevations * nAzimuths + nScales;
vidIn = PadVideoReplicate(vidIn,2*nScales);

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
vidScalesPyr = cell(nScales);
n = 1;
for k = 1:nScales
    vidS = imresize3(vidIn,[1/k, 1/k, 1/k] .* size(vidIn),'Antialiasing',true);
    vidOriTot_n=zeros(size(vidS));
    vidOriTot_p=zeros(size(vidS));
    FacilitationLength=max(3, baseFacilitationLength/k);
    if(minAngle == 0)
        %0 elev handling
        [LF_n, LF_p] = Gabor3DActivation(vidS, 0, 0, activationThreshold, FacilitationLength, alpha);
        elevationNormFactor = 1;%1 - cosd(Elevations(1)/2);
        vidOriTot_n = vidOriTot_n+(LF_n*elevationNormFactor).^m1;
        vidOriTot_p = vidOriTot_p+(LF_p*elevationNormFactor).^m1;
        disp(['elevation: ',num2str(0),' azimuth: ',num2str(0), ...
            ' valueN: ', num2str(max(LF_n(5:end-5,5:end-5,5:end-5),[],'all')),' valueP: ', num2str(max(LF_p(5:end-5,5:end-5,5:end-5),[],'all'))])
        Nvals(:,n) = [0,0,max(LF_n(5:end-5,5:end-5,5:end-5),[],'all')];
        Pvals(:,n) = [0,0,max(LF_p(5:end-5,5:end-5,5:end-5),[],'all')];
        n=n+1;
    end
    for i = 1:length(Azimuths)
        for j = 1:length(Elevations)
            [LF_n, LF_p] = Gabor3DActivation(vidS, Azimuths(i), Elevations(j), activationThreshold, FacilitationLength, alpha);
            
            elevationStart = Elevations(j) - Elevations(1)/2;
            elevationEnd = min(Elevations(j) + Elevations(1)/2, Elevations(end));
            elevationNormFactor = 1;%cosd(elevationStart) - cosd(elevationEnd);
            vidOriTot_n = vidOriTot_n+(LF_n*elevationNormFactor).^m1;
            vidOriTot_p = vidOriTot_p+(LF_p*elevationNormFactor).^m1;
            progressCounter = progressCounter + 1;
            waitbar(progressCounter / totalIterationNumber, w);
            disp(['elevation: ',num2str(Elevations(j)),' azimuth: ',num2str(Azimuths(i)),...
                 ' valueN: ', num2str(max(LF_n(5:end-5,5:end-5,5:end-5),[],'all')),' valueP: ', num2str(max(LF_p(5:end-5,5:end-5,5:end-5),[],'all'))])
        Nvals(:,n) = [Elevations(j),Azimuths(i),max(LF_n(5:end-5,5:end-5,5:end-5),[],'all')];
        Pvals(:,n) = [Elevations(j),Azimuths(i),max(LF_p(5:end-5,5:end-5,5:end-5),[],'all')];
        n=n+1;
        end
    end
    
    vidOriTot_n = vidOriTot_n.^(1/m1);
    vidOriTot_p = vidOriTot_p.^(1/m1);
    
    vidScaled = imresize3(vidOriTot_p.^m2 - vidOriTot_n.^m2,size(vidIn));
    vidScaled = vidScaled/(k^m2);
    vidScalesPyr{k} = vidScaled;
    vidScaleTot = vidScaleTot + vidScaled;
    
    waitbar(progressCounter / totalIterationNumber, w, ['finished scale ', num2str(k)]);
end

vidScaleTot = sign(vidScaleTot).*abs(vidScaleTot).^(1/m2);

vidScaleTot = stripVideo(vidScaleTot, 2*nScales);
vidScaleTot = vidScaleTot/max(abs(vidScaleTot(:)));

close(w);
end