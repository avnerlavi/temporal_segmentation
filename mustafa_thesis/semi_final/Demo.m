function [u]=Demo(I,sigma)
% This code demonstrates the level set evolution (LSE) and bias field estimation
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
%    All rights researved by Chunming Li, who formulated the model, designed and 
%    implemented the algorithm in the above paper.
%
% E-mail: lchunming@gmail.com
% URL: http://www.engr.uconn.edu/~cmli/
% Copyright (c) by Chunming Li
% Author: Chunming Li
% clear all
%Img=imread('myBrain_axial.bmp');
%Img=double(Img(:,:,1))
% sigma =10; % scale parameter that specifies the size of the neighborhood
c0=1;
% num=11;
% Path=['C:\Users\97254\Documents\MATLAB\thesis\Images\FilteredIm\FiltSeg',num2str(num)];
% Format='jpg';
% I=double(imread([Path,'.',Format]));
% C=rgb2gray(I);
Im=imresize(I,[256 256]);
Img=double(Im);
A=255;
% Jerode=imfill(BWWafterOP,'holes');
% JJ=double(~Jerode);
% JJ(~JJ) = -c0;
% Img=Sorf;
%Img=double(AlgParamsSeg.InputImg);
Img=A*normalize01(Img); % rescale the image intensities
nu=0.001*A^2; % coefficient of arc length term
iter_outer=50; 
iter_inner=30;   % inner iteration for level set evolution

timestep=.1;
mu=1;  % coefficient for distance regularization term (regularize the level set function)
figure(1);
imagesc(Img,[0, 255]); colormap(gray); axis off; axis equal
% initialize level set function
initialLSF = c0*ones(size(Img));
initialLSF(30:90,50:90) = -c0;
%initialLSF(106-100:106+100,166-100:166+50) = -c0;
u=initialLSF;
% u=JJ;

figure(2);
imagesc(Img,[0, 255]); colormap(gray); axis off; axis equal
hold on;
contour(u,[0 0],'r');
title('Initial contour');

epsilon=1;
b=ones(size(Img));  %%% initialize bias field

K=fspecial('gaussian',round(2*sigma)*2+1,sigma); % Gaussian kernel
KI=conv2(Img,K,'same');
KONE=conv2(ones(size(Img)),K,'same');

[row,col]=size(Img);
N=row*col;

for n=1:iter_outer
    [u, b, C]= lse_bfe(u,Img, b, K,KONE, nu,timestep,mu,epsilon, iter_inner);

    if mod(n,2)==0
        pause(0.001);
        imagesc(Img,[0, 255]); colormap(gray); axis off; axis equal;
        hold on;
        contour(u,[0 0],'r');
        iterNum=[num2str(n), ' iterations'];
        title(iterNum);
        hold off;
    end
   
end
Mask =(Img>10);
Img_corrected=normalize01(Mask.*Img./(b+(b==0)))*255;
% 
% figure(3); imagesc(b);  colormap(gray); axis off; axis equal;
% title('Bias field');
% 
% figure(4);
% imagesc(Img_corrected); colormap(gray); axis off; axis equal;
% title('Bias corrected image');

BWg=u>0;
newBw=bwareaopen(BWg,30);
[LabB num]=bwlabel(double(newBw),4);
figure;imagesc(LabB)
%%
% segment=I>0;
% se=strel('disk',4);
% segment=imerode(segment,se);
% segment=imfill(segment,'holes');
% Lab=LabB.*segment;
% targetU=Lab==7;%classification
% % targetU2=Lab==nan;%classification
% % targetU=targetU1+targetU2;
% filledBW=imfill(targetU,'holes');
% [B,L,N,A] = bwboundaries(filledBW);
% % contourB=[B{1,1};B{2,1}];
% contourB=[B{1,1}];
% figure;subplot(1,2,1);imshow(Img,[]),title('Original Im');
% subplot(1,2,2);imshow(Img,[]);hold on;plot(contourB(:,2),contourB(:,1),'g');
% title('LevelSet segment(Our)+Sorf');