%% initilization
disp(['Start ', datestr(datetime('now'),'HH:MM:SS')]);
dump_movies = true;

root = getenv('TemporalSegmentation');
addpath(genpath([root,'/utils']));
addpath(genpath([root,'/3dGabor']));
addpath(genpath([root,'/3dGaussianStd']));

STDParams = struct;
STDMethod = '3D';
if(strcmp(STDMethod, 'Pyr'))
    inFileDir = [root,'\resources\horse_running.avi'];
    vid_matrix_orig = readVideoFromFile(inFileDir, false);
    
    STDParams.resizeFactors = [1/2, 1/2, 1];
    vid_matrix = safeResize(vid_matrix_orig, ...
        STDParams.resizeFactors .* size(vid_matrix_orig));
    
    vid_std = StdUsingPyramidFunc(vid_matrix);
    vid_matrix = vid_std;
    
elseif(strcmp(STDMethod, '3D'))
    inFileDir = [root,'\resources\horse_running.avi'];
    vid_matrix_orig = readVideoFromFile(inFileDir, false);
    
    STDParams.numOfScales = 4;
    STDParams.elevationHalfAngle = 60;
    STDParams.azimuthNum = 4;
    STDParams.elevationNum = 4;
    STDParams.sigmaSpatial = [3, 3, 0.1];
    STDParams.sigmaTemporal = [0.1, 0.1, 7];
    STDParams.m1 = 1;
    STDParams.m2 = 2;
    STDParams.resizeFactors = [1/2, 1/2, 1];
    
    vid_std = generateStdVideo3DFunc(vid_matrix_orig, STDParams);
    vid_matrix = vid_std;
    
elseif(strcmp(STDMethod, 'None'))
    inFileDir = [root,'\results\3dStd\movie_vid_std_3d.avi'];
    vid_matrix_orig = readVideoFromFile(inFileDir, false);
    vid_matrix = vid_matrix_orig;
    
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
CCLFParams.numOfScales = 4;
CCLFParams.elevationHalfAngle = 60;
CCLFParams.azimuthNum = 8;
CCLFParams.elevationNum = 7;
CCLFParams.facilitationLength = 16;
CCLFParams.alpha = 0;
CCLFParams.m1 = 1;
CCLFParams.m2 = 1;
CCLFParams.resizeFactors = MaskParams.baseResizeFactors;

[totalMask, maskPyr] = maskGenerationFunc(vid_matrix, MaskParams, CCLFParams);

%% test 

implay(vid_matrix_orig .* safeResize(totalMask, size(vid_matrix_orig)));
maintainFitToWindow();

disp(['Done ' datestr(datetime('now'),'HH:MM:SS')]);
if (dump_movies)
    if (~strcmp(STDMethod, 'None')) 
        writeVideoToFile(vid_std, 'vid_std', [root,'\results\iterativeDetection\std']);
    end

    writeVideoToFile(totalMask, 'movie_total_mask', [root,'\results\iterativeDetection\iterative_mask']);
    for i=1:MaskParams.iterationNumber
        writeVideoToFile(maskPyr{i}, ['movie_mask_',num2str(MaskParams.baseResizeFactors(1)*((i-1)*MaskParams.resizeIncrement+1),'%.3f'),'_'...
                                                   ,num2str(MaskParams.baseResizeFactors(2)*((i-1)*MaskParams.resizeIncrement+1),'%.3f'),'_'...
                                                   ,num2str(MaskParams.baseResizeFactors(3)*((i-1)*MaskParams.resizeIncrement+1),'%.3f')]...
                                                   ,[root,'\results\iterativeDetection\iterative_mask']);
    end
    
    saveParams([root,'\results\iterativeDetection\iterative_mask'],STDMethod, STDParams ... 
        ,CCLFParams, MaskParams);
    save([root,'\results\iterativeDetection\iterative_mask\params.mat'],'STDMethod', 'STDParams' ... 
        ,'CCLFParams','MaskParams');
end
