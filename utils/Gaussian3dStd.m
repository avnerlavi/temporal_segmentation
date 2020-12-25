function [vidOut] = Gaussian3dStd(vidIn,G)
    M2 = convn(vidIn.^2,G,'same');
    M1 = convn(vidIn,G,'same').^2;
    vidOut = sqrt(M2-M1);
end

