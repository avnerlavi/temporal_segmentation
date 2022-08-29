close all;clear all
%New tear Segmenattion 
Path='C:\Users\97254\Documents\MATLAB\thesis\Images\ShoulderPartialTear3';

Format='jpg';
res=[3];
AlgParams = AlgorithmParams(Path,res,Format);
varargout = SorfProcessing(AlgParams,'gray','gaussian','gaussian','SORF');
se=strel('disk',5);
   
% k=imopen(P,se);
% T2=opthr(k);
% BinaryIm=k>abs(T2);
% Iblur = imgaussfilt(double(BinaryIm),7);
% T22=opthr(Iblur);
% BinaryIm2=Iblur>T22;
T = adaptthresh(P);
BWP = imbinarize(P,T);
%%
seSlim=strel('disk',1);
BWPerode=imerode(BWP,seSlim);
% figure;imshow(BWPerode)

%features:
Prop=regionprops(BWPerode, 'All');   % Get the blob properties of 'Area'
% F1=[Prop.MajorAxisLength];
F2=[Prop.Area];
CC=bwlabel(BWPerode);

% % A=F2(F2>=median(F2));
% Alen=length(A);
% iA=zeros(1,Alen);
% for a=1:Alen
%     iA(a)=find(F2==A(a));
% end
H=bwareaopen(BWPerode,round(mean(F2)));
propMajor=regionprops(H, 'All');
% F1=[propMajor.MajorAxisLength];
% % A=maxk(F2,4);
% % i12=find(F2==A(1));i22=find(F2==A(2));i32=find(F2==A(3));i42=find(F2==A(4));
% % iA=[i12,i32,i32,i42];
% X=maxk(F1,5);
% for major=1:Alen
%     iMajor(major)=find(F1==X(major));
% end
% i1=find(F1==X(1));i2=find(F1==X(2));i3=find(F1==X(3));i4=find(F1==X(4));
% iMajor=[i1 i2 i3 i4];

% i= intersect(iMajor,iA);
% lenInd=length(i);
% high=zeros(1,lenInd);
% for n=1:lenInd
%     high(n)=Prop(i(n)).Centroid(2);
%     width(n)=Prop(i(n)).Centroid(1);
% end
% 
% H=maxk(high,2);
% ind1=find(high==H(1));
% ind2=find(high==H(2));
% line1=i(ind1);
% line2=i(ind2);
%%
[m,n]=size(H);
center=[round(m/2) round(n/2)];
HC=bwlabel(H,4);
% BWareas=ismember(HC,iMajor);
[CCarea,numLabel]=bwlabel(H,4);
PropArea=regionprops(CCarea, 'All');   % Get the blob properties of 'Area'
X=zeros(1,numLabel);
Y=zeros(1,numLabel);
DistancePoints=zeros(1,numLabel);

for n=1:numLabel
    X(n)=PropArea(n).Centroid(2);
    Y(n)=PropArea(n).Centroid(1);
    
    DistancePoints(n)=sqrt((X(n) - center(1))^2 + (Y(n) - center(2))^2);
end
th=size(H,1)/2;
CenterLabel=DistancePoints(DistancePoints<th);
CenterLabelInd=zeros(1,length(CenterLabel));
for CenterLabeI=1:length(CenterLabel)
    CenterLabelInd(CenterLabeI)=find(DistancePoints==CenterLabel(CenterLabeI));
end
Labels=ismember(CCarea,CenterLabelInd);
PH=uint8(P.*double(Labels));
PD=double(PH);
% PD(PD==0)=nan;
T2=opthr(PD);
Hnoise=PD>abs(T2);

%noise reduce()
Propnoise=regionprops(Hnoise, 'All');   % Get the blob properties of 'Area'
noiseArea=[Propnoise.Area];
Binary=bwareaopen(Hnoise,200);

% %%
% %Area
% % l1=ismember(CC,i1);
% % l2=ismember(CC,i2);
% % l3=ismember(CC,i3);
% % l4=ismember(CC,i4);
% % l=l1+l2+l3+l4;
% 
% l1=ismember(CC,line1);
% l2=ismember(CC,line2);
% l=l1+l2;
% figure;imshow(l)
% %
% %error of the another area
% ls1=bwskel(l1,'MinBranchLength',200);
% ls2=bwskel(l2,'MinBranchLength',200);
% skel=ls1+ls2;
% figure;imshow(skel)
% signalCol=skel(:,round(size(skel,2)/2));
% OnesPeak= find(signalCol==1);
% if (length(OnesPeak)>2)
%     if(H(1)>H(2))
%         l=l1;
%     else
%         l=l2;
%     end
% end
%%
%segment:
m=1;
l=Binary;
[row col]=size(l);
Dif=zeros(row,col,9);
for n=10:10:200
    se=strel('disk',n);
    seg(:,:,m)=imclose(l,se);
%     figure;imshow(seg(:,:,m));
    if (m>1)
        Dif(:,:,m-1)=abs(seg(:,:,m)-seg(:,:,m-1));
        D=Dif(:,:,m-1);
        DifVal(m)=mean(D(:));
%         figure;imshow(D,[]);
    end
    m=m+1;
end
change=diff(DifVal);
SmoothChange=smooth(change,20); 
firstChange=find(SmoothChange==min(SmoothChange));
% firstChange=find(change==min(change))+3;
TendonSegment=seg(:,:,5);%% To Change.
figure;imshow(TendonSegment,[])
%%
% %tear analysis:
% seg=TendonSegment;
% I=imread([Path,'.',Format]);
% C=rgb2gray(I);
% Im=imresize(C,[256 256]);
% segment=double(seg);
% % segment(segment==0)=nan;
% ImSeg=uint8(double(Im).*segment);
% 
% [gradThresh,numIter] = imdiffuseest(ImSeg,'ConductionMethod','quadratic');
% SegFiltered = imdiffusefilt(ImSeg,'ConductionMethod','quadratic', ...
%     'GradientThreshold',gradThresh,'NumberOfIterations',numIter);
% SegFiltered=double(SegFiltered);
% SegFiltered(SegFiltered==0)=nan;
% 
% se1=strel('disk',1);
% B1=imdilate(segment,se1);
% B2=imerode(segment,se1);
% B=B1-B2;
% ImBorder=double(C)+B*255;
% figure;imshow(ImBorder,[])
% num=5;
% SegFilteredUint8=uint8(SegFiltered);
% imwrite(SegFilteredUint8,['C:\Users\hedva\Documents\MATLAB\Mustafa\teza-20191126T102427Z-001\teza\ForTalShaul\ShoulderIm\ShoulderPartialTear',num2str(num),'.png']); % Save as PNG to avoid jpeg artifacts.
% %%
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
% %SORF:
% PathSeg=['C:\Users\hedva\Documents\MATLAB\Mustafa\teza-20191126T102427Z-001\teza\ForTalShaul\ShoulderIm\ShoulderPartialTear',num2str(num)];
% FormatSeg='PNG';
% %figure;imshow(C,[])
% AlgParamsSeg = SetAlgorithmParams2(PathSeg,10,FormatSeg);
% SorfSeg = SorfProcessing(AlgParamsSeg,'gray','gaussian','gaussian','SORF');
% figure;imagesc(SorfSeg)
% 
% SorfSeg(SorfSeg==0)=nan;
% Pos=max(SorfSeg,0);
% PosNaN=segment.*Pos;
% Neg=max(-SorfSeg,0);
% 
% th=20;%to change
% 
% T=max(-SorfSeg,th);
% tear2=T.*segment;
% tear2=tear2>th;
% tearTot=tear2.*tear1;
% figure;imagesc(tearTot)
% 
% %Opening;
% tearTot=imread(['C:\Users\hedva\Documents\MATLAB\Mustafa\teza-20191126T102427Z-001\teza\ForTalShaul\ShoulderIm\BinaryMap',num2str(2),'.png']);
% C=imread('C:\Users\hedva\Documents\MATLAB\Mustafa\teza-20191126T102427Z-001\teza\ShoulderPartialTear2.jpg');
% C=rgb2gray(C);
% SE=strel('disk',5);
% tearTotOpen=imclose(tearTot,SE);
% 
% %imwrite(tearTot,['C:\Users\hedva\Documents\MATLAB\Mustafa\teza-20191126T102427Z-001\teza\ForTalShaul\ShoulderIm\BinaryMap',num2str(num),'.png']); % Save as PNG to avoid jpeg artifacts.
% 
% %Border:
% seB=strel('disk',1);
% dil=imdilate(tearTotOpen,seB);er=imerode(tearTotOpen,seB);
% Border=dil-er;
% imageBorder=C+uint8(255*Border);
% figure;imshow(imageBorder)
% imwrite(imageBorder,['C:\Users\hedva\Documents\MATLAB\Mustafa\teza-20191126T102427Z-001\teza\ForTalShaul\ShoulderIm\Border',num2str(2),'.png']); % Save as PNG to avoid jpeg artifacts.

%%
% AlgParamsSeg = SetAlgorithmParams2(PathSeg,10,FormatSeg);
% SorfSeg = SorfProcessing(AlgParamsSeg,'gray','gaussian','gaussian','SORF');
% % figure;imagesc(SorfSeg.*BWseg)
% u=SorfSeg.*BWseg;
% Z=zeros(size(SorfSeg));
% Z(280:310,200:240)=1;
% u=SorfSeg.*Z;
% u(u==0)=nan;
% figure;imagesc(u)
% % figure;hist(u(:),255)
% nanmean(u(:))
% nanstd(u(:))
% %figure;subplot(2,1,1);imagesc(SegFiltered);subplot(2,1,2);imagesc(SorfSeg);
% th=20;
% T=max(-SorfSeg,th);
% tear=T.*segment;