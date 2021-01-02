addpath(genpath('utils'));
addpath(genpath('no-grid'));
addpath(genpath('3dGabor'));
archiveResults();
cd 'no-grid';
detail_enhancement_per_frame_IN3D;
cd '..';