%% DE setup
root = getenv('TemporalSegmentation');
addpath(genpath([root,'/utils']));
addpath(genpath([root,'/3dGabor']));
addpath(genpath([root,'/HDR']));
elevationHalfAngle = [0, 90];
resizeFactors = [1/4, 1/4, 1/4];
inFileDir = [root ,'/resources/ultrasound_1_cropped.avi'];

vid_matrix = readVideoFromFile(inFileDir, false);

CCLFParams = struct;
CCLFParams.resizeFactors = [1/4,1/4,1/4];
CCLFParams.numOfScales = 4;
CCLFParams.elevationHalfAngle = atand(tand(elevationHalfAngle) * resizeFactors(1) / resizeFactors(3));
CCLFParams.azimuthNum = 8;
CCLFParams.elevationNum = 7;
CCLFParams.eccentricity = sqrt(1);
CCLFParams.activationThreshold = 0.03;
CCLFParams.facilitationLengths = [10, 5];
CCLFParams.alpha = 0.5;
CCLFParams.m1 = 1;
CCLFParams.m2 = 2;
CCLFParams.normQ = 2;
%% DE
c1 = 1/8;
c2 = 1/8;
V = 1/4;

[vid_ste] = softTissueEnhancementOverFrames(vid_matrix,c1,c2,V);
[vid_resized_reg,response_reg] = detailEnhancement3Dfunc(vid_matrix,CCLFParams,false);
[vid_resized_ste,response_ste] = detailEnhancement3Dfunc(vid_ste,CCLFParams,false);
%% hist plots
beta = 1.5;
gain = 1;

[hist_response_reg_by_reg,edges] = response_histogram(vid_resized_reg,response_reg,false);
[hist_response_ste_by_reg,edges] = response_histogram(vid_resized_reg,response_ste,false);
disp_hists = [hist_response_reg_by_reg',hist_response_ste_by_reg'];
figure()
bar(edges,disp_hists)
legend('DE regular','DE ste by regular')
[vid_combined_reg] = additiveCombination(vid_resized_reg, response_reg, beta, gain);
[vid_combined_ste] = additiveCombination(vid_resized_reg, response_ste, beta, gain);
[hist_combined_reg_by_reg,edges] = response_histogram(vid_resized_reg,vid_combined_reg-vid_resized_reg,false);
[hist_combined_ste_by_reg,edges] = response_histogram(vid_resized_reg,vid_combined_ste-vid_resized_reg,false);
disp_hists = [hist_combined_reg_by_reg',hist_combined_ste_by_reg'];
figure()
bar(edges,disp_hists)
%% videos
%% saving params


