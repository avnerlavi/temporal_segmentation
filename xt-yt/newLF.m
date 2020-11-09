%code of the LF with steerable and new version of LF:
close all;clear all;
tic
%IMG = imread('C:\Users\97254\Documents\MATLAB\thesis\Images\ShoulderPartialTear1.jpg');
IMG=rgb2gray(imread('Lenna.png'));
%IMG=out;
if size(IMG,3)>1
    IMGhsv=rgb2hsv(IMG);
    img=IMGhsv(:,:,3);   
else
    img=im2double(IMG);
end
SS=4;
IMscel=zeros(size(img,1),size(img,2),SS);
IMsceltot=zeros(size(img,1),size(img,2));

for j=1:SS
    %%
    RSfactorR = round(size(img,1)/max(1,2*(j-1)));
    RSfactorC = round(size(img,2)/max(1,2*(j-1)));
    
    imgS=imresize(img,[RSfactorR RSfactorC]);
    theta=0:30:150;
    KK=length(theta);
    
    LFimmNor=zeros(size(imgS,1),size(imgS,2),KK);
    LFimmPor=zeros(size(imgS,1),size(imgS,2),KK);
    immNor=zeros(size(imgS,1),size(imgS,2));
    immPor=zeros(size(imgS,1),size(imgS,2));
    
    J1=zeros(size(imgS,1),size(imgS,2),length(theta));
    J2=zeros(size(imgS,1),size(imgS,2),length(theta));
    J=zeros(size(imgS,1),size(imgS,2),length(theta));
    P=zeros(size(imgS,1),size(imgS,2),length(theta));
    N=zeros(size(imgS,1),size(imgS,2),length(theta));

    sigma=0.75;
    
    for i =1:KK
    J1(:,:,i) = steerGaussFilterOrder1(imgS,theta(i),sigma,true);
    J2(:,:,i) = steerGaussFilterOrder2(imgS,theta(i),sigma,true);
    J(:,:,i)=J1(:,:,i)+J2(:,:,i);
    P(:,:,i)=max(J(:,:,i),0);
    N(:,:,i)=max(-J(:,:,i),0);
     
    THR(i)=max(max(abs(J(:,:,i))));
    P(:,:,i)=(P(:,:,i)>0.05*THR(i)).*P(:,:,i);
    N(:,:,i)=(N(:,:,i)>0.05*THR(i)).*N(:,:,i);
     
     %Fac=max(5,20./j);
    Fac=1;
    tat=theta(i)/180;
    [LFimmN NimNR] = LFsc2(N(:,:,i),tat,Fac);%change the LFsc func
    [LFimmP PimNR] = LFsc2(P(:,:,i),tat,Fac);

    LFimmN=0.5*max(0,LFimmN-1*NimNR);
    LFimmP=0.5*max(0,LFimmP-1*PimNR);
     
    immNor=immNor+LFimmN;
    immPor=immPor+LFimmP;
%     figure;imshow(immPor,[])
    end
    IM2scel =-immNor+immPor;
    
    IMscel(:,:,j)=imresize(IM2scel,[size(img,1) size(img,2)]); %();

    IMscel(:,:,j) = IMscel(:,:,j)/2.^(j-1);
%     if (j>1)
%         IMscel(:,:,j)=IMscel(:,:,j).^0.8;
%     end


%      figure; imagesc(imgS);colormap gray
% % 
%     figure; imagesc(min(1,max(0,(imgS-immNor/2+immPor/8))));colormap gray
     IMsceltot=IMsceltot+IMscel(:,:,j);
end
IMsceltot1=IMsceltot;
%IMsceltot1=IMsceltot/(KK*SS.^0.5);
%IMsceltot1=0.3*sign(IMsceltot).*(min(abs(IMsceltot),1)).^0.5;
IMsceltot1=0.25*IMsceltot1/(max(abs(IMsceltot1(:))));
tmp=img+IMsceltot1;
outF=img+(IMsceltot1>0).*IMsceltot1./max(1,15*(tmp-0.7).^2)+(IMsceltot1<0).*IMsceltot1./(1+5*(tmp<0.1).*(0.1-tmp));%min(0,10*(tmp)))
outFin=min(1,max(0,outF));
%figure;subplot(1,2,1);imshow(img,[]);subplot(1,2,2);imshow(outFin,[])

figure;subplot(1,2,1);imshow(IMG,[]);title('Before');subplot(1,2,2);imshow(outFin,[]);title('After');

% %added for RGB display
% if size(IMG,3)>1
%     IMGhsv(:,:,3)=outFin;
%     A=hsv2rgb(IMGhsv); 
% 
%     %figure; imshow(hsv2rgb(IMGhsv));
% end
