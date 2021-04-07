function [distance2D] = PlanarDist(AzElDir,Shape)

if(numel(Shape)==1)
    x = -(Shape-1)/2:(Shape-1)/2;
    y = -(Shape-1)/2:(Shape-1)/2;
    z = -(Shape-1)/2:(Shape-1)/2;
elseif(numel(Shape)==3)
    x = -(Shape(1)-1)/2:(Shape(1)-1)/2;
    y = -(Shape(2)-1)/2:(Shape(2)-1)/2;
    z = -(Shape(3)-1)/2:(Shape(3)-1)/2;
else
    error('Shape size invalid (1 or 3)')
end

[X,Y,Z] = meshgrid(x,y,z);
shape = size(X);
r = [X(:),Y(:),Z(:)];
Az = AzElDir(1);
El = AzElDir(2);
D = [cosd(Az),sind(Az) ,0       ;
    -sind(Az),cosd(Az) ,0       ;
    0        ,0        ,1       ];

C = [1       ,0        ,0       ;
    0        ,cosd(El) ,sind(El);
    0        ,-sind(El),cosd(El)];

R = C*D;

P= [1,0,0 ;...
    0,1,0 ;...
    0,0,0];
coords2D = P*R*r';
distance2D = sqrt(sum(coords2D.^2,1));
distance2D = reshape(distance2D,shape);
end

