function [vidScaleTot] = computeCombinedLF_IN3D(vidIn, nAzimuths, nElevations, elHalfAngle, nScales, baseFacilitationLength, alpha, m1, m2)
vidScaleTot = zeros(size(vidIn));
Elevations = linspace(0,elHalfAngle,nElevations+1);
Elevations = Elevations(2:end);
Azimuths = linspace(0,360,nAzimuths+1);
Azimuths = Azimuths(1:end-1);
for k = 1:nScales
    vidS = imresize3(vidIn,1/k,'Antialiasing',true);
    vidOriTot_n=zeros(size(vidS));
    vidOriTot_p=zeros(size(vidS));
    for i = 1:length(Azimuths)
        for j = 1:length(Elevations)
            L = BuildGabor3D(Azimuths(i),Elevations(j));
            Co = imfilter(vidS,L,'replicate');
            Cp = max(Co,0);
            Cn = max(-Co,0);
            threshold = 0.3 * max(abs(Co),[],'all');
            Cp(Cp < threshold) = 0;
            Cn(Cn < threshold) = 0;
            
            FacilitationLength=max(3,baseFacilitationLength/k);
            [LF_n ,NR_n] = LFsc3D(Cn,Azimuths(i),Elevations(j),FacilitationLength);
            [LF_p ,NR_p] = LFsc3D(Cp,Azimuths(i),Elevations(j),FacilitationLength);
            LF_n=0.5*max(0,LF_n-alpha*NR_n);
            LF_p=0.5*max(0,LF_p-alpha*NR_p);
            
            vidOriTot_n = vidOriTot_n+LF_n.^m1;
            vidOriTot_p = vidOriTot_p+LF_p.^m1;
        end
        disp(['i',num2str(i)]);
    end
    %0 elev handling - replace with spherical normalization
    L = BuildGabor3D(0,0);
    Co = imfilter(vidS,L,'replicate');
    Cp = max(Co,0);
    Cn = max(-Co,0);
    threshold = 0.3 * max(abs(Co),[],'all');
    Cp(Cp < threshold) = 0;
    Cn(Cn < threshold) = 0;
    FacilitationLength=max(3,baseFacilitationLength/k);
    [LF_n ,NR_n] = LFsc3D(Cn,0,0,FacilitationLength);
    [LF_p ,NR_p] = LFsc3D(Cp,0,0,FacilitationLength);
    LF_n=0.5*max(0,LF_n-alpha*NR_n);
    LF_p=0.5*max(0,LF_p-alpha*NR_p);
    
    vidOriTot_n = vidOriTot_n+LF_n.^m1;
    vidOriTot_p = vidOriTot_p+LF_p.^m1;
    
    
    vidOriTot_n = vidOriTot_n.^(1/m1);
    vidOriTot_p = vidOriTot_p.^(1/m1);
    
    vidScalesArray = imresize3(vidOriTot_p.^m2 - vidOriTot_n.^m2,size(vidIn));
    vidScalesArray = vidScalesArray/k;
    vidScaleTot=vidScaleTot+vidScalesArray;
    disp(['k',num2str(k)]);
end
vidScaleTot = sign(vidScaleTot).*abs(vidScaleTot).^(1/m2);
vidScaleTot = vidScaleTot / max(abs(vidScaleTot(:)));
end