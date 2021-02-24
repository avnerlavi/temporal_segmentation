function [vidOut] = Gaussian3dStd(vidIn,G)
    M2 = convn(vidIn.^2,G,'same');
    M1 = convn(vidIn,G,'same').^2;
    temp = M2-M1;
    temp(temp<0) = 0;
    vidOut = sqrt(temp);
end