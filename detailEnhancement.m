function [imgOut] = detailEnhancement(imgInRaw,nOrientations,nScales,verbose)
alpha = 1;
m1 = 1.5;
m2 = 1;
beta = 2;

if size(imgInRaw,3)>1
    hsv=rgb2hsv(imgInRaw);
    imgIn=hsv(:,:,3);
else
    imgIn=im2double(imgInRaw);
end

imScalesArray=zeros(size(imgIn,1),size(imgIn,2),nScales);
imScaleTot=zeros(size(imgIn,1),size(imgIn,2));
Orientations=linspace(0,pi,nOrientations+1);
Orientations = Orientations(1:end-1);
for j=1:nScales
    imgS=imresize(imgIn,1/j,'Antialiasing',true); %instead of min(1,1/(2*(j-1)))
    imOriTot_n=zeros(size(imgS));
    imOriTot_p=zeros(size(imgS));
    for i=1:nOrientations
        L = buildGabor(Orientations(i));
        Co = conv2(imgS,L,'same');
        Cp = max(Co,0);
        Cn = max(-Co,0);
        threshold = 0.05 * max(abs(Co),[],'all'); %% to change
        Cp(Cp < threshold) = 0;
        Cn(Cn < threshold) = 0;
        
        FacilitationLength=max(5,20/j);
        [LF_n ,NR_n] = LFsc2(Cn,rad2deg(Orientations(i)),FacilitationLength);
        [LF_p ,NR_p] = LFsc2(Cp,rad2deg(Orientations(i)),FacilitationLength);
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
imScaleTot = 20*imScaleTot / max(abs(imScaleTot(:)));
%imScaleTot = 0.1*min(0.5*imScaleTot,4);%IMsceltot/(KK*SS.^0.5);
%imScaleTot = 0.5*imScaleTot;
% tmp = imgIn + imScaleTot;
out_p = max(imScaleTot,0)./(1 + beta*imgIn);%max(1,15*(tmp-0.7).^2); %not sure where these numbers are from...
out_n = min(imScaleTot,0)./(1 + beta*(1 - imgIn));%(1+5*(tmp<0.1).*(0.1-tmp));
out = imgIn + out_p + out_n;

out(out>1) = 1;
out(out<0) = 0;


if size(imgInRaw,3)>1
    hsv(:,:,3)=out;
    imgOut = hsv2rgb(hsv);
else
imgOut = out;
end

if(verbose)
    figure()
    subplot(2,2,1)
    imshow(imgInRaw)
    title('Original')
    subplot(2,2,2)
    imshow(imgOut)
    title('Enhanced')
    subplot(2,2,3)
    imshow(out_p + out_n,[])
    colorbar
    title('Difference')
end
end

