function [vidScaleTot] = computeCombinedStd_IN3D(vidIn, nAzimuths, nElevations, elHalfAngle, nScales, m1, m2)
vidIn = PadVideoReplicate(vidIn,2*nScales);
vidScaleTot = zeros(size(vidIn));
Elevations = linspace(0,elHalfAngle,nElevations+1);
Elevations = Elevations(2:end);
Azimuths = linspace(0,360,nAzimuths+1);
Azimuths = Azimuths(1:end-1);
sigmaS = [3,3,0.1];
Gshort = Gaussian3D([0,0],0,sigmaS,[]);

for k = nScales:-1:1
    vidS = imresize3(vidIn,1/k,'Antialiasing',true);
    vidStd = stdfilt(vidS,ones(5,5,1));
    vidOriTot=zeros(size(vidS));

    %0 elev handling
    [std_out] = Std3DActivation(vidStd, 0, 0);
    elevationNormFactor = 1;%1 - cosd(Elevations(1)/2);
    vidOriTot = vidOriTot+(std_out*elevationNormFactor).^m1;

    for i = 1:length(Azimuths)
        for j = 1:length(Elevations)
            [std_out] = Std3DActivation(vidStd, Azimuths(i), Elevations(j));
            
            elevationStart = Elevations(j) - Elevations(1)/2;
            elevationEnd = min(Elevations(j) + Elevations(1)/2, Elevations(end));
            elevationNormFactor = 1;%cosd(elevationStart) - cosd(elevationEnd);
            vidOriTot = vidOriTot+(std_out*elevationNormFactor).^m1;
        end
        disp(['i',num2str(i)]);
    end
    
    vidOriTot = vidOriTot.^(1/m1);
    vidStdDiff = vidStd - vidOriTot;
    vidScaled = imresize3(vidStdDiff.^m2,size(vidIn));
    vidScaled = vidScaled/(k^m2);
    vidScaleTot = vidScaleTot + vidScaled;
    disp(['k',num2str(k)]);
end
vidScaleTot = sign(vidScaleTot).*(abs(vidScaleTot).^(1/m2));
vidScaleTot = stripVideo(vidScaleTot, 2*nScales);
end