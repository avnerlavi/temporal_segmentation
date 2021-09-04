%% initilization
disp(['Start ', datestr(datetime('now'),'HH:MM:SS')]);
dump_movies = true;
generatePyrFlag = true;
root = getenv('TemporalSegmentation');
addpath(genpath([root,'/utils']));
addpath(genpath([root,'/3dGabor']));

if(generatePyrFlag)
    inFileDir = [root,'\captcha_running.avi'];
    vid_matrix_orig = readVideoFromFile(inFileDir, true);
    vid_matrix = imresize(vid_matrix_orig, 0.25);
    std_pyr = StdUsingPyramidFunc(vid_matrix);
    vid_matrix = std_pyr;
else
    inFileDir = [root,'\results\3dStd\movie_vid_std_3d.avi'];
    vid_matrix = readVideoFromFile(inFileDir, false);
end

resizeParams = struct;
resizeParams.initialReduction = 3;
resizeParams.targetResizeFactors  = [2/3 , 2/3 , 2/2];
resizeParams.resizeIncrement = 0.5;
baseResizeFactors  = resizeParams.targetResizeFactors./resizeParams.initialReduction;
iterationNumber = (resizeParams.initialReduction-1)/resizeParams.resizeIncrement +1;

CCLFParams = struct;
CCLFParams.numOfScales = 4;
CCLFParams.elevationHalfAngle = 60;
CCLFParams.azimuthNum = 8;
CCLFParams.elevationNum = 7;
CCLFParams.facilitationLength = 16;
CCLFParams.alpha = 0;
CCLFParams.m1 = 1;
CCLFParams.m2 = 1;
CCLFParams.resizeFactors = baseResizeFactors;
boundryMaskWidth = ceil(CCLFParams.facilitationLength/4);

thresholdCC = 0.2;
thresholdAreaOfCC = 0.1;
alpha = 0.125;

MaskGaussianParams = struct;
MaskGaussianParams.sigma = 4;
MaskGaussianParams.shape = 13;
MaskGaussianParams.maxVal = 1/4;
maskBlurFilt = Gaussian3DIso(MaskGaussianParams.sigma,MaskGaussianParams.shape);
maskBlurFilt = minMaxNorm(maskBlurFilt)*MaskGaussianParams.maxVal;

totalMask = ones(size(vid_matrix));

maskPyr = cell(1,iterationNumber);
for i=1:iterationNumber 
    %% detail enhancement
    CCLFParams.resizeFactors = baseResizeFactors*((i-1)*resizeParams.resizeIncrement+1);
    vidMasked = vid_matrix .* safeResize(totalMask,size(vid_matrix));
    detailEnhanced = detailEnhancement3Dfunc(vidMasked,CCLFParams,false);
    detailEnhanced = minMaxNorm(abs(detailEnhanced));
    %% connected components 
    %TODO: into function
%     detailEnhanced = detailEnhanced.*safeResize(totalMask,size(detailEnhanced));
    vidTrimmed = zeros(size(detailEnhanced));
    boundryMask = zeros(size(detailEnhanced));
    boundryMask(boundryMaskWidth+1 : end-boundryMaskWidth...
            ,boundryMaskWidth+1 : end-boundryMaskWidth...
            ,boundryMaskWidth+1 : end-boundryMaskWidth) = 1;
        
    vidTrimmed(boundryMask == 1) = detailEnhanced(boundryMask == 1);
    vidTrimmed = minMaxNorm(vidTrimmed);

    CC = bwconncomp(vidTrimmed>thresholdCC);
    numOfPixels = cellfun(@numel,CC.PixelIdxList);
    largestCCArea = max(numOfPixels);

    largestCCIdx = find(numOfPixels > thresholdAreaOfCC * largestCCArea);
    numOfCC2keep = length(largestCCIdx);
    vidCC = zeros(size(vidTrimmed));
    for j = 1:numOfCC2keep
        vidCC(CC.PixelIdxList{largestCCIdx(j)}) = 1;
    end
    vidCC = minMaxNorm(vidCC);
    %% create mask 
    currMask = convn(vidCC,maskBlurFilt,'same');
    currMask = safeResize(currMask,size(vid_matrix));
    maskPyr{i} = currMask;
    totalMask = alpha* currMask + (1 - alpha) * totalMask;
end
%% test 

implay(totalMask)
maintainFitToWindow();

disp(['Done ' datestr(datetime('now'),'HH:MM:SS')]);
if (dump_movies)
    if (generatePyrFlag) 
        writeVideoToFile(std_pyr, 'movie_std_pyr', [root,'\results\iterativeDetection\std']);
    end

    writeVideoToFile(totalMask, 'movie_total_mask', [root,'\results\iterativeDetection\iterative_mask']);
    for i=1:iterationNumber
        writeVideoToFile(maskPyr{i}, ['movie_mask_',num2str(baseResizeFactors(1)*((i-1)*resizeParams.resizeIncrement+1),'%.3f'),'_'...
                                                   ,num2str(baseResizeFactors(2)*((i-1)*resizeParams.resizeIncrement+1),'%.3f'),'_'...
                                                   ,num2str(baseResizeFactors(3)*((i-1)*resizeParams.resizeIncrement+1),'%.3f')]...
                                                   ,[root,'\results\iterativeDetection\iterative_mask']);
    end
    
    saveParams([root,'\results\iterativeDetection\iterative_mask'],generatePyrFlag ... 
        ,resizeParams,CCLFParams,thresholdCC,thresholdAreaOfCC,alpha,MaskGaussianParams);
    save([root,'\results\iterativeDetection\iterative_mask\params.mat'],'generatePyrFlag' ... 
        ,'resizeParams','CCLFParams','thresholdCC','thresholdAreaOfCC','alpha','MaskGaussianParams');
end
