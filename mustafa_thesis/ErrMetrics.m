function [Q,AreaTP] = ErrMetrics(AutoSeg,ManuSeg)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description
%        This function calculate area error metrics for the segmented lesion.
%
% Usage:
%        Statistics = ErrMet(ManuSeg,AutoSeg)
%
% Input:
%        AutoSeg (Aa): automatic lesion segmntation (should be a binary image).
%        ManuSeg (Am): manual lesion segmentation (should be a binary image).
%
% Output:
%        Statistics: error matrics values.

ManuSeg=double(im2bw(ManuSeg));
% difference of delinated areas
Diff = ManuSeg-AutoSeg;

% flase negative area
AreaFN = Diff==1;
FN = sum(AreaFN(:));

% flase positive area
AreaFP = Diff==-1;
FP = sum(AreaFP(:));

% true positive area
AreaTP = AutoSeg - AreaFP;
TP = sum(AreaTP(:));

% true negative area
AreaTN = true(size(ManuSeg)) - AreaFN - AreaFP - AreaTP;
TN = sum(AreaTN(:));

%  size of area in ManuSeg
NManuSeg = TP+FN;

% true positive ratio
TPR = TP/NManuSeg;

% false negative ratio
FNR = FN/NManuSeg;

% false positive ratio
FPR = FP/NManuSeg;

% similarity
SI = TP/(TP+FP+FN);

% overall accuracy
OA = (TP+ TN)/(TP+TN+FP+FN);

% specificity
Spe = TN/(TN+FP);

% sensitivity
Sen = TP/(TP+FN);

% positive predictive value
PPV = TP/(TP+FP);

% negative predictive value
NPV = TN/(TN+FN);

% Matthew's correlation coefficient
MCC = (TP*TN-FP*FN)/sqrt((TP+FP)*(TP+FN)*(TN+FP)*(TN+FN));

%dice
Dice = dice(AutoSeg, ManuSeg);
% Compute Tversky index
numer = TP + 1e-8;
denom = TP + 0.5*FP + 0.5*FN + 1e-8;
lossTIc = 1 - numer./denom;

ACC=(TP+TN)./(TP+TN+FP+FN);


Q=zeros(1,13);
Q(1)=TPR;
Q(2)=FPR;
Q(3)=FNR;
Q(4)=SI;
Q(5)=OA;
Q(6)=Spe;
Q(7)=Sen;
Q(8)=PPV;
Q(9)=NPV;
Q(10)=MCC;
Q(11)=Dice;
Q(12)=lossTIc;
Q(13)=ACC;
% tests
test = 1;
if test
    figure; imshow(ManuSeg); title('Manual segmentation');
    figure; imshow(AutoSeg); title('Automatic segmentation');
    figure; imshow(AreaTP); title('TP area');
    figure; imshow(AreaFN); title('FN area');
    figure; imshow(AreaFP); title('FP area');
    figure; imshow(AreaTN); title('TN area');
end