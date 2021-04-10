function [L] = buildGabor(orientation)
x=1:5;
y=1:5;
x0=ceil(length(x)/2);
y0=ceil(length(y)/2);
sigma=8/5;
lambda=12/5;
w = 2*pi/lambda;
[X,Y] = meshgrid(x,y);
X = X-x0;
Y= Y-y0;
G = exp(-X.^2/sigma^2 - Y.^2/sigma^2);
Wave = X * cosd(orientation)+ Y * sind(orientation);
Wave = cos(w * Wave);
L = G .* Wave;

Norm = L(:)' * Wave(:); % convolution at 0 = sum(L(:).*sum(Wave(:))) = L(:)' * Wave(:)
L = L./Norm;
end

