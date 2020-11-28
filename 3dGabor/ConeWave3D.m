function [ConeWave] = ConeWave3D(AzElDir,XYOrientation,WaveLengths,Shape)
S = max(ceil(WaveLengths));
if(numel(Shape)~=0)
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
else
x = -2*S:2*S;
y = -2*S:2*S;
z = -2*S:2*S;
end
[X,Y,Z] = meshgrid(x,y,z);
shape = size(X);
r = [X(:),Y(:),Z(:)];
Az = AzElDir(1);
El = AzElDir(2);
XY = XYOrientation;
D = [cosd(Az),sind(Az) ,0       ;
    -sind(Az),cosd(Az) ,0       ;
    0        ,0        ,1       ];

C = [1       ,0        ,0       ;
    0        ,cosd(El) ,sind(El);
    0        ,-sind(El),cosd(El)];

B = [cosd(XY),sind(XY) ,0       ;
    -sind(XY),cosd(XY) ,0       ;
    0        ,0        ,1       ];
R = B*C*D;
SigmaMat = diag(WaveLengths);


P = [2*pi/WaveLengths(1),0                  ,0  ;...
     0                  ,2*pi/WaveLengths(2),0  ;...
     0                  ,0                  ,0  ];
coords2D = P*R*r';
distance2D = sqrt(sum(coords2D.^2,1));
distance2D = reshape(distance2D,shape);
ConeWave = cos(distance2D);
end

