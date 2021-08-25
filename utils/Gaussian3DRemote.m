function [Gaussian] = Gaussian3DRemote(sigma, shape, distance)
Gaussian = Gaussian3DIso(sigma, shape);
Shape = ceil(shape);
if(numel(Shape)~=0)
    x = -(Shape-1)/2:(Shape-1)/2;
    y = -(Shape-1)/2:(Shape-1)/2;
    z = -(Shape-1)/2:(Shape-1)/2;
end

[X,Y,Z] = meshgrid(x,y,z);
R = sqrt((X - ceil(size(Gaussian,2)/2)).^2 + ...
    (Y - ceil(size(Gaussian,1)/2)).^2 + ...
    (Z - ceil(size(Gaussian,3)/2)).^2);

Gaussian(R < distance) = 0;

end

