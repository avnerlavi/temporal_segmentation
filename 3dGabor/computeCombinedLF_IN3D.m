function [vidScaleTot] = computeCombinedLF_IN3D(vidIn, nAzimuths, nElevations, elHalfAngle, nScales, baseFacilitationLength, alpha, m1, m2)
vidScaleTot = zeros(size(vidIn));
Elevations = linspace(0,elHalfAngle,nElevations+1);
Elevations = Elevations(2:end);
Azimuths = linspace(0,360,nAzimuths+1);
Azimuths = Azimuths(1:end-1);
for k = nScales:-1:1
    vidS = imresize3(vidIn,1/k,'Antialiasing',true);
    vidOriTot_n=zeros(size(vidS));
    vidOriTot_p=zeros(size(vidS));
    FacilitationLength=max(3, baseFacilitationLength/k);
    
    %0 elev handling
    [LF_n, LF_p] = Gabor3DActivation(vidS, 0, 0, FacilitationLength, alpha);
    elevationNormFactor = 1 - cos(Elevations(1)/2);
    vidOriTot_n = vidOriTot_n+(LF_n*elevationNormFactor).^m1;
    vidOriTot_p = vidOriTot_p+(LF_p*elevationNormFactor).^m1;
    
    for i = 1:length(Azimuths)
        for j = 1:length(Elevations)
            [LF_n, LF_p] = Gabor3DActivation(vidS, Azimuths(i), Elevations(j), FacilitationLength, alpha);
            
            elevationStart = Elevations(j) - Elevations(1)/2;
            elevationEnd = min(Elevations(j) + Elevations(1)/2, Elevations(end));
            elevationNormFactor = cos(elevationStart) - cos(elevationEnd);
            vidOriTot_n = vidOriTot_n+(LF_n*elevationNormFactor).^m1;
            vidOriTot_p = vidOriTot_p+(LF_p*elevationNormFactor).^m1;
        end
        disp(['i',num2str(i)]);
    end
    
    vidOriTot_n = vidOriTot_n.^(1/m1);
    vidOriTot_p = vidOriTot_p.^(1/m1);
    
    vidScaled = imresize3(vidOriTot_p.^m2 - vidOriTot_n.^m2,size(vidIn));
    vidScaled = vidScaled/(k^m2);
    vidScaleTot=vidScaleTot+vidScaled;
    disp(['k',num2str(k)]);
end
vidScaleTot = sign(vidScaleTot).*abs(vidScaleTot).^(1/m2);
vidScaleTot = vidScaleTot / max(abs(vidScaleTot(:)));
end