
close all;
clear all;
for num=1
    if ((num~=5))
        Path=['C:\Users\97254\Documents\MATLAB\thesis\Images\ShoulderPartialTear',num2str(num)];
        Format='jpg';
        AlgParams = SetAlgorithmParams2(Path,10,Format);
        SORF = SorfProcessing(AlgParams,'gray','gaussian','gaussian','SORF');
        N=max(0,-SORF);P=max(0,SORF);
        figure;subplot(1,2,1);imagesc(N);title('Neg');subplot(1,2,2);imagesc(P);title('Pos')
    end
end

[m,n]=size(SORF);
center=[round(m/2) round(n/2)];
% S = stdfilt(P,ones(15));
% Sim = rescale(S);
% T2=opthr(Sim);
% BinaryIm=Sim>abs(T2);
% figure;imagesc(BinaryIm);
T=opthr(P);
BinaryIm2=P>abs(T);

Contrast=(max(SORF(:))-min(SORF(:)))/(max(SORF(:))+min(SORF(:)))
% % J=medfilt2(P,[9 9]);
% % % L=(log(P+1));
% % 
% % T2=opthr(J);
% % BinaryIm=J>abs(T2);
%  figure;imagesc(SORF);
% % 
% se=strel('disk',5);
% BinaryImOpen=imclose(BinaryIm,se);
% figure;imagesc(BinaryImOpen);
% se2=strel('disk',15);
% BinaryImOpen2=imclose(BinaryImOpen,se2);
% % figure;imagesc(BinaryImOpen2);
 BinaryIm2(1:50,:)=0;

%%
[CC,numLabel]=bwlabel(BinaryIm2,4);
Prop=regionprops(CC, 'All');   % Get the blob properties of 'Area'
X=zeros(1,numLabel);
Y=zeros(1,numLabel);
DistancePoints=zeros(1,numLabel);


for n=1:numLabel
    X(n)=Prop(n).Centroid(2);
    Y(n)=Prop(n).Centroid(1);
    
    DistancePoints(n)=sqrt((X(n) - center(1))^2 + (Y(n) - center(2))^2);
end
th=size(SORF,1)/4;
CenterLabel=DistancePoints(DistancePoints<th);
CenterLabelInd=zeros(1,length(CenterLabel));
for CenterLabeI=1:length(CenterLabel)
    CenterLabelInd(CenterLabeI)=find(DistancePoints==CenterLabel(CenterLabeI));
end
Labels=ismember(CC,CenterLabelInd);
se=strel('disk',3);
LabelsFinalbefore=imopen(Labels,se);

%Small Area:
Propsmall=regionprops(LabelsFinalbefore, 'All');   % Get the blob properties of 'Area'
area=[Propsmall.Area];
LabelsFinal=bwareaopen(LabelsFinalbefore,round(mean(area)));%%%%
% LabelsFinal=LabelsFinalbefore;
%segment:
m=1;
[row col]=size(LabelsFinal);
Dif=zeros(row,col,9);
for n=10:10:200
    se=strel('disk',n);
    seg(:,:,m)=imclose(LabelsFinal,se);
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
TendonSegment=seg(:,:,15);%%%%%% convergence index
I=imread([Path,'.',Format]);
C=imresize(rgb2gray(I),[256 256]);

segment=double(TendonSegment);
% segment(segment==0)=nan;
ImSeg=uint8(double(C).*segment);
figure;imagesc(ImSeg);
