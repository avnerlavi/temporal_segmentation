Algo=imread('C:\Users\97254\Documents\MATLAB\thesis\dataset\Results\Label7_2.png');
GT=imread('C:\Users\97254\Documents\MATLAB\thesis\dataset\G.T\Label7.png');
GT=logical(GT/255);
[Q] = ErrMetrics(Algo,GT);
figure;subplot(1,2,1);imshow(GT,[]);title('ManuSeg');subplot(1,2,2);imshow(Algo,[]);title('AutoSeg')
%%
G=imread('C:\Users\97254\Documents\MATLAB\thesis\dataset\G.T\mask7.png');
BG=bwlabel(G(:,:,1),4);
LL=BG==0;
[r c]=find(LL==1);
x1=min(r);
x2=max(r);
y1=min(c);
y2=max(c);

cropedG=G(x1:x2,y1:y2,1);
resizedG=imresize(cropedG,[256 256]);
imwrite(resizedG,['C:\Users\97254\Documents\MATLAB\thesis\dataset\G.T\Label',num2str(7),'.png']);