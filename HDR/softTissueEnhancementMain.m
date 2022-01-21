root = getenv('TemporalSegmentation');
addpath(genpath([root,'/utils']));
c1 = 0.18;
c2 = 0.18;
V = 0.25;
sigma = [16,4,2,1,0.5,0.125];% run all params later
dir = datestr(now,'dd-mm-yyyy-HH_MM');
inFileDir = [root ,'/resources/ultrasound_1_cropped.avi'];
vid_matrix = readVideoFromFile(inFileDir, false);
[vid_ste] = softTissueEnhancementOverFrames(vid_matrix,c1,c2,V,sigma);
[d,t] = compareVids(vid_matrix,minMaxNorm(vid_ste));
%%
writeVideoToFile(minMaxNorm(vid_ste),'out',[root,'\results\SoftTissueEnhacement\',dir,'\']);
writeVideoToFile(t,'comparison',[root,'\results\SoftTissueEnhacement\',dir,'\']);
saveParams([root,'\results\SoftTissueEnhacement\',dir,'\'],c1,c2,V,sigma);