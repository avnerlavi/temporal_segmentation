
close all
%   IMG=imread('D:\hava\LFrealIMG\bwt\swan.jpg');
%   IMG=imread('D:\hava\LFrealIMG\bwt\looking-at-bridge.jpg');
IMG=imread('C:\Users\97254\Pictures\girl.PNG');
%  IMG=imread('D:\hava\LFrealIMG\bwt\fog_bridge_golden_gate_san_fransisc.jpg');
%    IMG=imread('D:\hava\LFrealIMG\bwt\fog-house-2.jpg');
%   IMG=imread('D:\hava\LFrealIMG\bwt\view-of-ahthibung-town-from-heichal-shlomo_0.jpg');

%       IMG=imread('D:\hava\LFrealIMG\bwt\san_fran.jpg');
      %IMG=imread('D:\hava\LFrealIMG\bwt\a-foggy-view-of-machu-picchu1.jpg');
    
%      
%         IMG=imresize(IMG,3);
% 
%     H = fspecial('disk',4);
%     IMG = 0.5*IMG+0.5*imfilter(IMG,H,'replicate');
%   IMG=imresize(IMG,0.3);
%   

%     
%    IMG=imcrop(IMG,[]);
%  IMG=IMG*0.8+30;
  LDR=0;

if size(IMG,3)>1
    IMGhsv=rgb2hsv(IMG);
    img=IMGhsv(:,:,3);   
else
    img=im2double(IMG);
end


% img=im2double((IMG(:,:,1)));

% H = fspecial('disk',4);
%   img = 0.5*img+ 0.5*imfilter(img,H,'replicate');


% img=imresize(img,2);

% figure;
% imagesc(img);colormap gray; title('lena');
%
% img2=[repmat(img(:,1)',160,1)',img, repmat(img(:,end)',160,1)'];
% img2=[repmat(img2(1,:),160,1);img2; repmat(img2(end,:),160,1)];
KK=8;
SS=4;

IMscel=zeros(size(img,1),size(img,2),SS);
IMsceltot=zeros(size(img,1),size(img,2));


for j=1:SS
    %%
    
    
    
    RSfactorR = round(size(img,1)/max(1,2*(j-1)));
    
    RSfactorC = round(size(img,2)/max(1,2*(j-1)));
    
    imgS=imresize(img,[RSfactorR RSfactorC]);
    
    immN=zeros(size(imgS,1),size(imgS,2),KK);
    immP=zeros(size(imgS,1),size(imgS,2),KK);
    LFimmNor=zeros(size(imgS,1),size(imgS,2),KK);
    LFimmPor=zeros(size(imgS,1),size(imgS,2),KK);
    immNor=zeros(size(imgS,1),size(imgS,2));
    immPor=zeros(size(imgS,1),size(imgS,2));
    tic
    for i=1:KK
        
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
        
        for x1=1:size(x,2)
            for y1=1:size(y,2)
                exp1=exp(-((x(x1)-x0)^2/sig^2+(y(y1)-y0).^2/(sig)^2));
                L(y1,x1)=cos(2*pi/lmd*((x(x1)-x0)*cos(tat)+(y(y1)-y0)*sin(tat))).*exp1;
                Lnorm(y1,x1)=cos(2*pi/lmd*((x(x1)-x0)*cos(tat)+(y(y1)-y0)*sin(tat)));
            end
        end
        
        
        Lnorm=imresize(Lnorm,1/5);
        L=imresize(L,1/5);
        
        
        Lnorm  =conv2(Lnorm,L,'same');
        CONVnorm = Lnorm(ceil(size(L,1)/2),ceil(size(L,1)/2));
        
        
        
        imgO = conv2(imgS,L,'same')/CONVnorm; %THR=0.009
        imgP = max(imgO,0);
        imgN = max(-imgO,0);
        
        THR=max(max(abs(imgO))); %% to change
%         
        imgP=(imgP>0.05*THR).*imgP;
        imgN=(imgN>0.05*THR).*imgN;
%         imgP=(imgP>0.03).*imgP;
%         imgN=(imgN>0.03).*imgN;
        %
        % imgO2=[repmat(imgO2(:,1)',160,1)',imgO2, repmat(imgO2(:,end)',160,1)'];
        % imgO2=[repmat(imgO2(1,:),160,1);imgO2; repmat(imgO2(end,:),160,1)];
        
        
%         immNtmp = bwmorph(imgN>0.15*THR,'skel',Inf);%(imgN,SE);
%         immPtmp = bwmorph(imgP>0.15*THR,'skel',Inf);%(imgN,SE);
%         
%         
%         immN(:,:,i) = (immNtmp).*imgN;%(imgN,SE);
%         immP(:,:,i) = (immPtmp).*imgP;%(imgN,SE);
%         
%         Fac=min(3,15./j);        
%         [LFimmN NimNR] = LFsc(immN(:,:,i),tat,Fac);
%         [LFimmP PimNR] = LFsc(immP(:,:,i),tat,Fac);

        Fac=max(5,20./j);

        [LFimmN NimNR] = LFsc(imgN,tat,Fac);
        [LFimmP PimNR] = LFsc(imgP,tat,Fac);
        
        
        %  

%          subplot(2,2,1)
% 
%         imagesc(NimNR);colormap gray
%         subplot(2,2,2)
% 
%         imagesc(LFimmN);colormap gray
%                      subplot(2,2,3)
%         imagesc(L);colormap gray


        
%         immNor=immNor+0.5*immN(:,:,i)+max(LFimmN,0.5*immN(:,:,i));
%         
%         immPor=immPor+0.5*immP(:,:,i)+max(LFimmP,0.5*immP(:,:,i));

        LFimmN=0.5*max(0,LFimmN-1*NimNR);
        

        LFimmP=0.5*max(0,LFimmP-1*PimNR);
              
        immNor=immNor+LFimmN;
        
        immPor=immPor+LFimmP;

        
    end
    
    IM2scel =-immNor+immPor;
    IMscel(:,:,j)=imresize(IM2scel,[size(img,1) size(img,2)]); %();
    
    IMscel(:,:,j) = IMscel(:,:,j)/2.^(j-1);
    
%      figure; imagesc(imgS);colormap gray
% % 
%             figure; imagesc(min(1,max(0,(imgS-immNor/2+immPor/8))));colormap gray
IMsceltot=IMsceltot+IMscel(:,:,j);
end

IMsceltot1=0.1*min(0.5*IMsceltot,4);%IMsceltot/(KK*SS.^0.5);

% IMsceltot1=0.3*sign(IMsceltot1).*(min(abs(IMsceltot1),1)).^0.5;

tmp=img+IMsceltot1;

out=img+(IMsceltot1>0).*IMsceltot1./max(1,15*(tmp-0.7).^2)+(IMsceltot1<0).*IMsceltot1./(1+5*(tmp<0.1).*(0.1-tmp));%min(0,10*(tmp)))



out=min(1,max(0,out));

 if LDR==1
     out=out.^0.8;
 end



% img=min(1,max(0,img));



if size(IMG,3)>1
    IMGhsv(:,:,3)=out;
     figure; imshow((IMG));

 figure; imshow(hsv2rgb(IMGhsv));
else
 figure; imagesc(img);colormap gray
 figure; imagesc(out);colormap gray
end