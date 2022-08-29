function [Target] = TearRegion(Tear,Neg)

%remove the connections

TearFill=imfill(Tear,'holes');
se_remove=strel('disk',1);
Tear_after1=imopen(TearFill,se_remove);

%bottom edge
E=edge(Neg);
Z2=zeros(size(E));
for i=1:size(E,2)
    [x y]=find(E(:,i)); 
    if ~(isempty(x) || isempty(y))
        bottom=max(x);
        idx.x(i)=bottom;
        idx.y(i)=i;
        Z2(bottom,i)=1;%bottom  of the bone
    end
end
se=strel('disk',5);
ZZ2=imdilate(Z2,se); 
[x y]=find(ZZ2==1);
thr=median(x);

R=imcomplement(ZZ2);
%figure;imshow(R.*Tear_after1,[])

L=R.*Tear_after1;
L2=imclose(L,se_remove);

seFinal=strel('disk',1);
FinalL=imopen(L2,seFinal);

Lb=bwlabel(FinalL,4);
stats = regionprops(Lb,'All');
%tear features:

Eq=[stats.EquivDiameter];
idx=find(Eq==max(Eq));
Target=ismember(Lb,idx);
end