function [tmp,IMsceltot]=facilation(inImg)
LDR=1;
if size(inImg,3)>1
    Iorginal = rgb2gray(inImg);
else
    Iorginal=inImg;
end
Iorginal = im2double(Iorginal);
inImg = medfilt2(Iorginal,[3 3]);

%%
if size(inImg,3)>1
    IMGhsv=rgb2hsv(inImg);
    I=IMGhsv(:,:,3);   
else
    I=im2double(inImg);
end
%im=rgb2gray(IMG);
%T = adaptthresh(im, 0.6);
%inImg2=im-T;
%dim = ndims(inImg);
%if(dim == 3)
%Input is a color image
%inImg = rgb2gray(inImg);
%end

SS=4;
IMscel=zeros(size(I,1),size(I,2),SS);
IMsceltot=zeros(size(I,1),size(I,2));
theta = [0:30:360];
KK=length(theta);
tic
for j=1:SS
    RSfactorR = round(size(I,1)/max(1,2*(j-1)));
    RSfactorC = round(size(I,2)/max(1,2*(j-1)));
    imgS=imresize(I,[RSfactorR RSfactorC]);
    
    immN=zeros(size(imgS,1),size(imgS,2),KK);
    immP=zeros(size(imgS,1),size(imgS,2),KK);
    LFimmNor=zeros(size(imgS,1),size(imgS,2),KK);
    LFimmPor=zeros(size(imgS,1),size(imgS,2),KK);
    immNor=zeros(size(imgS,1),size(imgS,2));
    immPor=zeros(size(imgS,1),size(imgS,2));
    
    immNor1=zeros(size(imgS,1),size(imgS,2));
    immPor1=zeros(size(imgS,1),size(imgS,2));
    immNor2=zeros(size(imgS,1),size(imgS,2));
    immPor2=zeros(size(imgS,1),size(imgS,2));
     for i=2:KK-1
         
         tat=pi()*(i-1)/KK;
         x=1:25;
         y=1:25;
         x0=13;
         y0=13;
         sig=8;
         lmd=12;
         
         exp1=0;
         L = zeros(size(y,2),size(x,2));
         Lnorm = zeros(size(y,2),size(x,2));
%         
         for x1=1:size(x,2)
             for y1=1:size(y,2)
                 exp1=exp(-((x(x1)-x0)^2/sig^2+(y(y1)-y0).^2/(sig)^2));
                 L(y1,x1)=cos(2*pi/lmd*((x(x1)-x0)*cos(tat)+(y(y1)-y0)*sin(tat))).*exp1;
                 Lnorm(y1,x1)=cos(2*pi/lmd*((x(x1)-x0)*cos(tat)+(y(y1)-y0)*sin(tat)));
             end
         end
         
         Lnorm=imresize(Lnorm,2/3);
         L=imresize(L,2/3);
     
         Lnorm  =conv2(Lnorm,L,'same');
         CONVnorm = Lnorm(ceil(size(L,1)/2),ceil(size(L,1)/2));
         imgO = conv2(imgS,L,'same')/CONVnorm; %THR=0.009
         imgP = max(imgO,0);
         %imgN = max(-imgO,0);
%          THR=max(max(abs(imgO))); %% to change
%          imgP=(imgP>0.05*THR).*imgP;
%          imgN=(imgN>0.05*THR).*imgN;
%%
%Add the orthogonal line;



%%

      for i = [1:length(theta)]
          [J11]=steerGaussFilterOrder1(imgS,theta(i),sig,0);
          imgP = max(J11,0);% image with positive values
          imgN = max(-J11,0);% image with negative values
          THR=max(max(abs(J11))); %% true
          %         
          imgP=(imgP>0.05*THR).*imgP;
          imgN=(imgN>0.05*THR).*imgN;
 %%
 % Add the orthogonal line:
          SEN = strel('line',10,theta(i) -90);
%           new_imgN=imdilate(imgN,SEN); %Orthogonal element 
          new_imgP=imdilate(imgP,SEN); %Orthogonal element
          
 %%
 
          %Fac=max(10,20./j);%aother calculate 
          Fac=1;
          %[LFimmN1 NimNR1] = LFsc(imgN,theta(i),Fac);
          %IblurP = imgaussfilt(imgP,1);
          
%           IblurP=conv2(imgP,L);
          C=max(imgP,imgaussfilt(imgP,1));
          C=imresize(C,size(imgP));
          c_normalized=imgP./(1+C);
          
          [LFimmP1 PimNR1] = LFsc(c_normalized,theta(i),Fac);
          %LFimmN1=0.5*max(0,LFimmN1);
          LFimmP1=max(0,LFimmP1);      
          %immNor1=immNor1+LFimmN1;
          immPor1=immPor1+LFimmP1;
          
%           [LFimmN2 NimNR2] = LFsc(new_imgN,theta(i)-90,Fac);
          [LFimmP2 PimNR2] = LFsc(new_imgP,theta(i)-90,Fac);
%           LFimmN2=0.5*max(0,LFimmN2-1*NimNR2);
          LFimmP2=0.5*max(0,LFimmP2-1*PimNR2);      
%           immNor2=immNor2+LFimmN2;
          immPor2=immPor2+LFimmP2;
          %IM2scel =-LFimmN2-LFimmN1+immPor1+immPor2;
          %figure;imshow(IM2scel,[]);
         
          
     end
    IM2scel =-immNor1+immPor1;
    %IM2scel =immPor1;
    IMscel=imresize(IM2scel,[size(I,1) size(I,2)]); %();
    IMscel = IMscel/2.^(j-1);
    
%      figure; imagesc(imgS);colormap gray
% % 
%             figure; imagesc(min(1,max(0,(imgS-immNor/2+immPor/8))));colormap gray
    IMsceltot=IMsceltot+IMscel;
    %figure;imshow(IMsceltot,[])
   
end

toc
maxVal=max(IMsceltot(:));
minVal=max(-1,min(IMsceltot(:)));
IMsceltot=max(IMsceltot,minVal);
IMsceltot=IMsceltot-minVal;
IMsceltot=IMsceltot/maxVal;
%[IMsceltot] = LForg(IMsceltot);
% 
% 
% new_im=zeros(size(IMsceltot));
% for i=0:10:180
%     im=IMsceltot;
%     [out, imNR] = LFsc2(im,i,50);
%     %out=imadjust(out,[],[0 1]);
%     %imNR=imadjust(imNR,[],[0 1]);
%     d=0.5*max(0,out-1*imNR);
%     new_im=new_im+d;
% %     figure;subplot(3,1,1);imshow(out,[]);subplot(3,1,2);imshow(imNR,[]);
% %     subplot(3,1,3);imshow(d,[])
% end
% % IMsceltot=IMsceltot(4:end-3,4:end-3);
% % I=I(4:end-3,4:end-3);
% new_im=new_im/max(new_im(:));
IMsceltot1=0.05*min(0.01*IMsceltot,0.05);%IMsceltot/(KK*SS.^0.5);

% IMsceltot1=0.3*sign(IMsceltot1).*(min(abs(IMsceltot1),1)).^0.5;
tmp=I+IMsceltot1*255;
%%
% figure;
% subplot(1,2,1);
% imshow(I,[]);title('Original')
% % subplot(1,2,2);
% % imshow(IMsceltot,[]);title('Algo')
% 
% out=I+(IMsceltot1>0).*IMsceltot1./max(1,15*(tmp-0.7).^2);
% %+(IMsceltot1<0).*IMsceltot1./(1+5*(tmp<0.1).*(0.1-tmp));%min(0,10*(tmp)))
% 
% out=min(1,max(0,out));
% 
%  if LDR==1
%      out=out.^1.2;
%  end
% subplot(1,2,2);
% imagesc(out);colormap gray
% img=min(1,max(0,img));

% if size(inImg,3)>1
%     IMGhsv(:,:,3)=out;
%     figure; imshow((inImg));
%     A=hsv2rgb(IMGhsv); 
% 
%     figure; imshow(hsv2rgb(IMGhsv));
%     d=(I-A);
%     figure; imshow(d,[]);
% else
%  figure; imagesc(I);colormap gray
%  figure; imagesc(out);colormap gray
% end


%%
% tic
%  for i = [1:length(theta)]
%  J1(:,:,i) = steerGaussFilterOrder1(I,theta(i),sigma,true);
%  end
% toc
% 
% tic
% for i = [1:length(theta)]
% J2(:,:,i) = steerGaussFilterOrder2(I,theta(i),sigma,true);
% end
% toc

%}
%%
% imageSegmenter(IMsceltot);
% c50=0.005;%min(0.5,1/(THR+10^-7)*0.15);
% 
% imNR=IMsceltot.^2./(IMsceltot.^2+c50.^2);%R
%%
% %PCA
% DataMean=mean(IMsceltot);
% [a b]=size(IMsceltot);
% DataMeanNew=repmat(DataMean,a,1);
% DataAdjust=IMsceltot-DataMeanNew;
% covData=cov(DataAdjust);
% [V,D]=eig(covData);
% V_t=V';
% DataAdjust_t=DataAdjust';
% FinalData=V_t*DataAdjust_t;
% OrgData_t=inv(V_t)*FinalData;
% OrgData=OrgData_t'+DataMeanNew;
% %Image Copm
% PCs=input('Enter');
% PCs=b-PCs;
% Reduced_V=V;
% for i=1:PCs
%     Reduced_V(:,1)=[];
% end
% Y=Reduced_V'*DataAdjust_t;
% compData=Reduced_V*Y;
% compData=compData'+DataMeanNew;
figure;imshow(tmp,[]);
end