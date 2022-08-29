function AlgParams = AlgorithmParams(Path,res,Format,IMC,cost)

% This function contains algorithm parameters for the input image

%%  read Ulstrasound Image
switch nargin
    case 3
        
    % image path
    AlgParams.ImgPath = Path;

    % image type
    AlgParams.ImgType =Format;
    
    Res=res;
    case 4
    Res=res;
    AlgParams.ImgPath = Path;
    AlgParams.ImgType =Format;
    AlgParams.InputImgC=IMC;
    case 5
    Res=res;
    AlgParams.ImgPath = Path;
    AlgParams.ImgType =Format;
    AlgParams.InputImgC=IMC;
    AlgParams.Cost=cost;
end

        

% AlgParams.InputImg = imread([Path],AlgParams.ImgType);
IM=imread([Path],AlgParams.ImgType);
if (size(IM,3)>1)
    J = adapthisteq(rgb2gray(IM),'clipLimit',0.2,'Distribution','rayleigh');
else
    J = adapthisteq(IM,'clipLimit',0.2,'Distribution','rayleigh');
end
%AlgParams.InputImg=imresize(J,[256 256]);
AlgParams.InputImg=imresize(IM,[256 256]);
%% default parameters
% noise reduction parameters
AlgParams.LpfSize = 3; % size for low pass filter

% SORF parametrs for B-mode image
AlgParams.LocalSize =                 10;% size of local area (squer area of sizeXsize pixels)
AlgParams.LocalDecayCoef =     10; % decay coefficient of filter mask in local area
AlgParams.RemoteSize =                30;% size of remote area (squer area of sizeXsize pixels)
AlgParams.RemoteDecayCoef =   30; % decay coefficient of filter mask in remote  area
AlgParams.CenSizes.Im =             Res;%[20 25 35 40];   %[3 5 7 10 12 15 18 20]; %5:5:35; % 20:10:40; % center area resolutions for B-mode image
AlgParams.FieldSizeFactor =            3; % field size proportion factor to center area resolution
AlgParams.SrndDecayCoefFactor = 2; % surround mask decay coefficient proportion factor to center area resolution
AlgParams.CenDecayCoefFactor =    2; % center mask decay coefficient proportion factor to center area resolution
AlgParams.MultiResPower=   2; % power for summing multi resolution SORF responses for B-mode image
AlgParams.MultiResPowerBmode =   2; % power for summing multi resolution SORF responses for B-mode image
% local intensity parameters
AlgParams.AvrgFiltSize = 3; % size for avereging filter for local intensity calculation
AlgParams.SeedLocalIntenTh = 0.1; % threshold for local intensity of seed point area, to deside wether to use "and" or "or" operation with Elasto SORF response mask

% relative intensity parameters
AlgParams.CenSizes.Relative = [8 10 12]; %10; % center size for relative intensity calculation

% edge parameters
AlgParams.LocalIntenThHigh = 0.09; % intensity threshold for B-mode images
AlgParams.RelativeIntenThHigh = 0.3;% relative intensity threshold for B-mode images
AlgParams.BmodeSorfTh = 0.06; % response threshold for SORF processed B-mode images
AlgParams.LocalContrastTh = 0.28; % response threshold for local contrast response
AlgParams.RelativeContrastTh = 0.42; % response threshold for relative contrast response

% color parameters
AlgParams.BmodeEdgeColor = [0 255 0]; % Green
AlgParams.CorrEdgeColor = [255 255 0]; % Yellow
AlgParams.ManuEdgeColor = [0 255 255]; % Cyan
AlgParams.ElastoEdgeColor = [0 0 255]; % Blue
AlgParams.ConvexEdgeColor = [255 0 0]; % Red

% level set parameters
AlgParams.C0Radious = 15; % radious of the initial contour
AlgParams.Phi0Level = 10; % % levle value of the initial level set function (Phi0 = -Phi0Level,0 or +Phi0Level)
AlgParams.NIterBmode = 500; % number of iteration for the update of phi
AlgParams.NIterElasto = 300; % number of iteration for the update of phi
AlgParams.dt = 5; % time difference between iterations
AlgParams.Epsilon = 1; % a small number for the approximation of Heaviside and Dirac functions
AlgParams.RegType = 2; % type of regularization potintial function. if 1: p=p1, if 2: p=p2.
AlgParams.AlfasBmode = [1 0 0;0 0 0]; % weights for force terms in the gradient descent equation: [for region terms; for dge terms]
AlgParams.BetaBmode = 0; %0.1*255; % weight for length force term in the gradient descent equation
AlgParams.GammaBmode = 0; %0.2/AlgParams.dt;% weight for regularization force term in the gradient descent equation
AlgParams.AlfasElasto = [1 0;0 0]; % weights for force terms in the gradient descent equation: [for region terms; for dge terms]
AlgParams.BetaElasto = 255; % weight for length force term in the gradient descent equation
AlgParams.GammaElasto = 0; %0.2/AlgParams.dt;% weight for regularization force term in the gradient descent equation

% flag parameters
AlgParams.ShowInputImgs = 0; % flag to show input B-mode and elasto images
AlgParams.BmodeCalcs = 0; % flag for calculations for B-mode images
AlgParams.ElastoCalcs = 0; % flag for calculations for Elasto images
AlgParams.ProcIntenFlag = 0; % flag for intensity calculation fo Elasto images
AlgParams.ShowBmodeRes = 0; % flag for ploting SORF results for Elasto images
AlgParams.ShowElastoRes = 0; % flag for ploting SORF results for Elasto images
AlgParams.CovexEdgeFlag = 1; % flag for calculating convex hull edge
AlgParams.SaveResBmode = 0; % flag for saving B-mode results
AlgParams.SaveResElasto = 0; % flag for saving Elasto results
AlgParams.ColorImageFlag=0;
end % function AlgParams = SetAlgorithmParams(ImgNum)