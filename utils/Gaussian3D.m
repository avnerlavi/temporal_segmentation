function [Gaussian] = Gaussian3D(AzElDir,XYOrientation,Sigma,Shape)

Shape = ceil(Shape);
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
    S = max(ceil(Sigma));
    S = sqrt(S/2);
    x = -3*S:3*S;
    y = -3*S:3*S;
    z = -3*S:3*S;
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
SigmaMat = diag(Sigma);
expArg = (R'*inv(SigmaMat)*R*r');
expArg = sum(r'.*expArg,1);
Gaussian = exp(-expArg);

%Gaussian = Gaussian./max(abs(Gaussian),[],'all');
Gaussian = Gaussian./sum(abs(Gaussian),'all');
Gaussian = reshape(Gaussian,shape);
end

