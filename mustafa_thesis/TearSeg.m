function [TargetSegment] = TearSeg(I,S,ROI)
[MG1, ~, ~]=fth(S,3,[2,3],1);
[MG2, ~, ~]=fth(I,0,[1,2]);

TearS=MG1==1;
TearI=MG2==1;
alpha=0.3;
Tear=alpha*TearS+(1-alpha)*TearI;
Tear_ROI=Tear.*double(ROI);
Tear_ROI=Tear_ROI==1;

se=strel('disk',5);
erodedROI=imerode(ROI,se);
Neg=max(-S,0).*erodedROI;
TargetSegment = TearRegion(Tear_ROI,Neg);
Centroid_Tear = regionprops(TargetSegment,'Centroid');
X=Centroid_Tear.Centroid(1);
Y=Centroid_Tear.Centroid(2);

end

