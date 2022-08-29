%clear all;
close all;


%Load DATA:

% [MG, S, TM]=fth(Im,2,[3 3],3);
num=2;
% Path=['C:\Users\97254\Documents\MATLAB\thesis\dataset\train_images\tear',num2str(num)];
Path=['C:\Users\97254\Documents\MATLAB\thesis\dataset\train_images\img',num2str(num)];
Format='png';
ImC=imread([Path,'.',Format]);
% C=rgb2gray(I);
% ImC=imresize(C,[256 256]);
%imwrite(ImC,['C:\Users\97254\Documents\MATLAB\thesis\ShoulderIm\train_images\img',num2str(num),'.png']);
segment=imread('C:\Users\97254\Documents\MATLAB\thesis\dataset\ROI\Auto\segmen24_2.png');
%imwrite(I,'C:\Users\97254\Documents\MATLAB\thesis\dataset\ROI\SST\img1.png');
%out=LF3(ImC);%LForiginal
% [out,G]=LForiginal(ImC);
% [MG, S, TM]=fth(ImC,3,[2,3],1);
% figure;imshow(MG,[])
% [MG, S, TM]=fth(G,3,[2,3],1);
% figure;imshow(MG,[])
%%
%LF:
out=LF3(ImC);
out=imresize(out,[256 256]);
segment=rgb2gray(segment);
figure;
% segment=imcrop(segment);
segment=imresize(segment(:,:,1),[256 256]);
I=out.*(double(segment./255));

%out=LForiginal(ImC);
%out=ImC;
saveLF=0;
if (saveLF)
    imwrite(out,['C:\Users\97254\Documents\MATLAB\thesis\HDR-20200713T211325Z-001\HDR\HistEq\HistEq\RGB\LF_img',num2str(num),'.jpg'])
end
% AHE:
J = adapthisteq(ImC);

% AD+AHE:
[gradThresh,numIter] = imdiffuseest(ImC,'ConductionMethod','quadratic');
SegFiltered = imdiffusefilt(J,'ConductionMethod','quadratic', ...
    'GradientThreshold',gradThresh,'NumberOfIterations',numIter);



% ACC algo:
% J=imread(['C:\Users\97254\Documents\MATLAB\thesis\HDR-20200713T211325Z-001\HDR\HistEq\HistEq\Results\LF_img',num2str(num),'.jpg']);
% J_Adaptive=imread(['C:\Users\97254\Documents\MATLAB\thesis\HDR-20200713T211325Z-001\HDR\HistEq\HistEq\Results\ref_LF_img',num2str(num),'.jpg']);
% JJ=out;
% [m n]=size(JJ);
% segment=imresize(segment,[m n]);
% se=strel('disk',3);%% depent to ROI segmentation!
% segment2=imdilate(segment,se);
% Iout=double(segment2).*double(JJ);
% [Result2] = NewLSE(Iout);
%% ROI
R = ROI_Tendon(out,num);

%%
%Sorf:
res=[1 3 5 7 9 11 13 15];
%res=[3 5 7 9 11];
analysis=imstat2(out,res);
K=analysis(:,6);
C=analysis(:,1);
S=analysis(:,4);
Snorm=S/max(S(:));
Knorm=K/max(K(:));
Cnorm=C/max(C(:));
c=exp(Snorm);
Costnorm=c.^2;
%CCnorm=Costnorm/sum(Costnorm);
% Costnorm2=[1 1 1 0.8 0.7 0.6 0.5 0.4 0.3 0.2];
% CCnorm2=Costnorm2/sum(Costnorm2);
CC=normalize01(Costnorm);
%JJ=imread(['C:\Users\97254\Documents\MATLAB\thesis\HDR-20200713T211325Z-001\HDR\HistEq\HistEq\RGB\LF_img',num2str(num),'.jpg']);
JJ=I;
[m n]=size(JJ);
segment=imresize(R,[m n]);
se=strel('disk',3);%% depent to ROI segmentation!
%segment=uint8(R);
segment2=imdilate(segment,se);
Iout=double(segment).*double(JJ);
% PathSeg=['C:\Users\97254\Documents\MATLAB\thesis\Images\FilteredIm\FiltSeg',num2str(11)];
% FormatSeg='jpg';
%%
res=[1 3 5 7 9 11 13 15 17 19];
% CC=[0.3,0.3,0.3,0.1];%CC=[1,0.5,0.5,0.3,0.3,0.1,0,0];
analysis=imstat2(out,res);
K=analysis(:,6);
C=analysis(:,1);
S=analysis(:,4);
Snorm=S/max(S(:));
Knorm=K/max(K(:));
Cnorm=C/max(C(:));
c=exp(Snorm.*Knorm);
Costnorm=c.^2;
CC=normalize01(Costnorm);
CC=[1,1,1];
AlgParamsSeg = AlgorithmParams(Path,res,Format,out,CC);
%AlgParamsSeg.InputImg=abs(JJ+abs(min(JJ(:))));
AlgParamsSeg.InputImg=out;
[Sorf,MultiResSorfResp]  = SorfProcessing(AlgParamsSeg,'gray','gaussian','gaussian','SORF');
SorfSeg=Sorf{1,1};figure;imshow(SorfSeg,[])
%imwrite(SorfSeg./255,['C:\Users\97254\Documents\MATLAB\thesis\dataset\Res_LSE\SORF\Im_',num2str(num),'.png']);
%%

S=SorfSeg+abs(min(SorfSeg(:)));
S=S/(max(S(:)));
S=imadjust(S,[],[0 1]);
[ROIp] = NewLSE(SorfSeg*255);
%imwrite(S,['C:\Users\97254\Documents\MATLAB\thesis\SORF_Im\SORFacc',num2str(num),'.jpg'])
%imwrite(S,['C:\Users\97254\Documents\MATLAB\thesis\SORF_Im\SORFadaptHE',num2str(num),'.jpg'])
[u,Img_corrected]=Demo(max(-SorfSeg,0),1);
% [u,Img_corrected]=Demo(I,1);

se_seg=strel('disk',15);
segment_2=imerode(segment,se_seg);
segment_22=double(segment_2);
 figure;imshow(max(-SorfSeg,0).*double(segment_22),[])
segment_22(segment_22==0)=nan;
T=max(0,-u);
thT=min(T,50);
figure;imshow(u.*double(segment_22),[])

figure;imshow(abs(min(thT(:)))-thT.*double(segment_22),[])
%%

%1-segmentation usi adaptngive threshold:
Sseg=SorfSeg.*double(segment_2);%to remove the edges response.
Neg=max(-Sseg,0);

IIout=double(out).*double(segment_2);
[MG1, ~, ~]=fth(out,4,[1,1],1);
figure;imshow(MG1,[])
P=max(SorfSeg,0);
Tear=TearSeg(out,SorfSeg,segment_2);
% imwrite(P,['C:\Useers\97254\Douments\MATLAB\thesis\dataset\train_images2\img',num2str(num),'.png']);
% imwrite(out,['C:\Users\97254\Documents\MATLAB\thesis\dataset\train_images3\img',num2str(num),'.png']);
%% New LSE 22.11.2020:
% [Result1] = NewLSE(Neg);
[Result22] = NewLSE(out*255);
% Result2=Result22.*double(segment./255);

% tear_Sorf=ismember(Result1,[2,3]);% R G B =0.3333;
% tear_intensity=ismember(Result2,[1]);% R G B =0.3333;
% 
% Total=tear_Sorf+tear_intensity;
% th=max(Total(:));
% Tear=(Total==th);

% choose the tear region:

%N=Neg.*double(segment_2);

% TargetSegment = TearRegion(Tear,Neg);
% figure;imshow(TargetSegment,[]);
TargetSegment=Tear;

Im=ImC.*uint8(segment);
ImC=imresize(ImC,[256 256]);
[Bu,L,N,A] = bwboundaries(TargetSegment);
figure;imshow(ImC)
for i=1:N
    Cont=Bu{i,1};
    hold on;plot(Cont(:,2),Cont(:,1),'c')
end

% saveas(gcf,['C:\Users\97254\Documents\MATLAB\thesis\dataset\Results_Algo\segment',num2str(num),'_2.png']);
% imwrite(TargetSegment,['C:\Users\97254\Documents\MATLAB\thesis\dataset\Results_Algo\Label',num2str(num),'_2.png']);

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% error metrics
close all;
AutoSeg=double(imread('C:\Users\97254\Documents\MATLAB\thesis\dataset\ROI\AUTO2\Mask24.png'));
AutoSeg=imfill(AutoSeg,'holes');
ManuSeg=double(imread('C:\Users\97254\Documents\MATLAB\thesis\dataset\ROI\manual\img24_2.png'));
if (max(ManuSeg)==255)
    ManuSeg=ManuSeg./255;
end
ManuSeg=imresize(ManuSeg,[256,256]);
[Q,AutoSeg_fix] = ErrMetrics(AutoSeg,ManuSeg);

[HausDist MeanDist HausDistNorm MeanDistNorm] = HausdorffDist(AutoSeg,ManuSeg,0);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
Neg2(Neg2==0)=nan;
%Statistical features
m=nanmean(Neg2(:));%nanmax(Neg2(:));
s=nanstd(Neg2(:));
e = entropy(Neg2(:));
Contrast=(nanmax(Neg2(:))-nanmin(Neg2(:)))/(nanmax(Neg2(:))+nanmin(Neg2(:)));
k= kurtosis(Neg2(:));
sk=skewness(Neg2(:));
analysis=[Contrast,e,m,s,sk,k];
% T=max(-SorfSeg,th);
% tear2=T.*segment;
a=1;
th=m+sk*s;%to change       % first way- threshold for SORF map
tear2=Neg2>th;
props1 = regionprops(tear2, 'Area','centroid'); 
centroids = cat(1, props1.Centroid);
Area1=[props1.Area];
bigArea = max(Area1);
bigInd=find(Area1==bigArea);
targetLabel=centroids(bigInd,:);
%2-level sets of SORF nad Intinsity 
[v ind]=min(CC);
sigma=res(ind);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Neg3=Neg.*double(segment);%tear probability. 
%[u,LabB]=Demo(Iout,1);
[uSORF]=Demo(Neg,1);
[uIntinsity]=Demo(out,1);%5 1 3
IntinsityA=normalize01(uIntinsity);
SorfA=normalize01(uSORF);
SorfC=imcomplement(SorfA);
Inorm=IntinsityA.*double(segment);%tear probability. 
Snorm=SorfC.*double(segment);%tear probability. 


Aold=create_alpha(Snorm,Inorm);%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A=normalize01(Aold); 
% newA=A-median(A(:));
newA=Aold;
% [uAA]=Demo(Aold,3);
% UU=uAA;
%thresh=opthr(U);
%thresh=-abs(mean(newA(:)));
% thrsh=0;
% BW=double(~imbinarize(UU,thresh));
% BW=BW.*double(segment);
% L=bwlabel(BW,4);figure;imagesc(L)
% %OR
%New=Aold+ZZ2*(max(Aold(:)));
[MG,~, TM]=fth(Aold,4,[3 3],3);
se3=strel('disk',2);
segment3=imerode(segment,se3);
ROIMG=MG.*double(segment3)/255;
%%
SEG1=ismember(ROIMG,[1 2]);
%SEG1=ROIMG==2;
se=strel('disk',3);
BWfinal1=imopen(SEG1,se);

%choose the tears labels
L=bwlabel(BWfinal1,4);
targetLabNew=L==3;

Im=ImC.*uint8(segment2);
%%
num=24;
Path=['C:\Users\97254\Documents\MATLAB\thesis\dataset\train_images\img',num2str(num)];
Format='png';
ImC=imread([Path,'.',Format]);
targetLabNew=imread('C:\Users\97254\Documents\MATLAB\thesis\dataset\Results_Algo\Label124.png');
targetLabNew=imresize(targetLabNew,[256,256]);
[Bu,~,N,~] = bwboundaries(targetLabNew);
figure;imshow(ImC)
for i=1:N
    Cont=Bu{i,1};
    hold on;plot(Cont(:,2),Cont(:,1),'m')
end

targetLabNew=imresize(targetLabNew2,[256,256]);
[Bu,~,N,~] = bwboundaries(targetLabNew);
for i=1:N
    Cont=Bu{i,1};
    hold on;plot(Cont(:,2),Cont(:,1),'m')
end


figure;imshow(ImC)
%%
imwrite(targetLabNew,['C:\Users\97254\Documents\MATLAB\thesis\dataset\Results\Label',num2str(num),'_2.png']);
%%
SEG2=ismember(ROIMG,[1 2 3]);
se=strel('disk',1);
BWfinal2=imclose(SEG2,se);

Im=ImC.*uint8(segment2);

targetLabNew=SEG2;

[Bu,L,N,A] = bwboundaries(AutoSeg_fix);
figure;imshow(ImC)
for i=1:N
    Cont=Bu{i,1};
    hold on;plot(Cont(:,2),Cont(:,1),'m')
end


%%
%Rremove:
E=edge(Neg3);
Z2=zeros(size(E));
for i=1:size(E,2)
    [x y]=find(E(:,i)); 
    if ~(isempty(x) || isempty(y))
        bottom=max(x);
        idx.x(i)=bottom;
        idx.y(i)=i;
        Z2(bottom,i)=1;%bottom  of the bone
    end
end
ZZ2=imdilate(Z2,se);    
remove=imcomplement(ZZ2);
SSS=Final_SEG+ZZ2*(max(Final_SEG(:)));
uAA=Demo(SSS,3);


%%
%newA
N=num;
%newAA=imread('C:\Users\97254\Documents\MATLAB\thesis\Seg_Result\level11.png');
%newA=double(newAA(:,:,1));
%new=min(newA,median(newA(:)));
new=Aold;
se=strel('disk',5);
[m n]=size(new);
% segment=imread(['C:\Users\97254\Documents\MATLAB\thesis\Images\Seg\segment',num2str(N),'.jpg']);
% segment=imresize(segment,[m n]);
segment3=imerode(segment,se);
% prob=new.*double(segment3);
% figure;imshow(prob,[])
Z=zeros(size(new));
for i=1:size(new,2)
    [x y]=find(segment(:,i)); 
    if ~(isempty(x) || isempty(y))
        bottom=max(x);
        Z(bottom,i)=1;
    end
end
se=strel('disk' ,5);
ZZ=imdilate(Z,se);% bottom segment

% SEG=(new<median(new(:))).*double(segment3);
E=edge(Neg3);
Z2=zeros(size(E));
for i=1:size(E,2)
    [x y]=find(E(:,i)); 
    if ~(isempty(x) || isempty(y))
        bottom=max(x);
        idx.x(i)=bottom;
        idx.y(i)=i;
        Z2(bottom,i)=1;%bottom  of the bone
    end
end
ZZ2=imdilate(Z2,se);
remove=imcomplement(ZZ2);
IDX_x=abs(diff(idx.x));
th=mean(IDX_x);
[outliers_x ouliers_y]=find(IDX_x>th);
Val_x=idx.x;
Val_x(outliers_x,ouliers_y)=nan;
Val_y=idx.y;
[Seg_x Seg_y]=find(Z==1);

for k=1:numel(Val_y)
  [ii]=find(Seg_y==Val_y(k));
  if ~isempty(ii)
    dis(k)=abs(Val_x(k)-Seg_x(ii));
  end
end

TOT=SEG+ZZ;
kernel=min(round(nanmedian(dis)),round(nanmean(dis)));
se=strel('disk',kernel+3);%to change
thin_edge1=~(imdilate(ZZ,se));
thin_edge2=(imdilate(ZZ,se));
thin_edge2(thin_edge2==1)=median(newA(:));
NEW=thin_edge1.*new;
FinalNew=thin_edge2+NEW;
%[FinalNewseg,L]=Demo(FinalNew,3);%to change the sigma
%imwrite(uint8(FinalNewseg),['C:\Users\97254\Documentus\MATLAB\thesis\Seg_Result\SegmenMap',num2str(N),'.jpg'])
%NEW(NEW==0)=median(newA(:));
% 
eps=round(double(segment3.*uint8(thin_edge1))/255);
TOTfinal=(FinalNew.*eps)>0;

props = regionprops(TOTfinal, 'Area'); 
Area=[props.Area];
LB = min(Area);
UB = max(Area);
Iout = xor(bwareaopen(TOTfinal,LB),  bwareaopen(TOTfinal,UB));
figure, imshow(Iout);
%%
%segmentation
labold=TOTfinal;
labold=imfill(labold,'holes');
seLab=strel('disk',1);
lab=imopen(labold,seLab);
Llab=bwlabel(lab,4);
figure;imshow(Llab,[])
props = regionprops(labold,'centroid'); 
centroidsFin = cat(1, props.Centroid);
diff_Cen=sqrt((centroidsFin(:,1)-targetLabel(:,1)).^2+(centroidsFin(:,2)-targetLabel(:,2)).^2);
Target_Cen=find(diff_Cen==min(diff_Cen));
%%
%choose the tears labels
Llab=bwlabel(Final_SEG,4);
numlab=0;
ImC;%=ImC.*uint8(segment2);
targetLab=ismember(Llab,numlab);
[Bu,L,N,~] = bwboundaries(AutoSeg);
[Bu2,L2,N,A] = bwboundaries(ManuSeg);

figure;imshow(ImC)
for i=1:N
    Cont2=Bu2{i,1};
    Cont=Bu{i,1};
    hold on;plot(Cont2(:,2),Cont2(:,1),'y');plot(Cont(:,2),Cont(:,1),'g')
end
%imwrite(targetLab,['C:\Users\97254\Documents\MATLAB\thesis\dataset\Results\LabelO',num2str(num),'.png']);
%saveas(gcf,['C:\Users\97254\Documents\MATLAB\thesis\dataset\Results\segmentO',num2str(num),'.png']);

%%
AutoSeg=double(imread('C:\Users\97254\Documents\MATLAB\thesis\dataset\Results_Algo\Label2.png'));
% AutoSeg=double(imread('C:\Users\97254\Documents\MATLAB\thesis\dataset\ROI\Auto\segmen9.png'));
ManuSeg=double(imread('C:\Users\97254\Documents\MATLAB\thesis\dataset\Results_Algo\Label2.png'));
ManuSeg=imresize(ManuSeg,[256,256]);AutoSeg=imresize(AutoSeg,[256,256]);
ManuSeg=double(ManuSeg>0);
AutoSeg=double(AutoSeg>0);

% if (max(ManuSeg==255))is\dataset\G.T\Mask\Label29new.png
%     ManuSeg=ManuSeg./255;
% end
% ManuSeg(ManuSeg<1)=0;
[Q,AutoSeg_fix] = ErrMetrics(AutoSeg,ManuSeg);
%%
I=imread('C:\Users\97254\Desktop\tear6.png');
M=255-(I(:,:,1)-I(:,:,3));
BW=imbinarize(M);
BW2=imfill(~BW,'holes');
Label=bwlabel(BW2,4);
Final_Lab=Label>0;
figure;imshow(Final_Lab,[]);
% imwrite(Final_Lab,'C:\Users\97254\Documents\MATLAB\thesis\dataset\G.T\Mask\Label_29new.png');