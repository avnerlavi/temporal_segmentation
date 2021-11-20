load('thresholding_data_cell.mat')
index = 4;
threshold_data = thresholding_data_cell{index,2};
[scales_g,scales] = findgroups(threshold_data(:,1));
[azimuths_g,azimuths] = findgroups(threshold_data(:,2));
[elevations_g,elevations] = findgroups(threshold_data(:,3));
figure()
subplot(2,1,1)
plot(scales,splitapply(@mean,threshold_data(:,4),scales_g),...
    scales,splitapply(@min,threshold_data(:,4),scales_g),...
    scales,splitapply(@max,threshold_data(:,4),scales_g))
title('LF_n')
legend('average','min','max')
subplot(2,1,2)
plot(scales,splitapply(@mean,threshold_data(:,5),scales_g),...
    scales,splitapply(@min,threshold_data(:,5),scales_g),...
    scales,splitapply(@max,threshold_data(:,5),scales_g))
title('LF_p')
legend('average','min','max')
suptitle('by scale')

figure()
subplot(2,1,1)
plot(azimuths,splitapply(@mean,threshold_data(:,4),azimuths_g),...
    azimuths,splitapply(@min,threshold_data(:,4),azimuths_g),...
    azimuths,splitapply(@max,threshold_data(:,4),azimuths_g))
title('LF_n')
legend('average','min','max')
subplot(2,1,2)
plot(azimuths,splitapply(@mean,threshold_data(:,5),azimuths_g),...
    azimuths,splitapply(@min,threshold_data(:,5),azimuths_g),...
    azimuths,splitapply(@max,threshold_data(:,5),azimuths_g))
title('LF_p')
legend('average','min','max')
suptitle('by azimuth')

figure()
subplot(2,1,1)
plot(elevations,splitapply(@mean,threshold_data(:,4),elevations_g),...
    elevations,splitapply(@min,threshold_data(:,4),elevations_g),...
    elevations,splitapply(@max,threshold_data(:,4),elevations_g))
title('LF_n')
legend('average','min','max')
subplot(2,1,2)
plot(elevations,splitapply(@mean,threshold_data(:,5),elevations_g),...
    elevations,splitapply(@min,threshold_data(:,5),elevations_g),...
    elevations,splitapply(@max,threshold_data(:,5),elevations_g))
title('LF_p')
legend('average','min','max')
suptitle('by elevation')
%%
for i = 1:size(thresholding_data_cell,1)
    thresholds(i) = thresholding_data_cell{i,1};
    thresholding_data = thresholding_data_cell{i,2};
    average_n(i) = mean(thresholding_data(2:end,4));
    std_n(i) = std(thresholding_data(2:end,4));
    average_p(i) = mean(thresholding_data(2:end,5));
    std_p(i) = std(thresholding_data(2:end,5));
end
figure()
errorbar(thresholds,average_n,std_n)
hold on
errorbar(thresholds,average_p,std_p)
legend('LF_n','LF_p')
figure()
errorbar(log(thresholds),average_n,std_n)
hold on
errorbar(log(thresholds),average_p,std_p)
legend('LF_n','LF_p')