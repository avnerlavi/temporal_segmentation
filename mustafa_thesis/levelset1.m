% clear all;
% close all;
% Img=imread('img1.png');
% Img=double(Img(:,:,1));
close all;
% ImgC=AlgParamsSeg.InputImgC;
% realIm=AlgParamsSeg.InputImg;
Img=out;
% Img=double(realIm);
%x=centerOfMass(2);y=centerOfMass(1);
[x y]=size(Img);
x=110;
y=100;
%% parameter setting
timestep=0.1;  % time step
mu=0.2/timestep;  % coefficient of the distance regularization term R(phi)
iter_inner=20;
iter_outer=50;
lambda=1; % coefficient of the weighted length term L(phi)
alfa=-1;  % coefficient of the weighted area term A(phi)
epsilon=1.5; % papramater that specifies the width of the DiracDelta function
sigma=1;    % scale parameter in Gaussian kernel
G=fspecial('gaussian',1,sigma); % Gaussian kernel
Img_smooth=conv2(Img,G,'same');  % smooth image by Gaussiin convolution
[Ix,Iy]=gradient(Img_smooth);
f=Ix.^2+Iy.^2;
g=1./(1+f);  % edge indicator function.
% initialize LSF as binary step function
c0=2;
initialLSF = c0*ones(size(Img));
% generate the initial region R0 as two rectangles
% initialLSF(25:35,20:25)=-c0; 
initialLSF(x-3:x+3,y-3:y+3)=-c0;

% SE=strel('disk',5);
% Jerode2=imdilate(BWWafterOP,SE);
% JJ=double(~Jerode);
% JJ(~JJ) = -c0;
%phi=JJ;

phi=initialLSF;
% figure(1);
% mesh(-phi);   % for a better view, the LSF is displayed upside down
% hold on;  contour(phi, [0,0], 'r','LineWidth',2);
% title('Initial level set function');
% view([-80 35]);
figure(2);
imshow(Img,[]); axis off; axis equal; colormap(gray); hold on;  contour(phi, [0,0], 'r');
% title('Initial zero level contour');
pause(0.5);
%%
potential=1;  
if potential ==1
    potentialFunction = 'single-well';  % use single well potential p1(s)=0.5*(s-1)^2, which is good for region-based model 
elseif potential == 2
    potentialFunction = 'double-well';  % use double-well potential in Eq. (16), which is good for both edge and region based models
else
    potentialFunction = 'double-well';  % default choice of potential function
end  
% start level set evolution
for n=1:iter_outer
    phi = drlse_edge(phi, g, lambda, mu, alfa, epsilon, timestep, iter_inner, potentialFunction);    
    if mod(n,2)==0
        figure(2);
        imagesc(Img,[0, 255]); axis off; axis equal; colormap(gray); hold on;  contour(phi, [0,0], 'r');
    end
end
% refine the zero level contour by further level set evolution with alfa=0
alfa=0;
iter_refine =0;
phinew = drlse_edge(phi, g, lambda, mu, alfa, epsilon, timestep, iter_inner, potentialFunction);
finalLSF=phinew;
figure(2);
subplot(1,2,1);imshow(ImC,[]);%title('Original Image');

subplot(1,2,2);
imshow(Img,[]); axis off; axis equal; colormap(gray); hold on;  contour(phi, [0,0], 'r');
hold on;  contour(phi, [0,0], 'r');
% str=['Final zero level contour, ', num2str(iter_outer*iter_inner+iter_refine), ' iterations'];
str='Final zero level contour';
%title(str);
% %3D
% figure;
% mesh(-finalLSF); % for a better view, the LSF is displayed upside down
% hold on;  contour(phi, [0,0], 'r','LineWidth',2);
% view([-80 35]);
% str=['Final level set function, ', num2str(iter_outer*iter_inner+iter_refine), ' iterations'];
% title(str);
% axis on;
% [nrow, ncol]=size(Img);
% axis([1 ncol 1 nrow -5 5]);
% set(gca,'ZTick',[-3:1:3]);
% set(gca,'FontSize',14)

function phi = drlse_edge(phi_0, g, lambda,mu, alfa, epsilon, timestep, iter, potentialFunction)
%  This Matlab code implements an edge-based active contour model as an
%  application of the Distance Regularized Level Set Evolution (DRLSE) formulation in Li et al's paper:
%
%      C. Li, C. Xu, C. Gui, M. D. Fox, "Distance Regularized Level Set Evolution and Its Application to Image Segmentation", 
%        IEEE Trans. Image Processing, vol. 19 (12), pp.3243-3254, 2010.
%
%  Input:
%      phi_0: level set function to be updated by level set evolution
%      g: edge indicator function
%      mu: weight of distance regularization term
%      timestep: time step
%      lambda: weight of the weighted length term
%      alfa:   weight of the weighted area term
%      epsilon: width of Dirac Delta function
%      iter: number of iterations
%      potentialFunction: choice of potential function in distance regularization term. 
%              As mentioned in the above paper, two choices are provided: potentialFunction='single-well' or
%              potentialFunction='double-well', which correspond to the potential functions p1 (single-well) 
%              and p2 (double-well), respectively.%
%  Output:
%      phi: updated level set function after level set evolution
%
% Author: Chunming Li, all rights reserved
% E-mail: lchunming@gmail.com   
%         li_chunming@hotmail.com 
% URL:  http://www.imagecomputing.org/~cmli/

phi=phi_0;
[vx, vy]=gradient(g);
for k=1:iter
    phi=NeumannBoundCond(phi);
    [phi_x,phi_y]=gradient(phi);
    s=sqrt(phi_x.^2 + phi_y.^2);
    smallNumber=1e-10;  
    Nx=phi_x./(s+smallNumber); % add a small positive number to avoid division by zero
    Ny=phi_y./(s+smallNumber);
    curvature=div(Nx,Ny);
    if strcmp(potentialFunction,'single-well')
        distRegTerm = 4*del2(phi)-curvature;  % compute distance regularization term in equation (13) with the single-well potential p1.
    elseif strcmp(potentialFunction,'double-well');
        distRegTerm=distReg_p2(phi);  % compute the distance regularization term in eqaution (13) with the double-well potential p2.
    else
        disp('Error: Wrong choice of potential function. Please input the string "single-well" or "double-well" in the drlse_edge function.');
    end        
    diracPhi=Dirac(phi,epsilon);
    areaTerm=diracPhi.*g; % balloon/pressure force
    edgeTerm=diracPhi.*(vx.*Nx+vy.*Ny) + diracPhi.*g.*curvature;
    phi=phi + timestep*(mu*distRegTerm + lambda*edgeTerm + alfa*areaTerm);
end
end

function f = distReg_p2(phi)
% compute the distance regularization term with the double-well potential p2 in eqaution (16)
[phi_x,phi_y]=gradient(phi);
s=sqrt(phi_x.^2 + phi_y.^2);
a=(s>=0) & (s<=1);
b=(s>1);
ps=a.*sin(2*pi*s)/(2*pi)+b.*(s-1);  % compute first order derivative of the double-well potential p2 in eqaution (16)
dps=((ps~=0).*ps+(ps==0))./((s~=0).*s+(s==0));  % compute d_p(s)=p'(s)/s in equation (10). As s-->0, we have d_p(s)-->1 according to equation (18)
f = div(dps.*phi_x - phi_x, dps.*phi_y - phi_y) + 4*del2(phi);  
end
function f = div(nx,ny)
[nxx,junk]=gradient(nx);  
[junk,nyy]=gradient(ny);
f=nxx+nyy;
end
function f = Dirac(x, sigma)
f=(1/2/sigma)*(1+cos(pi*x/sigma));
b = (x<=sigma) & (x>=-sigma);
f = f.*b;
end
function g = NeumannBoundCond(f)
% Make a function satisfy Neumann boundary condition
[nrow,ncol] = size(f);
g = f;
g([1 nrow],[1 ncol]) = g([3 nrow-2],[3 ncol-2]);  
g([1 nrow],2:end-1) = g([3 nrow-2],2:end-1);          
g(2:end-1,[1 ncol]) = g(2:end-1,[3 ncol-2]); 
end