function AlgParams = SetAlgorithmParams(ImgNum)

% This function contains algorithm parameters for the input image

%% load saved parameters if exist
% image number
AlgParams.ImgNum = ImgNum;

%%  read B-mode and Elasto image
% image path
AlgParams.ImgPath = 'images\';

% image type
AlgParams.ImgType = 'bmp';

% images names (B-mode and elasto)
AlgParams.ImgBmodeName = [ImgNum '_B-mode.' AlgParams.ImgType];
AlgParams.ImgElastoName =  [ImgNum '_Elasto.' AlgParams.ImgType];

% read the images  (B-mode and elasto)
AlgParams.InputImgBmode = imread([AlgParams.ImgPath AlgParams.ImgBmodeName],AlgParams.ImgType);
AlgParams.InputImgElasto = imread([AlgParams.ImgPath AlgParams.ImgElastoName],AlgParams.ImgType);

%% default parameters
% noise reduction parameters
AlgParams.LpfSize = 3; % size for low pass filter

% SORF parametrs for B-mode image
AlgParams.LocalSize =                 10;% size of local area (squer area of sizeXsize pixels)
AlgParams.LocalDecayCoef =     10; % decay coefficient of filter mask in local area
AlgParams.RemoteSize =                30;% size of remote area (squer area of sizeXsize pixels)
AlgParams.RemoteDecayCoef =   30; % decay coefficient of filter mask in remote  area
AlgParams.CenSizes.Bmode =                  [3 5 7 10 12 15 18 20]; %5:5:35; % 20:10:40; % center area resolutions for B-mode image
AlgParams.CenSizes.Elasto =                [1 3 5]; %10; %1:3:10; % center area resolutions for Elasto image
AlgParams.CenSizes.ElastoInten =   [12 15 18]; %[3 5 7 10 12 15 18 20]; % center area resolutions for intensity of Elasto image
AlgParams.FieldSizeFactor =            3; % field size proportion factor to center area resolution
AlgParams.SrndDecayCoefFactor = 2; % surround mask decay coefficient proportion factor to center area resolution
AlgParams.CenDecayCoefFactor =    1; % center mask decay coefficient proportion factor to center area resolution
AlgParams.MultiResPowerBmode =    2; % power for summing multi resolution SORF responses for B-mode image
AlgParams.MultiResPowerElasto = 2;% power for summing multi resolution SORF responses for Elasto image

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
AlgParams.ElastoSorfThLow = 0.1; % response threshold for SORF processed Elasto images

% color parameters
AlgParams.BmodeEdgeColor = [0 255 0]; % Green
AlgParams.CorrEdgeColor = [255 255 0]; % Yellow
AlgParams.ManuEdgeColor = [0 255 255]; % Cyan
AlgParams.ElastoEdgeColor = [0 0 255]; % Blue
AlgParams.ConvexEdgeColor = [255 0 0]; % Red

% level set parameters
AlgParams.C0Radious = 40; % radious of the initial contour
AlgParams.Phi0Level = 4; % % levle value of the initial level set function (Phi0 = -Phi0Level,0 or +Phi0Level)
AlgParams.NIterBmode = 200; % number of iteration for the update of phi
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
AlgParams.ShowInputImgs = 1; % flag to show input B-mode and elasto images
AlgParams.BmodeCalcs = 1; % flag for calculations for B-mode images
AlgParams.ElastoCalcs = 0; % flag for calculations for Elasto images
AlgParams.ProcIntenFlag = 0; % flag for intensity calculation fo Elasto images
AlgParams.ShowBmodeRes = 0; % flag for ploting SORF results for Elasto images
AlgParams.ShowElastoRes = 0; % flag for ploting SORF results for Elasto images
AlgParams.CovexEdgeFlag = 1; % flag for calculating convex hull edge
AlgParams.SaveResBmode = 1; % flag for saving B-mode results
AlgParams.SaveResElasto = 1; % flag for saving Elasto results

%% specific parameters
switch ImgNum
    case '1.1'
        AlgParams.SeedPoint = [70 205];
        AlgParams.SeedPointElasto = [100 220];
        
    case '2.1'
        AlgParams.SeedPoint = [65 200];
        AlgParams.SeedPointElasto = [90 240];
        
    case '3.1'
        AlgParams.SeedPoint = [75 210];
        AlgParams.SeedPointElasto = [80 210];
        
    case '4.1'
        AlgParams.SeedPoint = [75 200];
        AlgParams.SeedPointElasto = [75 210];
        
    case '5.1'
        AlgParams.SeedPoint = [130 215];
        AlgParams.SeedPointElasto = [125 205];
        
    case '6.1'
        AlgParams.SeedPoint = [50 185];
        AlgParams.SeedPointElasto = [60 190];
        
    case '7.1'
        AlgParams.SeedPoint = [50 195];
        AlgParams.SeedPointElasto = [65 205];
        
    case '8.1'
        AlgParams.SeedPoint = [45 175];
        AlgParams.SeedPointElasto = [40 170];
        
    case '9.1'
        AlgParams.SeedPoint = [150 180];
        AlgParams.SeedPointElasto = [100 140];
        
    case '10.1'
        AlgParams.SeedPoint = [140 160];
        AlgParams.SeedPointElasto = [160 165];
        
    case '11.1'
        AlgParams.SeedPoint = [150 145];
        AlgParams.SeedPointElasto = [55 100];
        
    case '12.1'
        AlgParams.SeedPoint = [95 225];
        AlgParams.SeedPointElasto = [90 225];
        
    case '13.1'
        AlgParams.SeedPoint = [100 215];
        AlgParams.SeedPointElasto = [75 205];
        
    case '14.1'
        AlgParams.SeedPoint = [80 230];
        AlgParams.SeedPointElasto = [90 205];
        
    case '15.1'
        AlgParams.SeedPoint = [120 195];
        AlgParams.SeedPointElasto = [125 215];
        
    case '16.1'
        AlgParams.SeedPoint = [170 200];
        AlgParams.SeedPointElasto = [145 200];
        
    case '17.1'
        AlgParams.SeedPoint = [95 140];
        AlgParams.SeedPointElasto = [80 180];
        
    case '18.1'
        AlgParams.SeedPoint = [70 145];
        AlgParams.SeedPointElasto = [70 160];
        
    case '19.1'
        AlgParams.SeedPoint = [70 165];
        AlgParams.SeedPointElasto = [70 165];
        
    case '20.1'
        AlgParams.SeedPoint = [75 160];
        AlgParams.SeedPointElasto = [55 180];
        
    case '21.1'
        AlgParams.SeedPoint = [100 185];
        AlgParams.SeedPointElasto = [105 165];
        
    case '22.1'
        AlgParams.SeedPoint = [110 170];
        AlgParams.SeedPointElasto = [105 165];
        
    case '23.1'
        AlgParams.SeedPoint = [105 180];
        AlgParams.SeedPointElasto = [90 180];
        
    case '24.1'
        AlgParams.SeedPoint = [125 230];
        AlgParams.SeedPointElasto = [130 290];
        
    case '25.1'
        AlgParams.SeedPoint = [120 230];
        AlgParams.SeedPointElasto = [135 240];
        
    case '26.1'
        AlgParams.SeedPoint = [100 120];
        AlgParams.SeedPointElasto = [90 165];
        
    case '27.1'
        AlgParams.SeedPoint = [90 130];
        AlgParams.SeedPointElasto = [90 165];
        
    case '28.1'
        AlgParams.SeedPoint = [90 210];
        AlgParams.SeedPointElasto = [70 210];
        
    case '29.1'
        AlgParams.SeedPoint = [80 115];
        AlgParams.SeedPointElasto = [95 135];
        
    case '30.1'
        AlgParams.SeedPoint = [95 130];
        AlgParams.SeedPointElasto = [85 150];
        
    case '31.1'
        AlgParams.SeedPoint = [100 170];
        AlgParams.SeedPointElasto = [110 155];
        
    case '32.1'
        AlgParams.SeedPoint = [135 95];
        AlgParams.SeedPointElasto = [110 115];
        
    case '33.1'
        AlgParams.SeedPoint = [65 85];
        AlgParams.SeedPointElasto = [50 75];
        
    case '34.1'
        AlgParams.SeedPoint = [35 140];
        AlgParams.SeedPointElasto = [25 125];
        
    case '35.1';
        AlgParams.SeedPoint = [150 180];
        AlgParams.SeedPointElasto = [115 190];
        
    case '101.0'
        AlgParams.SeedPoint = [50 85];
        
    case '102.0'
        AlgParams.SeedPoint = [45 60];
        
    case '103.0'
        AlgParams.SeedPoint = [65 60];
        
    case '104.0'
        AlgParams.SeedPoint = [55 75];
        
    case '105.0'
        AlgParams.SeedPoint = [50 150];
        
    case '106.0'
        AlgParams.SeedPoint = [70 140];
        
    case '107.0'
        AlgParams.SeedPoint = [30 115];
        
    case '108.0'
        AlgParams.SeedPoint = [85 100];
        
    case '109.0'
        AlgParams.SeedPoint = [90 70];
        
    case '110.0'
        AlgParams.SeedPoint = [70 115];
        
    case '111.0'
        AlgParams.SeedPoint = [25 125];
        
    case '112.0'
        AlgParams.SeedPoint = [65 130];
        
    case '113.0'
        AlgParams.SeedPoint = [43 130];
        
    case '114.0'
        AlgParams.SeedPoint = [45 145];
        
    case '115.0'
        AlgParams.SeedPoint = [75 115];
        
    case '116.0'
        AlgParams.SeedPoint = [45 55];
        
    case '117.0'
        AlgParams.SeedPoint = [55 115];
        
    case '118.0'
        AlgParams.SeedPoint = [65 85];
        
    case '119.0'
        AlgParams.SeedPoint = [65 95];
        
    case '120.0'
        AlgParams.SeedPoint = [60 125];
        
    case '121.0'
        AlgParams.SeedPoint = [90 100];
        
    case '122.0'
        AlgParams.SeedPoint = [105 135];
        
    case '201.0';
        AlgParams.SeedPoint = [25 120];
        
    case '202.0';
        AlgParams.SeedPoint = [30 80];
        
    case '203.0';
        AlgParams.SeedPoint = [75 95];
        
    case '204.0';
        AlgParams.SeedPoint = [50 70];
        
    case '205.0';
        AlgParams.SeedPoint = [65 60];
        
    case '206.0';
        AlgParams.SeedPoint = [65 60];
        
    case '207.0';
        AlgParams.SeedPoint = [80 60];
        
    case '208.0';
        AlgParams.SeedPoint = [45 85];
        
    case '209.0';
        AlgParams.SeedPoint = [50 95];
        
    case '210.0';
        AlgParams.SeedPoint = [50 70];
        
    case '301.0';
        AlgParams.SeedPoint = [85 110];
        
    case '302.0';
        AlgParams.SeedPoint = [70 80];
        
    case '303.0';
        AlgParams.SeedPoint = [80 115];
        
    case '304.0';
        AlgParams.SeedPoint = [75 53];
        
    case '305.0';
        AlgParams.SeedPoint = [94 96];
        
    case '306.0';
        AlgParams.SeedPoint = [80 110];
        
    case '307.0';
        AlgParams.SeedPoint = [85 150];
        
    case '308.0';
        AlgParams.SeedPoint = [20 70];
        
    case '309.0';
        AlgParams.SeedPoint = [50 65];
        
    case '310.0';
        AlgParams.SeedPoint = [65 100];
        
    case '311.0';
        AlgParams.SeedPoint = [70 180];
end % switch ImgNum
end % function AlgParams = SetAlgorithmParams(ImgNum)