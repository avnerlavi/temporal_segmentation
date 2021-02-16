%% initilization
disp(['Start ', datestr(datetime('now'),'HH:MM:SS')]);
dump_movies = false;
generatePyrFlag = false;
root = getenv('TemporalSegmentation');
addpath(genpath([root,'/utils']));
addpath(genpath([root,'/3dGabor']));
baseResizeFactors = [2/3 , 2/3 , 2/2]*1/3;

if(generatePyrFlag)
    inFileDir = [root,'\captcha_running.avi'];
    vid_matrix_orig = readVideoFromFile(inFileDir, true);
    vid_matrix = imresize(vid_matrix_orig, 0.25);
    vid_matrix = StdUsingPyramidFunc(vid_matrix);
else
    inFileDir = "C:\Users\Avner\Documents\Elec. Eng. II\Project\temporal_segmentation\results\3dStd\normed_then_squared\movie_3d_std.avi";
    vid_matrix = readVideoFromFile(inFileDir, false);
end

CCLFParams = struct;
CCLFParams.numOfScales = 4;
CCLFParams.elevationHalfAngle = 60;
CCLFParams.azimuthNum = 8;
CCLFParams.elevationNum = 6;
CCLFParams.facilitationLength = 10;
CCLFParams.alpha = 0;
CCLFParams.m1 = 1;
CCLFParams.m2 = 2;
CCLFParams.resizeFactors = baseResizeFactors;

boundryMaskWidth = ceil(CCLFParams.facilitationLength/4);
thresholdCC = 0.3;
thresholdAreaOfCC = 0.3;

maskBlurFilt = Gaussian3dIso(3,11);
maskBlurFilt = minMaxNorm(maskBlurFilt)/4;

totalMask = zeros(size(vid_matrix));
gamma = 1.5;
alpha = 0.5;
backOff = 0.95;
SE = strel('sphere',2);
iterationNumber = 5; %TODO: link to scales
maskPyr = cell(1,iterationNumber);
for i=1:iterationNumber 
    %% detail enhancement
    CCLFParams.resizeFactors = baseResizeFactors*((i-1)/2+1); %TODO: link to scales
    detailEnhanced = detailEnhancement3Dfunc(vid_matrix,CCLFParams,false);
    detailEnhanced = minMaxNorm(abs(detailEnhanced));
    %% connected components 
    %TODO: into function
    if(i~=1)
        detailEnhanced = detailEnhanced.*safeResize(totalMask,size(detailEnhanced));
    end
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
    %totalMask = max(currMask ,(backOff*totalMask).^gamma);
    %totalMask = max(imerode(totalMask,SE),currMask);
    %% connected components two electric boogaloo
end
%% test 

implay(totalMask)
maintainFitToWindow();

disp(['Done ' datestr(datetime('now'),'HH:MM:SS')]);
if (dump_movies)
    writeVideoToFile(totalMask, 'movie_total_mask', [root,'\results\iterativeDetection\iterative_mask']);
    for i=1:iterationNumber
        writeVideoToFile(maskPyr{i}, ['movie_mask_',num2str(baseResizeFactors(1)*((i-1)/2+1),'%.3f'),'_'...
                                                   ,num2str(baseResizeFactors(2)*((i-1)/2+1),'%.3f'),'_'...
                                                   ,num2str(baseResizeFactors(3)*((i-1)/2+1),'%.3f')]...
                                                   ,[root,'\results\iterativeDetection\iterative_mask']);
    end
end
