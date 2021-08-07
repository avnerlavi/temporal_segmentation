function [e,c,CM] = ContrastMeasure(vid)
[Gx,Gy,Gz] = imgradientxyz(vid);
Gmag = sqrt(Gx.^2+Gy.^2);
numerator = convn(Gmag.*vid,ones(3),'same');
denumenator = convn(Gmag,ones(3),'same');
e = numerator./(denumenator+1e-8);
c = abs(vid-e)./abs(vid+e+1e-8);
CM = mean(c,'all');
end

