close all;clear all

num=12;
Path=['C:\Users\97254\Documents\MATLAB\thesis\Images\ShoulderPartialTear',num2str(num)];
Format='png';
I=imread([Path,'.',Format]);
I=double(I(:,:,1));
I=imresize(I,[256 256]);
res=[13 15 17 19];
cost=[1 1 1 1];
AlgParams= AlgorithmParams(Path,res,Format,I,cost);
[Sorf,MultiResSorfRespBmode]  = SorfProcessing(AlgParams,'gray','gaussian','gaussian','SORF');
II=AlgParams.InputImg;
% numIter=10;
% FilteredI = imdiffusefilt(II,'ConductionMethod','quadratic','NumberOfIterations',numIter);
S=Sorf{1,1};
POS=max(0,S);
m=mean(POS(:));
s=std(POS(:));
alpha=-0.5;
th=m-alpha*s;
P=max(th,POS);
P(P==th)=0;
figure;imshow(P,[])

%CCA
for i=1:1:5
    if i==1
        SE(i)=strel('disk',i);
        
    else  
        SE(i)=strel('disk',i);
        Dilation=imdilate(P,SE(i));
        Erosion=imerode(P,SE(i));
        A=Dilation-Erosion;
        Aerode=imerode(A,SE(i-1));
    end
end
Aerode=Aerode/length(SE);

% level = graythresh(P);
% BW = imbinarize(P,level);
% MIX=double(BW).*P;
% sigma=50;
% [u]=Demo(P,sigma);