%% initilization
disp(['Start ', datestr(datetime('now'),'HH:MM:SS')]);
dumpMovies = true;

root = getenv('TemporalSegmentation');
addpath(genpath([root,'/utils']));
addpath(genpath([root,'/3dGabor']));
addpath(genpath([root,'/3dGaussianStd']));

STDParams = struct;
STDMethod = 'Pyr';

if(strcmp(STDMethod, 'Pyr'))
    inFileDir = [root,'\resources\horse_running.avi'];
    vidMatrixOrig = readVideoFromFile(inFileDir, false);
    
    STDParams.resizeFactors = [1/2, 1/2, 1];
    STDParams.segmentLength = 9;
    STDParams.pyramidLevel = 5;
    
    vidStd = StdUsingPyramidFunc(vidMatrixOrig, STDParams);
    vidMatrix = vidStd;
    
elseif(strcmp(STDMethod, '3D'))
    inFileDir = [root,'\resources\horse_running.avi'];
    vidMatrixOrig = readVideoFromFile(inFileDir, false);
    
    STDParams.numOfScales = 4;
    STDParams.elevationHalfAngle = 60;
    STDParams.azimuthNum = 4;
    STDParams.elevationNum = 4;
    STDParams.sigmaSpatial = [3, 3, 0.1];
    STDParams.sigmaTemporal = [0.1, 0.1, 7];
    STDParams.m1 = 1;
    STDParams.m2 = 2;
    STDParams.resizeFactors = [1/2, 1/2, 1];
    
    vidStd = generateStdVideo3DFunc(vidMatrixOrig, STDParams);
    vidMatrix = vidStd;
    
elseif(strcmp(STDMethod, 'None'))
    inFileDir = [root,'\resources\horse_running.avi'];
    vidMatrixOrig = readVideoFromFile(inFileDir, false);
    vidMatrix = vidMatrixOrig;
    
else
    error('invalid stdMethod value');
end

MaskParams = struct;
MaskParams.initialReduction = 3;
MaskParams.targetResizeFactors  = [2/3, 2/3, 1];
MaskParams.baseResizeFactors = ...
    MaskParams.targetResizeFactors / MaskParams.initialReduction;
MaskParams.resizeIncrement = 0.5;
MaskParams.iterationNumber = ...
    ((MaskParams.initialReduction - 1) / MaskParams.resizeIncrement) + 1;
MaskParams.thresholdCC = 0.2;
MaskParams.thresholdAreaOfCC = 0.1;
MaskParams.alpha = 0.125;
MaskParams.gaussianSigma = 4;
MaskParams.gaussianShape = 13;
MaskParams.gaussianMaxVal = 1/4;

CCLFParams = struct;
CCLFParams.numOfScales = 1;
CCLFParams.activationThreshold = 0.3;
CCLFParams.elevationHalfAngle = 60;
CCLFParams.azimuthNum = 16;
CCLFParams.elevationNum = 16;
CCLFParams.facilitationLength = 16;
CCLFParams.alpha = 0;
CCLFParams.m1 = 2;
CCLFParams.m2 = 1;
CCLFParams.resizeFactors = MaskParams.baseResizeFactors;

[totalMask, maskPyr,  detailEnhancementPyr] = maskGenerationFunc(vidMatrix, MaskParams, CCLFParams);

%% test 

implay(vidMatrixOrig .* safeResize(totalMask, size(vidMatrixOrig)));
maintainFitToWindow();

disp(['Done ' datestr(datetime('now'),'HH:MM:SS')]);
if (dumpMovies)
    if (~strcmp(STDMethod, 'None')) 
        writeVideoToFile(vidStd, ['vid_std_', lower(STDMethod)], [root,'\results\iterativeDetection\std']);
    end
    
    for i=1:MaskParams.iterationNumber
        writeVideoToFile(detailEnhancementPyr{i}, ['detail_enhanced_',num2str(MaskParams.baseResizeFactors(1)*((i-1)*MaskParams.resizeIncrement+1),'%.3f'),'_'...
                                                   ,num2str(MaskParams.baseResizeFactors(2)*((i-1)*MaskParams.resizeIncrement+1),'%.3f'),'_'...
                                                   ,num2str(MaskParams.baseResizeFactors(3)*((i-1)*MaskParams.resizeIncrement+1),'%.3f')]...
                                                   ,[root,'\results\iterativeDetection\detail_enhancement']);

        writeVideoToFile(maskPyr{i}, ['mask_',num2str(MaskParams.baseResizeFactors(1)*((i-1)*MaskParams.resizeIncrement+1),'%.3f'),'_'...
                                                   ,num2str(MaskParams.baseResizeFactors(2)*((i-1)*MaskParams.resizeIncrement+1),'%.3f'),'_'...
                                                   ,num2str(MaskParams.baseResizeFactors(3)*((i-1)*MaskParams.resizeIncrement+1),'%.3f')]...
                                                   ,[root,'\results\iterativeDetection\iterative_mask']);
    end
        writeVideoToFile(totalMask, 'movie_total_mask', [root,'\results\iterativeDetection\iterative_mask']);
    
    saveParams([root,'\results\iterativeDetection\iterative_mask'],STDMethod, STDParams ... 
        ,CCLFParams, MaskParams);
    save([root,'\results\iterativeDetection\iterative_mask\params.mat'],'STDMethod', 'STDParams' ... 
        ,'CCLFParams','MaskParams');
end
