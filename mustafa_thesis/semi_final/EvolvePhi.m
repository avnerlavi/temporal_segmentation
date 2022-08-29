function [Phi Contour nIter] = EvolvePhi(ImgNum,SeedPoint,InputImg,ImgMasks,Phi0,NIter,dt,Epsilon,RegType,Alfas,Beta,Gamma)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description
%        This function evolves the level-set function phi.
%
% Usage:
%        [Phi,Contour] = EvolvePhi(I0,Phi0,NIter,Epsilon)
%
% Input:
%        ImgNum: input image number (string)
%        SeedPoint: a seed point in the lesion.
%        InputImg: input image.
%        ImgMasks: different image masks for active contour segmentation
%        ProcessedBmodeImg: multiresolution SORF response for B-mode image.
%        RelativeInten: relative intensity of  B-mode image.
%        Phi0: initial level set function.
%        NIter: maximum munber of iterations.
%        dt = "time interval" between iterations
%        Epsilon: a small number for the approximation of Heaviside and Dirac functions
%        RegType: type of regularization potintial function. if 1: p=p1, if 2: p=p2.
%        Alfas: vector of weights for region and edge terms in evolution equation of phi.
%        Beta: weight of length term in evolution equation of phi.
%        Gamma: weight of regularization term in evolution equation of phi.
%
% Output:
%        Phi: final phi.
%        Contour: final contour.
%        nIter: actual number of iterations.
%
% Author:
%        Itai Lang, August/2012
%
% Last modification:
%        August/2012 - Main code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% display image and initial contour
ActiveMasksInd = find(Alfas(1,:));
if length(ActiveMasksInd) == 1 % only one mask is active
    ActiveMask = ImgMasks(:,:,ActiveMasksInd);
    figure; imshow(ActiveMask,[]);
else % more than one mask is active
    figure; imshow(InputImg);
end
title(['Image number = ' ImgNum]);
hold on;

% display phi0
[C0 Handle] = contour(Phi0,[0 0],'r');
pause(0.1);

%% initialization
I0s = ImgMasks;
Phi = Phi0;
SmallNum = 1e-10; % define a small number in order to avoid division by zero
RegionTerms = zeros(size(I0s));
EdgeTerms = zeros(size(I0s));

%% evolve phi
for nIter = 1:NIter
    %nIter
    % make Phi satisfy Neuman boundary condition
    Phi = NeumanBoundCond(Phi);
    
    % calculate delta function of phi
    DiracPhi = Dirac(Phi,Epsilon);
    
   % H(Phi)
    HPhi = Heaviside(Phi,Epsilon);
    
    % integral(H(Phi))dxdy
    SumHPhi = sum(HPhi(:));
    
    % calculate derivatives of phi
    [Phix,Phiy] = gradient(Phi);
    
    % |grad(Phi)|
    AbsGradPhi = sqrt(Phix.^2+Phiy.^2);
    
    % grad(Phi)/|grad(Phi)|
    Nx = Phix./(AbsGradPhi+SmallNum); % x component
    Ny = Phiy./(AbsGradPhi+SmallNum); % y component
    
    % initialize Phit
    Phit = zeros(size(Phi));
    
    % calculate forces
    for nMask = 1:size(ImgMasks,3)
        % cuurent mask
        I0 = ImgMasks(:,:,nMask);
        
        %% calculate region based forces
        if Alfas(1,nMask) ~= 0
            % integral(I0*H(Phi))dxdy
            Integrand = I0.*HPhi;
            SumI0HPhi = sum(Integrand(:));
            
            % C+ =  integral(I0*H(Phi))dxdy / integral(H(Phi))dxdy
            CPlus = SumI0HPhi/SumHPhi;
            
            %C- = integral(I0*(1-H(Phi)))dxdy / integral((1-H(Phi)))dxdy
            CMinus = (sum(I0(:))-SumI0HPhi)/(numel(I0)-SumHPhi);
            
            % region based force term
            RegionTerms(:,:,nMask) = DiracPhi.*(-(I0-CPlus).^2+(I0-CMinus).^2);
        end % if Alfas(1,nMask) ~= 0
        
        %% calculate edge based forces
        if Alfas(2,nMask) ~= 0
            % gradient indicator function
            GGradI0 = GradIndFunc(I0,0.5);
            
            % edge based force term ( dirac(phi)*div(g(|grad(I0)|)*grad(phi)/|grad(phi)|) )
            EdgeTerms(:,:,nMask) = DiracPhi.*Div(GGradI0.*Nx,GGradI0.*Ny);
        end % if Alfas(2,nMask) ~= 0
        
        %% gradient decent equation (weighted sum of the different forces)
        Phit = Phit + Alfas(1,nMask)*RegionTerms(:,:,nMask) + Alfas(2,nMask)*EdgeTerms(:,:,nMask);
    end % for nMask = 1:size(ImgMasks,3)
    
    % calculate div(grad(phi)/|grad(phi)|)
    Curvature = Div(Nx,Ny);
    
    % add length term (legth of the contour) ( dirac(phi)*div(grad(phi)/|grad(phi)|) )
    if Beta ~=0
        % calculate length force term: dirac(phi)*div(grad(phi)/|grad(phi)|)
        LengthTerm = DiracPhi.*Curvature;
        
        % update Phit
        Phit = Phit + Beta*LengthTerm;
    end % if Beta ~=0
    
    % add regularization term (to keep Phi close to signed distance function)
    if Gamma ~= 0
        % calculate regularization term
        RegTerm = DistReg(RegType,Phi,Phix,Phiy,AbsGradPhi,Curvature);
        
        % update Phit
        Phit = Phit + Gamma*RegTerm;
    end % if Gamma ~=0
    
    % normalize Phit to the range [-1 1]
    %Phit = Phit/abs(min(Phit(:)));
    %Phit = Phit/max(Phit(:));
    
    % calculate new phi
    PhiNew = Phi+dt*Phit;
    
    % display current contour
     if mod(nIter,2)==0
         delete(Handle);
         [Contour Handle] = contour(PhiNew,[0 0],'b');
         pause(0.1);
     end
     
     % check stoping condition
     if mod(nIter,1)==0
         StopFlag = CheckStop(Phi,PhiNew,SeedPoint);
         
         % stop if phi has reched steady state in the area of the lesion
         if StopFlag
             % delete old contour 
             delete(Handle);
             
             % update phi
             Phi = PhiNew;
             
             % stop evolution of phi
             break;
         end
     end
     
     % update phi
     Phi = PhiNew;
     
     % re-initialize Phi
%      if mod(nIter,5)==0
%          Phi = ReIntPhi(Phi,SeedPoint);
%      end
     
     %if mod(nIter,1)==0
         % normalize phi to the range [-1 1]
         %Phi = Phi/abs(min(Phi(:)));
         %Phi = Phi/max(Phi(:));
     %end
end % for nIter = 1:NIter

% display initial and final contour
Contour = contour(Phi,[0 0],'g'); % final
contour(Phi0,[0 0],'r'); % initial
pause(0.1);
hold off

end % function Phi = EvolvePhi(I0,Phi0,NIter,Epsilon)

%% help functions
function GGradF = GradIndFunc(F,k)
[Fx,Fy] = gradient(F);
GradF = sqrt(Fx.^2+Fy.^2);
GGradF = 1./(1+GradF.^2/k^2);
end % function GF = GradIndFunc(F,k)

% make a function satisfy Neuman boundary condition
function FNeuman = NeumanBoundCond(F)
[Nrow,NCol] = size(F);
FNeuman = F;
FNeuman([1 Nrow],[1 NCol]) = FNeuman([3 Nrow-2],[3 NCol-2]);  
FNeuman([1 Nrow],2:end-1) = FNeuman([3 Nrow-2],2:end-1);          
FNeuman(2:end-1,[1 NCol]) = FNeuman(2:end-1,[3 NCol-2]);  
end

% divergence function
function DivF = Div(Fx,Fy)
[Fxx,Fxy] = gradient(Fx);  
[Fyx,Fyy] = gradient(Fy);
DivF = Fxx+Fyy;
end

% heaviside function
function HF = Heaviside(F,Epsilon)
HF = 0.5 + atan((1/Epsilon)*F)/pi;
end

% delta function
function DiracF = Dirac(F,Epsilon)    
DiracF = (Epsilon^2./(Epsilon^2+F.^2))/pi;
end

% distance rgularization force term
function f = DistReg(RegType,Phi,Phix,Phiy,AbsGradPhi,Curvature)
if RegType == 1 % potential function is p=p1
    % compute the distance regularization term with the single-well potential p1
    f = 4*del2(Phi) - Curvature; % the term is: Laplacian(phi)-div(grad(phi)/|grad(phi)|)
elseif RegType == 2 % potential function is p=p2
    % compute the distance regularization term with the double-well potential p2
    s=AbsGradPhi;
    a=(s>=0) & (s<=1);
    b=(s>1);
    ps=a.*sin(2*pi*s)/(2*pi)+b.*(s-1);  % compute first order derivative of the double-well potential p2 in eqaution (16)
    d_ps=((ps~=0).*ps+(ps==0))./((s~=0).*s+(s==0));  % compute d_p(s)=p'(s)/s in equation (10). As s-->0, we have d_p(s)-->1 according to equation (18)
    f = Div(d_ps.*Phix - Phix, d_ps.*Phiy - Phiy) + 4*del2(Phi);
else % error
    errordlg('Wrong type of regularization potential function','Function "EvolvePhi"');
end % if RegType == 1 % potential function is p=p1
end

% stopping condition
function [StopFlag PixDiff] = CheckStop(Phi,PhiNew,SeedPoint)
% binary mask
PhiBinaryMask = (Phi<=0);
PhiNewBinaryMask = (PhiNew<=0);

% take area around seed point
[AreaMask] = bwselect(PhiBinaryMask,SeedPoint(2),SeedPoint(1),4);
[AreaMaskNew] = bwselect(PhiNewBinaryMask,SeedPoint(2),SeedPoint(1),4);

% close open holes in the area around seed point
AreaMask = bwmorph(AreaMask,'close');
AreaMaskNew = bwmorph(AreaMaskNew,'close');

% fill holes in the area around seed point
%AreaMask = imfill(AreaMask,4,'holes');
%AreaMaskNew = imfill(AreaMaskNew,4,'holes');

% area difference
AbsDiff = abs(AreaMaskNew - AreaMask);

PixDiff = sum(AbsDiff(:));

% stoping condition
StopFlag = PixDiff <= 10;
end

