%close all;clear all;
A=S;
A=imresize(A,[256 256]);
%A = imresize(A,0.25);
Agray=A;

%Agray = rgb2gray(A);
figure
imshow(A,[])
%%
imageSize = size(A);
numRows = imageSize(1);
numCols = imageSize(2);

wavelengthMin = 4/sqrt(2);
wavelengthMax = hypot(numRows,numCols);
n = floor(log2(wavelengthMax/wavelengthMin));
wavelength = 2.^(0:(n-2)) * wavelengthMin;

deltaTheta = 45;
orientation = 0:deltaTheta:(180-deltaTheta);

g = gabor(wavelength,orientation);
gabormag = imgaborfilt(Agray,g);
%%
for i = 1:length(g)
    sigma = 0.5*g(i).Wavelength;
    K = 4;
    gabormag(:,:,i) = imgaussfilt(gabormag(:,:,i),K*sigma); 
end
X = 1:numCols;
Y = 1:numRows;
[X,Y] = meshgrid(X,Y);
featureSet = cat(3,gabormag,X);
featureSet = cat(3,featureSet,Y);
numPoints = numRows*numCols;
X = reshape(featureSet,numRows*numCols,[]);
X = bsxfun(@minus, X, mean(X));
X = bsxfun(@rdivide,X,std(X));
coeff = pca(X);
feature2DImage = reshape(X*coeff(:,1),numRows,numCols);
figure
imshow(feature2DImage,[])
%%
L = kmeans(X,3,'Replicates',5);
L = reshape(L,[numRows numCols]);
figure;
imshow(label2rgb(L))
%%
Aseg1 = zeros(size(A),'like',A);
Aseg2 = zeros(size(A),'like',A);
BW = L == 5;
BW = repmat(BW,[1 1 3]);
BW=BW(:,:,1);
Aseg1(BW) = A(BW);
Aseg2(~BW) = A(~BW);
figure
imshowpair(Aseg1,Aseg2,'montage');
%%
cc=bwlabel(L-1,4);
figure;imshow(cc,[])
seg=(cc==1);
se=strel('disk',1);
b1=imdilate(seg,se);
b2=imclose(seg,se);
border=b1-b2;
f=final_im+border;
figure;imshow(f);