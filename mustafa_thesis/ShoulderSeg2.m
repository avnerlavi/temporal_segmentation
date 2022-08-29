% clear all;
% %tear segment
% num=11;
% Path=['C:\Users\97254\Documents\MATLAB\thesis\Images\ShoulderPartialTear',num2str(num)];
% Format='jpg';
% % G=load('BW11.mat');
% % seg=G.BW11;
% % seg=TendonSegment;
% I=imread([Path,'.',Format]);
% C=rgb2gray(I);
% ImC=imresize(C,[256 256]);
% % seg=imresize(seg,[256 256]);
% % segment=double(seg);
% % % segment(segment==0)=nan;
% % ImSeg=segment.*double(ImC);
% 
% [gradThresh,numIter] = imdiffuseest(ImC,'ConductionMethod','quadratic');
% SegFiltered = imdiffusefilt(ImC,'ConductionMethod','quadratic', ...
%     'GradientThreshold',gradThresh,'NumberOfIterations',numIter);
% % SegFiltered=double(SegFiltered);
% % SegFiltered(SegFiltered==0)=nan;
% % IMsceltot=facilation(SegFiltered);
% figure;imshow(ImC)
% figure;imshow(SegFiltered)
% %%
% se1=strel('disk',1);
% B1=imdilate(segment,se1);
% B2=imerode(segment,se1);
% B=B1-B2;
% ImBorder=double(ImC)+B*255;
% figure;imshow(ImBorder,[])
% 
% SegFilteredUint8=uint8(SegFiltered);
% imwrite(SegFilteredUint8,['C:\Users\97254\Documents\MATLAB\thesis\Images\FilteredIm\FiltSeg',num2str(num),'.jpg']); % Save as PNG to avoid jpeg artifacts.
%%
% %Intensity:
% SegFiltered8=uint8(SegFiltered);
% SegFiltered(SegFiltered==0)=nan;
% threshI = multithresh(SegFiltered,8); %thresholding for three regions
% b1=im2bw(SegFiltered/255,threshI(1)/255);
% BWseg1=~b1;
% segment(isnan(segment))=0;
% se=strel('disk',5);
% gg=imerode(segment,se);
% BWseg=BWseg1.*gg;
% Seg=C+uint8(255*BWseg);
% tear1=BWseg;
% se=strel('disk',1);
% figure;subplot(2,1,1);imshow(BWseg,[]);subplot(2,1,2);imshow(Seg,[])
%SORF:
clear all;
%close all;
num=13;
G=load(['C:\Users\97254\Documents\MATLAB\thesis\Images\BW',num2str(num),'.mat']);
seg=G.BW13;
seg=imresize(seg,[256 256]);
segment=double(seg);
PathSeg=['C:\Users\97254\Documents\MATLAB\thesis\Images\FilteredIm\FiltSeg',num2str(num)];
FormatSeg='jpg';
%figure;imshow(C,[])
Im=imread([PathSeg,'.',FormatSeg]);figure;imshow(Im,[])
% [MG, S, TM]=fth(Im,2,[3 3],3);
% figure;subplot(1,2,1);imshow(Im);subplot(1,2,2);imshow(MG,[]);
% title(num2str(num))
Path=['C:\Users\97254\Documents\MATLAB\thesis\Images\ShoulderPartialTear',num2str(num)];
Format='png';
I=imread([Path,'.',Format]);
C=rgb2gray(I);
ImC=imresize(C,[256 256]);
res=[3 5 7 9 11 13 15 17 19 21];
% AlgParamsSeg = AlgorithmParams(PathSeg,res,FormatSeg,ImC,Sorf);
% c=ones(length(res));
% Cnorm=c;
analysis=ImStat(num);
K=analysis(:,6);
C=analysis(:,1);
S=analysis(:,4);
Snorm=S/max(S(:));
Knorm=K/max(K(:));
Cnorm=C/max(C(:));
c=exp(Snorm.*Knorm);
Costnorm=c/max(c(:));
Costnorm=Costnorm.^2;
CCnorm=Costnorm/sum(Costnorm);
% Costnorm2=[1 1 1 0.8 0.7 0.6 0.5 0.4 0.3 0.2];
% CCnorm2=Costnorm2/sum(Costnorm2);
CC=normalize01(CCnorm);
AlgParamsSeg = AlgorithmParams(PathSeg,res,FormatSeg,ImC,CC);
%inImg=AlgParamsSeg.InputImg;
% PathHDR='C:\Users\97254\Documents\MATLAB\thesis\HDR-20200713T211325Z-001\HDR\HistEq\HistEq\Results';
% HDRimg=imread([PathHDR,'\ShoulderPartialTear',num2str(num),'.jpg']);
out=LF3(ImC);
% J = adapthisteq(out,'clipLimit',0.01,'Distribution','rayleigh');
% J=imread('C:\Users\97254\Documents\MATLAB\thesis\HDR-20200713T211325Z-001\HDR\HistEq\HistEq\Results\LF_img11.jpg');
% J=rgb2gray(J);
% figure;imshow(J,[]);JJ=imcrop();
% [m n]=size(JJ);
% segment=imresize(segment,[m n]);
% Iout=segment.*double(JJ);
% AlgParamsSeg.InputImg=abs(Iout+abs(min(Iout(:))));
[Sorf,MultiResSorfRespBmode]  = SorfProcessing(AlgParamsSeg,'gray','gaussian','gaussian','SORF');
SorfSeg=Sorf{1,1};
figure;imagesc(SorfSeg)
%%
se=strel('disk',5);
segment2=imdilate(segment,se);
Sorf=SorfSeg.*segment2;
Sorf(Sorf==0)=nan;
Pos=max(Sorf,0);
PosNaN=segment.*Pos;
Neg=max(-Sorf,0);
Neg2=Neg.*segment;
Neg2(Neg2<1)=nan;
%Statistical features
m=nanmean(Sorf(:));%nanmax(Neg2(:));
s=nanstd(Sorf(:));
e = entropy(Sorf(:));
Contrast=(nanmax(Sorf(:))-nanmin(Sorf(:)))/(nanmax(Sorf(:))+nanmin(Sorf(:)));
k= kurtosis(Sorf(:));
sk=skewness(Sorf(:));
analysis=[Contrast,e,m,s,sk,k];
% T=max(-SorfSeg,th);
% tear2=T.*segment;
a=1;
th=m-sk*s;%to change       % first way- threshold for SORF map
tear2=Neg2>th;
% tearTot=tear2.*tear1;
%figure;imagesc(tear2)
%title(num2str(res))
% [BMEAN,~,~,~] = bwboundaries(tear2);
% figure;imshow(Im);hold on;
% for i=1:length(BMEAN)
%     Cont=BMEAN{i,1};
%     plot(Cont(:,2),Cont(:,1),'r')
% end
%second way level sets of SORF nad Intinsity 
[v ind]=min(CC);
sigma=res(ind);
Im=Im.*uint8(segment2);
[uSORF]=Demo(Neg,2);
[uIntinsity]=Demo(Im,5);
IntinsityA=normalize01(uIntinsity);
SorfA=normalize01(uSORF);
Aold=create_alpha(-SorfA,IntinsityA);
% alpha=0.9;
% u=-alpha*uSORF+(1-alpha)*uIntinsity;figure;imagesc(u)
A=normalize01(Aold);
[UU]=Demo(A,5);
%thresh=opthr(U);
thresh=0;
BW=~imbinarize(UU,thresh);
figure;imagesc(BW)
L=bwlabel(BW,4);figure;imagesc(L)
%%
%segmentation
num=[4];
labold=ismember(L,num);
labold=imfill(labold,'holes');
seLab=strel('disk',3);
lab=imopen(labold,seLab);
Llab=bwlabel(lab,4);
figure;imshow(Llab,[])
%%
numlab=1;
targetLab=ismember(Llab,numlab);
[Bu,L,N,A] = bwboundaries(targetLab);
figure;imshow(Im)
for i=1:N
    Cont=Bu{i,1};
    hold on;plot(Cont(:,2),Cont(:,1),'r')
end

% SEborder=strel('disk',1);
% out=imdilate(openingBWu,SEborder);in=imerode(openingBWu,SEborder);
% border=out-in;
% figure;imshow(ImC+uint8(255*border),[]);

%%
%Opening;
tearTot=Sorf<0;
%tearTot=tear2;
Jerode=bwareaopen(tearTot,50);
Jerode=imfill(Jerode,'hole');
% imwrite(Jerode,['C:\Users\97254\Documents\MATLAB\thesis\Images\ShoulderSeg\BinaryMap',num2str(num),'-3res',num2str(res),'.png']); % Save as PNG to avoid jpeg artifacts.
Im=imread([PathSeg,'.',FormatSeg]);
Mix=double(uint8(Jerode).*Im);
% Mix(Mix==0)=nan;
[MG, S, TM]=fth(Mix,3,[4 3],3);
BWW=MG==2;
seBWW=strel('disk',1);
BWWafterOP1=imclose(Jerode,seBWW);
seBWW2=strel('disk',1);
BWWafterOP=imopen(BWWafterOP1,seBWW2);
%Border:
% seB=strel('disk',1);
% dil=imdilate(Jerode,seB);er=imerode(Jerode,seB);
% Border=dil-er;
% imageBorder=Im+uint8(255*Border);
[B,L,N,A] = bwboundaries(BWWafterOP);
figure;imshow(Im);hold on;
for i=1:length(B)
    Cont=B{i,1};
    plot(Cont(:,2),Cont(:,1),'r')
end
title('Tear Segmentation')
figure;imshow(Im);title('Tendon')

% imwrite(imageBorder,['C:\Users\97254\Documents\MATLAB\thesis\Images\ShoulderSeg\Border',num2str(num),'-3res',num2str(res),'.png']); % Save as PNG to avoid jpeg artifacts.
labels=bwlabel(BWWafterOP,4);
grayImage=Im;
measurements=regionprops(labels,grayImage, 'WeightedCentroid');
% A=mean([stats.Area]);
% idx=find([stats.Area]>A);
% Centers={stats.Centroid};
figure;imshow(grayImage,[]);hold on;
for i=1:length(measurements)
    centerOfMass = [measurements.WeightedCentroid];
    R=reshape(centerOfMass,[2 4]);
    plot(R(1,i),R(2,i),'*r')
end
%%
%R-G with SORF:
x=110;
y=165;%to change
range_th=(max(Neg(:))-min(Neg(:)))/10;
J=regiongrowing(double(Im),x,y,range_th);
J=imfill(J,'holes');
[B,L,N,A] = bwboundaries(J);
Cont=B{1,1};
figure;imshow(Im,[]);hold on;plot(Cont(:,2),Cont(:,1),'r')
figure;imagesc(J)
%%
%R-G:
num=11;
Path=['C:\Users\97254\Documents\MATLAB\thesis\Images\ShoulderPartialTear',num2str(num)];
Format='png';
I=imread([Path,'.',Format]);
C=rgb2gray(I);
ImC=imresize(I,[256 256]);
alpha=0.6;
max_range=(max(Neg2(:))*alpha);
initial_mask=Neg2>max_range;
% measurements = regionprops(initial_mask, 'Centroid');
% centroids = [measurements.Centroid];
% xCentroids = centroids(1:2:end);
% yCentroids = centroids(2:2:end);
% AlgParamsSeg.InputImgC=ImC;
I=double(Im);
range_th=10;
J=zeros(256,256);
j=1;
for L=1:length(idx)
    i=idx(L);
    coor=Centers{i};
%     J=regiongrowing(I,round(coor(2)-2),round(coor(1)-2),res)+J;
    J(:,:,j)=regiongrowing(I,round(coor(2)-2),round(coor(1)-2),range_th);
    Ij=J(:,:,j);
    JJ=imfill(Ij,'holes');
    seJ=strel('disk',3);
    JJafter=imopen(JJ,seJ);
    [B,L,N,A] = bwboundaries(JJafter);Cont1=B{1};%boundary
    figure;imshow(ImC+uint8(255*JJafter),[]);
    figure;imshow(ImC,[]);
    hold on;
    plot(Cont1(:,2),Cont1(:,1),'r')
    j=j+1;
end

%J=regiongrowing(I,round(yCentroids(2)),round(xCentroids(2)),res);
% JJ=imfill(J,'holes');
% [B,L,N,A] = bwboundaries(JJ);Cont1=B{1};
% figure;imshow(JJ,[]);
% figure;imshow(ImC+uint8(255*JJ),[]);
% figure;imshow(ImC,[]);
% hold on;
% plot(Cont1(:,2),Cont1(:,1),'r')
%%
%level-set:
for L=1:length(idx)
    i=idx(L);
    SP=Centers{i};
    [AreaMask EdgeMask ImgWithEdge] = ActivContSeg(AlgParamsSeg,BWWafterOP,[centerOfMass(2)-5 centerOfMass(1)+3]);
end
%%
function f=normalize01(f)
% Normalize to the range of [0,1]

fmin  = min(f(:));
fmax  = max(f(:));
f = (f-fmin)/(fmax-fmin);  % Normalize f to the range [0,1]
end
%%
%Dividing Image:
% W=16;
% %Blocks=Blocking(Im,W);
% % I = imread('liftingbody.png');
% I=uint8(Im);
% S = qtdecomp(I,0.25);
% blocks = repmat(uint8(0),size(S));
% 
% for dim = [64 32 16  8 4 2 1] 
%   numblocks = length(find(S==dim));    
%   if (numblocks > 0)        
%     values = repmat(uint8(1),[dim dim numblocks]);
%     values(2:dim,2:dim,:) = 0;
%     blocks = qtsetblk(blocks,S,dim,values);
%   end
% end
% 
% blocks(end,1:end) = 1;
% blocks(1:end,end) = 1;
% figure;
% imshow(I)
% figure
% imshow(blocks,[])
% figure
% imshow(I+255*blocks,[])


function Blocks=Blocking(Im,W)
    YourImage = im2double(Im);
    [m,n] = size(YourImage);
    Blocks = cell(m/W,n/W);
    counti = 0;
    for i = 1:W:m-W-1
       counti = counti + 1;
       countj = 0;
       for j = 1:W:m-W-1
            countj = countj + 1;
            Blocks{counti,countj} = YourImage(i:i+W-1,j:j+W-1);
       end
    end
end
%%
% fun = @(block_struct) ...
%    std2(block_struct.data) * ones(size(block_struct.data));
% I3 = blockproc(Im,[2 2],fun);
% figure;imshow(I3,[])
