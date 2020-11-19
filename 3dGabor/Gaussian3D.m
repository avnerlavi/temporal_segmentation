function [Gaussian] = Gaussian3D(AzElDir,XYOrientation,sigma)
S = max(ceil(sigma));
x = -3*S:3*S;
y = -3*S:3*S;
z = -3*S:3*S;
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
Sigma = diag(sigma);
expArg = (R'*inv(Sigma)*R*r');
expArg = sum(r'.*expArg,1);
Gaussian = exp(-expArg); 

%Gaussian = Gaussian./max(abs(Gaussian),[],'all');
Gaussian = Gaussian./sum(abs(Gaussian),'all');
Gaussian = reshape(Gaussian,shape);
end

