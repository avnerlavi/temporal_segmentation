function [out,IMsceltot1]=LF_Sharp(inImg)
LDR=0;
Iorginal = im2double(inImg);
if size(inImg,3)>1
    IMGhsv=rgb2hsv(inImg);
    I=IMGhsv(:,:,3);   
else
    I=im2double(inImg);
end


SS=4;
IMscel=zeros(size(I,1),size(I,2),SS);
IMsceltot=zeros(size(I,1),size(I,2));
theta = [0:5:210];
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
     for i=1:KK-1
         
         tat=pi()*(i-1)/(KK-1);
    
         
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
         
         Lnorm=imresize(Lnorm,1/5);
         L=imresize(L,1/5);
     
         Lnorm  =conv2(Lnorm,L,'same');
         CONVnorm = Lnorm(ceil(size(L,1)/2),ceil(size(L,1)/2));
         imgO = conv2(imgS,L,'same')/CONVnorm; %THR=0.009
         imgP = max(imgO,0);
         imgN = max(-imgO,0);
         THR=max(max(abs(imgO))); %% to change
         imgP=(imgP>0.05*THR).*imgP;
         imgN=(imgN>0.05*THR).*imgN;

          Fac=min(3,round(10./j));
          %Fac=3;
          [LFimmN1 NimNR1] = LFsc(imgN,theta(i),Fac);
          [LFimmP1 PimNR1] = LFsc(imgP,theta(i),Fac);
          LFimmN1=0.5*max(0,LFimmN1);
          LFimmP1=0.5*max(0,LFimmP1);      
          immNor1=immNor1+LFimmN1;
          immPor1=immPor1+LFimmP1;
          
          
          
    end
    IM2scel =-immNor1+immPor1;
    %IM2scel =immPor1;
    IMscel = interp2(IM2scel,j-1);
    IMscel=imresize(IMscel,[size(I,1) size(I,2)]); %reconstruction ;
    IMscel = IMscel/2.^(j-1);
    
%      figure; imagesc(imgS);colormap gray
%  
%             figure; imagesc(min(1,max(0,(imgS-immNor/2+immPor/8))));colormap gray
    IMsceltot=IMsceltot+IMscel;
   
end

% 
% new_im=zeros(size(IMsceltot));
% for i=0:10:180
%     im=IMsceltot;
%     [out, imNR] = LFsc2(im,i,1);
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
%C=1/max(IMsceltot(:));
% IMsceltot1=0.05*min(0.6*IMsceltot,5);%IMsceltot/(KK*SS.^0.5);girl
IMsceltot1=IMsceltot/(KK*SS.^0.5);
% IMsceltot1=0.3*min(0.2*IMsceltot,1);
%IMsceltot1=0.3*sign(IMsceltot).*(min(abs(C*IMsceltot),1)).^0.5;
%tmp=(I+IMsceltot1./max(IMsceltot1(:)));

tmp=I+IMsceltot1;
out=I+(IMsceltot1>0).*IMsceltot1./max(1,15*(tmp-0.7).^2)+(IMsceltot1<0).*IMsceltot1./(1+5*(tmp<0.1).*(0.1-tmp));%min(0,10*(tmp)))
% out=min(1,max(0,out));
%out=IMsceltot1;
% IMsceltot1=0.3*sign(IMsceltot).*(min(abs(IMsceltot),1)).^0.5;
%IMsceltot1=IMsceltot;
% tmp=(I+IMsceltot1);
%%
% figure;
% subplot(1,2,1);
% imshow(I,[]);title('Original')
% subplot(1,2,2);
% imshow(IMsceltot,[]);title('Algo')
%IMsceltot1=IMsceltot;
%out=(IMsceltot1>0).*IMsceltot1./(1+5*(tmp<0.1).*(0.1-tmp));%min(0,10*(tmp)))
%tmp1=I+out1;
%me:
% IMsceltot1=IMsceltot1-mean(IMsceltot1);
% RegP=(IMsceltot1>0).*IMsceltot1./max(1,15*(tmp-1).^2);
% filtRegP=medfilt2(RegP,[2 2]);
% RegN=(IMsceltot1<0).*IMsceltot1./(1+5*(tmp<0.1).*(0.1-tmp));
% filtRegN=medfilt2(RegN,[2 2]);
% 
% PPP=filtRegP./max(abs(filtRegP(:)));
% NNN=filtRegN./max(abs(filtRegN(:)));
% out=I./max(I(:))+1*(RegP+RegN);
%%
%out=min(1,max(0,out));
 if LDR==1
     out=max(out,0).^0.8;
 end

% img=min(1,max(0,img));

if size(inImg,3)>1
    IMGhsv(:,:,3)=out;
    A=hsv2rgb(IMGhsv); 
    out=A;
    %figure; imshow(hsv2rgb(IMGhsv));
    figure;subplot(1,2,1);imshow(inImg,[]);title('Before');subplot(1,2,2);imshow(A,[]);title('After')
else
%  figure;subplot(1,2,1);imagesc(I);%colormap gray
%  subplot(1,2,2); imagesc(out);%colormap gray
    figure;subplot(1,2,1);imshow(I,[]);title('Before');subplot(1,2,2);imshow(out,[]);title('After')

end