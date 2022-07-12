function [Gaussian] = Gaussian3DIso(var, shape)
Var = [var,var,var];
Shape = [shape,shape,shape];
[Gaussian] = Gaussian3D([0,0],0,Var,Shape);
end

