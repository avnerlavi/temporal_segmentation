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

imScaleTot = computeCombinedLF(imgIn, nOrientations, nScales, alpha, m1, m2);
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
