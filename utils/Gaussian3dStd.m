function [vidOut] = Gaussian3dStd(vidIn,G)
    M2 = conv3FFT(vidIn.^2,G);
    M1 = conv3FFT(vidIn,G).^2;
    vidOut = sqrt(M2-M1);
end

