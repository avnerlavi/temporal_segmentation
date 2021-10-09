function [Gaussian] = Gaussian3DRemote(AzElDir, XYOrientation, sigma, shape, distance)
Gaussian = Gaussian3D(AzElDir, XYOrientation, sigma, shape);
Shape = ceil(shape);
if(numel(Shape)~=0)
    x = -(Shape-1)/2:(Shape-1)/2;
    y = -(Shape-1)/2:(Shape-1)/2;
    z = -(Shape-1)/2:(Shape-1)/2;
end

[X,Y,Z] = meshgrid(x,y,z);

Az = AzElDir(1);
El = AzElDir(2);
xRotated = X * cosd(Az) - Y * sind(Az);
yRotated = X * sind(Az) + Y * cosd(Az);

yRotated = yRotated * cosd(El) - Z * sind(El);
zRotated = yRotated * sind(El) + Z * cosd(El);

R = sqrt((xRotated).^2 + ...
    (yRotated).^2 + ...
    (zRotated).^2);

Gaussian(R < distance) = 0;

end