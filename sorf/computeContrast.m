function [contrast] = computeContrast(vidIn,kernel)
numerator = convn(abs(vidIn).^2, kernel, 'same');
denumerator = convn(abs(vidIn), kernel, 'same');
contrast = numerator ./ (denumerator + 1e-6);
end

