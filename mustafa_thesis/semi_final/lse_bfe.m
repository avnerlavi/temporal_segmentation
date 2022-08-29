function [u, b, C]= lse_bfe(u0,Img, b, Ksigma,KONE, nu,timestep,mu,epsilon, iter_lse)
% This code implements the level set evolution (LSE) and bias field estimation
% proposed in the following paper:
%      C. Li, R. Huang, Z. Ding, C. Gatenby, D. N. Metaxas, and J. C. Gore, 
%      "A Level Set Method for Image Segmentation in the Presence of Intensity
%      Inhomogeneities with Application to MRI", IEEE Trans. Image Processing, 2011
%
% Note: 
%    This code implements the two-phase formulation of the model in the above paper.
%    The two-phase formulation uses the signs of a level set function to represent
%    two disjoint regions, and therefore can be used to segment an image into two regions,
%    which are represented by (u>0) and (u<0), where u is the level set function.
%
u=u0;
KB1 = conv2(b,Ksigma,'same');
KB2 = conv2(b.^2,Ksigma,'same');
C =updateC(Img, u, KB1, KB2, epsilon);

KONE_Img = Img.^2.*KONE;
u = updateLSF(Img,u, C, KONE_Img, KB1, KB2, mu, nu, timestep, epsilon, iter_lse);

Hu=Heaviside(u,epsilon);
M(:,:,1)=Hu;
M(:,:,2)=1-Hu;
b =updateB(Img, C, M,  Ksigma);


% update level set function
function u = updateLSF(Img, u0, C, KONE_Img, KB1, KB2, mu, nu, timestep, epsilon, iter_lse)
u=u0;
Hu=Heaviside(u,epsilon);
M(:,:,1)=Hu;
M(:,:,2)=1-Hu;
N_class=size(M,3);
e=zeros(size(M));
u=u0;
for kk=1:N_class
    e(:,:,kk) = KONE_Img - 2*Img.*C(kk).*KB1 + C(kk)^2*KB2;
end

for kk=1:iter_lse
    u=NeumannBoundCond(u);
    K=curvature_central(u);    % div()
    DiracU=Dirac(u,epsilon);
    ImageTerm=-DiracU.*(e(:,:,1)-e(:,:,2));
    %ImageTerm=-DiracU.*(S);
    penalizeTerm=mu*(4*del2(u)-K);
    %penalizeTerm=distReg_p2(u);
    lengthTerm=nu.*DiracU.*K;
    u=u+timestep*(lengthTerm+penalizeTerm+ImageTerm);
end

% update b
function b =updateB(Img, C, M,  Ksigma)

PC1=zeros(size(Img));
PC2=PC1;
N_class=size(M,3);
for kk=1:N_class
    PC1=PC1+C(kk)*M(:,:,kk);
    PC2=PC2+C(kk)^2*M(:,:,kk);
end
KNm1 = conv2(PC1.*Img,Ksigma,'same');
KDn1 = conv2(PC2,Ksigma,'same');

b = KNm1./KDn1;

% Update C
function C_new =updateC(Img, u, Kb1, Kb2, epsilon)
Hu=Heaviside(u,epsilon);
M(:,:,1)=Hu;
M(:,:,2)=1-Hu;
N_class=size(M,3);
for kk=1:N_class
    Nm2 = Kb1.*Img.*M(:,:,kk);
    Dn2 = Kb2.*M(:,:,kk);
    C_new(kk) = sum(Nm2(:))/sum(Dn2(:));
end

% Make a function satisfy Neumann boundary condition
function g = NeumannBoundCond(f)
[nrow,ncol] = size(f);
g = f;
g([1 nrow],[1 ncol]) = g([3 nrow-2],[3 ncol-2]);  
g([1 nrow],2:end-1) = g([3 nrow-2],2:end-1);          
g(2:end-1,[1 ncol]) = g(2:end-1,[3 ncol-2]);  

function k = curvature_central(u)
% compute curvature for u with central difference scheme
[ux,uy] = gradient(u);
normDu = sqrt(ux.^2+uy.^2+1e-10);
Nx = ux./normDu;
Ny = uy./normDu;
[nxx,junk] = gradient(Nx);
[junk,nyy] = gradient(Ny);
k = nxx+nyy;

function h = Heaviside(x,epsilon)    
h=0.5*(1+(2/pi)*atan(x./epsilon));

function f = Dirac(x, epsilon)    
f=(epsilon/pi)./(epsilon^2.+x.^2);

function f = distReg_p2(phi)
% compute the distance regularization term with the double-well potential p2 in eqaution (16)
[phi_x,phi_y]=gradient(phi);
s=sqrt(phi_x.^2 + phi_y.^2);
a=(s>=0) & (s<=1);
b=(s>1);
ps=a.*sin(2*pi*s)/(2*pi)+b.*(s-1);  % compute first order derivative of the double-well potential p2 in eqaution (16)
dps=((ps~=0).*ps+(ps==0))./((s~=0).*s+(s==0));  % compute d_p(s)=p'(s)/s in equation (10). As s-->0, we have d_p(s)-->1 according to equation (18)
f = div(dps.*phi_x - phi_x, dps.*phi_y - phi_y) + 4*del2(phi);  

function f = div(nx,ny)
[nxx,junk]=gradient(nx);  
[junk,nyy]=gradient(ny);
f=nxx+nyy;

