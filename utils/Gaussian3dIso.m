function [Gaussian] = Gaussian3dIso(sigma,shape)
Sigma = [sigma,sigma,sigma];
Shape = [shape,shape,shape];
[Gaussian] = Gaussian3D([0,0],0,Sigma,Shape);
end

