function [imScaleTot] = computeCombinedLF(imgIn, nOrientations, nScales, baseFacilitationLength, alpha, m1, m2, steerableGaussians)
sigma = 0.5;
imScalesArray = zeros(size(imgIn,1),size(imgIn,2),nScales);
imScaleTot = zeros(size(imgIn,1),size(imgIn,2));
Orientations = linspace(0,360,nOrientations+1);
Orientations = Orientations(1:end-1);
for j=1:nScales
    imgS=imresize(imgIn,1/j,'Antialiasing',true); %instead of min(1,1/(2*(j-1)))
    imOriTot_n=zeros(size(imgS));
    imOriTot_p=zeros(size(imgS));
    for i=1:nOrientations
        if(steerableGaussians)
            Gaussianed1 = steerGaussFilterOrder1(imgS, Orientations(i), sigma, false);
            Gaussianed2 = steerGaussFilterOrder2(imgS, Orientations(i), sigma, false);
            Co = Gaussianed1 + Gaussianed2;
        else
            L = buildGabor(Orientations(i));
            Co = conv2(imgS,L,'same');
        end
        Cp = max(Co,0);
        Cn = max(-Co,0);
        threshold = 0.03 * max(abs(Co),[],'all'); %% to change
        Cp(Cp < threshold) = 0;
        Cn(Cn < threshold) = 0;
        
        FacilitationLength=max(3,baseFacilitationLength/j);
        [LF_n ,NR_n] = LFsc2(Cn,Orientations(i),FacilitationLength);
        [LF_p ,NR_p] = LFsc2(Cp,Orientations(i),FacilitationLength);
        LF_n=0.5*max(0,LF_n-alpha*NR_n);
        LF_p=0.5*max(0,LF_p-alpha*NR_p);
        
        imOriTot_n = imOriTot_n+LF_n.^m1;
        imOriTot_p = imOriTot_p+LF_p.^m1;
    end
    
    imOriTot_n = imOriTot_n.^(1/m1);
    imOriTot_p = imOriTot_p.^(1/m1);
    
    imScalesArray(:,:,j)=imresize(imOriTot_p.^m2 - imOriTot_n.^m2,size(imgIn));
    imScalesArray(:,:,j) = imScalesArray(:,:,j)/j;%2.^(j-1)
    imScaleTot=imScaleTot+imScalesArray(:,:,j);
end

imScaleTot = sign(imScaleTot).*abs(imScaleTot).^(1/m2);
imScaleTot = imScaleTot / max(abs(imScaleTot(:)));
end

