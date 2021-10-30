load('baby_LF_threshold_data.mat');
nElevations = 7;
nAzimuths = 8;
nScales = 4;
zeros_vec = 1:(nElevations-1)*nAzimuths+1:((nElevations-1)*nAzimuths+1)*nScales;

LF_n_tensor = LF_n;
LF_p_tensor = LF_p;
LF_n_tensor(zeros_vec)=[];
LF_p_tensor(zeros_vec)=[];
LF_n_tensor = reshape(LF_n_tensor ,nScales,nElevations-1,nAzimuths);
LF_p_tensor = reshape(LF_p_tensor ,nScales,nElevations-1,nAzimuths);

LF_n_zeros = LF_n(zeros_vec);
LF_p_zeros = LF_p(zeros_vec);

figure()
subplot(2,1,1)
plot(1./(1:nScales),mean(LF_n_tensor,[2,3])...
    ,1./(1:nScales),min(LF_n_tensor,[],[2,3])...
    ,1./(1:nScales),max(LF_n_tensor,[],[2,3]))
title('LF_n')
subplot(2,1,2)
plot(1./(1:nScales),mean(LF_p_tensor,[2,3])...
    ,1./(1:nScales),min(LF_p_tensor,[],[2,3])...
    ,1./(1:nScales),max(LF_p_tensor,[],[2,3]))
title('LF_p')
suptitle('by scale')

figure()
subplot(2,1,1)
plot(1:(nElevations-1),mean(LF_n_tensor,[1,3])...
    ,1:(nElevations-1),min(LF_n_tensor,[],[1,3])...
    ,1:(nElevations-1),max(LF_n_tensor,[],[1,3]))
title('LF_n')
subplot(2,1,2)
plot(1:(nElevations-1),mean(LF_p_tensor,[1,3])...
    ,1:(nElevations-1),min(LF_p_tensor,[],[1,3])...
    ,1:(nElevations-1),max(LF_p_tensor,[],[1,3]))
title('LF_p')
suptitle('by elevation')

figure()
subplot(2,1,1)
plot(1:nAzimuths,squeeze(mean(LF_n_tensor,[1,2]))...
    ,1:nAzimuths,squeeze(min(LF_n_tensor,[],[1,2]))...
    ,1:nAzimuths,squeeze(max(LF_n_tensor,[],[1,2])))
title('LF_n')
subplot(2,1,2)
plot(1:nAzimuths,squeeze(mean(LF_p_tensor,[1,2]))...
    ,1:nAzimuths,squeeze(min(LF_p_tensor,[],[1,2]))...
    ,1:nAzimuths,squeeze(max(LF_p_tensor,[],[1,2])))
title('LF_p')
suptitle('by azimuths')

figure()
subplot(2,1,1)
plot(1./(1:nScales),LF_n_zeros)
title('LF_n')
subplot(2,1,2)
plot(1./(1:nScales),LF_p_zeros)
title('LF_p')
suptitle('zeros by scale')