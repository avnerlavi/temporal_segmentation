%% initialization
startTime = datetime('now');
dumpMovies = true;

root = getenv('TemporalSegmentation');
addpath(genpath([root,'/utils']));
addpath(genpath([root,'/3dGaussianStd']));
addpath(genpath([root,'/3dGabor']));
addpath(genpath([root,'/maskGeneration']));
addpath(genpath([root,'/evaluation']));

vidFileName = 'man_running';

STDMethod = '3D';
STDParams = struct;

MaskParams = struct;
MaskParams.initialReduction = 3;
MaskParams.targetResizeFactors  = [2/3, 2/3, 1];
MaskParams.baseResizeFactors = ...
    MaskParams.targetResizeFactors / MaskParams.initialReduction;
MaskParams.resizeIncrement = 0.5;
MaskParams.iterationNumber = ...
    ((MaskParams.initialReduction - 1) / MaskParams.resizeIncrement) + 1;
MaskParams.percentileThreshold = 95;
MaskParams.thresholdAreaOfCC = 0.1;
MaskParams.alpha = 0.125;
MaskParams.gaussianSigma = 4;
MaskParams.gaussianShape = 13;
MaskParams.gaussianMaxVal = 1/4;

CCLFParams = struct;
CCLFParams.numOfScales = 4;
CCLFParams.activationThreshold = 0.3;
CCLFParams.elevationHalfAngle = 60;
CCLFParams.azimuthNum = 8;
CCLFParams.elevationNum = 7;
CCLFParams.facilitationLength = 16;
CCLFParams.alpha = 0;
CCLFParams.m1 = 2;
CCLFParams.m2 = 1;
CCLFParams.normQ = 2;
CCLFParams.resizeFactors = MaskParams.baseResizeFactors;

%% image loading / STD preprocessing

disp(['Start ', datestr(startTime, 'HH:MM:SS')]);

if(strcmp(STDMethod, 'Pyr'))
    inFileDir = [root,'\resources\', vidFileName, '.avi'];
    vidMatrixOrig = readVideoFromFile(inFileDir, false);
    
    if(strcmp(vidFileName, 'man_running'))
        STDParams.resizeFactors = [1/4, 1/4, 1];
    else
        STDParams.resizeFactors = [1/2, 1/2, 1];
    end
    STDParams.segmentLength = 9;
    STDParams.pyramidLevel = 5;
    STDParams.gamma = 2;
    
    vidStd = StdUsingPyramidFunc(vidMatrixOrig, STDParams);
    vidMatrix = vidStd;
    
elseif(strcmp(STDMethod, '3D'))
    inFileDir = [root,'\resources\', vidFileName, '.avi'];
    vidMatrixOrig = readVideoFromFile(inFileDir, false);
    
    STDParams.numOfScales = 4;
    STDParams.elevationHalfAngle = 60;
    STDParams.azimuthNum = 4;
    STDParams.elevationNum = 4;
    STDParams.sigmaSpatial = [3, 3, 0.1];
    STDParams.sigmaTemporal = [0.1, 0.1, 7];
    STDParams.m1 = 2;
    STDParams.m2 = 2;
    STDParams.normQ = 2;
    STDParams.powerFactor = 2;
    if(strcmp(vidFileName, 'man_running'))
        STDParams.resizeFactors = [1/4, 1/4, 1];
    else
        STDParams.resizeFactors = [1/2, 1/2, 1];
    end
    
    vidStd = generateStdVideo3DFunc(vidMatrixOrig, STDParams);
    vidMatrix = vidStd;
    
elseif(strcmp(STDMethod, 'None'))
    inFileDir = [root,'\results\IterativeDetection\std\vid_std_3d.avi'];
    vidMatrixOrig = readVideoFromFile(inFileDir, false);
    vidMatrix = vidMatrixOrig;
    
else
    error('invalid stdMethod value');
end

%% object detection

[totalMask, maskPyr, detailEnhancementPyr] = maskGenerationFunc(...
    vidMatrix, MaskParams, CCLFParams);

finishTime = datetime('now');
disp(['Done ' datestr(finishTime,'HH:MM:SS')]);

runDuration = finishTime - startTime;
disp(['Took ' datestr(runDuration,'HH:MM:SS')]);

resizedMask = safeResize(totalMask, size(vidMatrixOrig));

%% performance evaluation

groundTruth = readVideoFromFile([root, '\resources\', vidFileName, '_gt.avi'], true);

thresholds = 80:99;
[precisions, recalls, ious] = getEvaluationMetrics(resizedMask, ...
    groundTruth, thresholds, 'prc');
evaluationPlot = plotEvaluationMetrics(thresholds, precisions, recalls, ious);

%% result display

vidMasked = vidMatrixOrig .* resizedMask;
implay(vidMasked);
maintainFitToWindow();

%% parameter saving

if (dumpMovies)
    warning('off');
    if (~strcmp(STDMethod, 'None')) 
        writeVideoToFile(vidStd, ['vid_std_', lower(STDMethod)], [root,'\results\iterativeDetection\std']);
    end
    
    for i=1:MaskParams.iterationNumber
        writeVideoToFile(detailEnhancementPyr{i}, ...
            ['detail_enhanced_',num2str(MaskParams.baseResizeFactors(1)*((i-1)*MaskParams.resizeIncrement+1),'%.3f'),'_'...
            ,num2str(MaskParams.baseResizeFactors(2)*((i-1)*MaskParams.resizeIncrement+1),'%.3f'),'_'...
            ,num2str(MaskParams.baseResizeFactors(3)*((i-1)*MaskParams.resizeIncrement+1),'%.3f')]...
            ,[root,'\results\iterativeDetection\detailEnhancement']);

        writeVideoToFile(maskPyr{i}, ...
            ['mask_',num2str(MaskParams.baseResizeFactors(1)*((i-1)*MaskParams.resizeIncrement+1),'%.3f'),'_'...
            ,num2str(MaskParams.baseResizeFactors(2)*((i-1)*MaskParams.resizeIncrement+1),'%.3f'),'_'...
            ,num2str(MaskParams.baseResizeFactors(3)*((i-1)*MaskParams.resizeIncrement+1),'%.3f')]...
            ,[root,'\results\iterativeDetection\maskGeneration']);
    end
    
    writeVideoToFile(totalMask, 'movie_total_mask', [root,'\results\iterativeDetection\maskGeneration']);
    writeVideoToFile(vidMasked, 'movie_masked', [root,'\results\iterativeDetection']);
    
    saveParams([root,'\results\iterativeDetection'], vidFileName, STDMethod, ...
        STDParams ,CCLFParams, MaskParams, runDuration);
    save([root,'\results\iterativeDetection\params.mat'], 'vidFileName', ...
        'STDMethod', 'STDParams' ,'CCLFParams', 'MaskParams', 'runDuration');
    saveas(evaluationPlot, [root,'\results\iterativeDetection\eval_plots.png']);
end
