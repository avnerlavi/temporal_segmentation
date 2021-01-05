root = getenv('TemporalSegmentation');
addpath(genpath([root,'\utils']));
addpath(genpath([root,'no-grid']));
addpath(genpath([root,'3dGabor']));
archiveResults();
detail_enhancement_per_frame_IN3D;