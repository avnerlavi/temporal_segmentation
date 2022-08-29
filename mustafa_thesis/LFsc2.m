function [out, imNR] = LFsc2(im,tat,Fac)

%  imagesc(im);figure(gcf);
 
c50=0.1;%min(0.5,1/(THR+10^-7)*0.15);
s=11;%odd num
imNR=im.^2./(im.^2+c50);%R
% w = gausswin(s);
% r0=imrotate(w,tat);
% r90=imrotate(w,tat+90);
% A0=imfilter(imNR,r0,'replicate');
% out0 =max(s/4,1)* (A0 + imfilter(imNR,r0,'replicate'));
% A90=imfilter(imNR,r90,'replicate');
% out90 =max(s/4,1)* (A90 + imfilter(imNR,r90,'replicate'));
% out=max(out0,out90);
% figure;subplot(1,3,1);imshow(A0,[]);subplot(1,3,2);imshow(A90,[]);subplot(1,3,3);imshow(x,[]);
% h = fspecial('motion',Fac , 90-tat*180/pi()); 
h0 = fspecial('motion',Fac ,tat); 
% h90=fspecial('motion',Fac ,90-tat);

out = 2*imfilter(imNR,h0,'replicate');

%h = fspecial('motion',round(Fac/2) , 90-tat*180/pi()); 
h0 = fspecial('motion',round(Fac/2) ,tat); 
% h90 = fspecial('motion',round(Fac/2) ,90-tat); 
% 
out =max(Fac/4,1)* (out + imfilter(imNR,h0,'replicate'));