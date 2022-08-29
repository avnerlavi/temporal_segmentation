%Ex4_3_solution
% clear all; close all; clc;
% im=imread('brain.jpg');
im=imread('ShoulderPartialTear4.jpg');

im=imresize(rgb2gray(im),[256 256]);
figure;subplot(1,2,1); imshow(im,[]); title('original image');
%Displaying image histogram
hist= imhist(im);
subplot(1,2,2);
bar(hist); title('histogram of image');
%%
[m,n]=size(im);
avg1(1:2)=0; std1(1:2)=0;k(1:2)=0;sk(1:2)=0;
%k = kurtosis(X);skewness(X)
for i= 1:2
    if (i==1)
    figure;
 end
 BW=roipoly(im);
 structure=find(BW);
 BW=double(BW);
 sum_el=0;std=0;sum_std=0;

 b=numel(structure); %size of structure
 for j=1:b
    sum_el=sum_el + double(im(structure(j)));
 end
 avg1(i)=round(sum_el / b);
 for j=1:b
    sum_std= sum_std + (double(im(structure(j)))-avg1(i))^2;
 end
 std1(i)=sqrt(sum_std/b);
 k(i)= kurtosis(structure);
 sk(i)=skewness(structure);
 
end
%%
%Distances:
seg_Euclidean2(1:m,1:n)=0;
label_Euclidean(1:m,1:n)=0;
for i=1:m
    for j=1:n
        min_dist=100; dist=0; index=0;
        for t=1:2
            dist=abs((double(im(i,j))-avg1(t)));
            if (dist<min_dist)
                index=t;
                 min_dist=dist;
                 label_Euclidean(i,j)=index;
                 seg_Euclidean2(i,j)=avg1(index);

            end
        end
    end
end
%figure; imshow(seg_Euclidean,[]);title('Euclidean Segmentation');
RGB1=label2rgb(seg_Euclidean2,'lines');
figure; imshow(RGB1,[]);title('Euclidean Segmentation');
figure; imshow(label_Euclidean,[]);title('Euclidean colored Segmentation');
%%
seg_Mahalanobis2(1:m,1:n)=0;
for i=1:m
    for j=1:n
    min_dist=500; dist=0; index=0;
    for t=1:2
        dist=abs( (double(im(i,j))-avg1(t)) / (std1(t)) );
        if (dist<min_dist)
            min_dist=dist;
            index=t;
        end
    end
    seg_Mahalanobis2(i,j)=avg1(index);
    end
end
RGB2=label2rgb(seg_Mahalanobis2,'jet');
figure; imshow(RGB2,[]);title('Mahalanobis Segmentation');
%figure; imshow(seg_Mahalanobis,[]);title('Mahalanobis Segmentation');
th=mean(seg_Mahalanobis2(:));
BWm=~(seg_Mahalanobis2>th);
IntensityBW=BWm.*seg;
%%
%SORF+Intensity:
SORFfeat=Jerode;
Intisityfeat=IntensityBW;

tot=SORFfeat*0.4+Intisityfeat*0.6;
BWtot=tot==1;
seB=strel('disk',1);
dil=imdilate(BWtot,seB);er=imerode(BWtot,seB);
Border=dil-er;
imageBorder=Im+uint8(255*Border);
figure;imshow(imageBorder)