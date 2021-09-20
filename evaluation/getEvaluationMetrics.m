function [precisions, recalls, ious] = getEvaluationMetrics(vidIn, groundTruth, ...
    thresholds, mode)

w = parfor_wait(length(thresholds), 'Waitbar', true);
progressCounter = 0;

groundTruth = logical(groundTruth);

ious = zeros(size(thresholds));
precisions = zeros(size(thresholds));
recalls = zeros(size(thresholds));

parfor i=1:length(thresholds)
    if(strcmp(mode, 'th'))
        vidThresholded = vidIn > thresholds(i);
    elseif(strcmp(mode, 'prc'))
        percentileThreshold = prctile(vidIn, thresholds(i), 'all');
        vidThresholded = vidIn > percentileThreshold;
    else
        error('invalid thresholding mode');
    end
   
   intersection = and(vidThresholded, groundTruth);
   union = or(vidThresholded, groundTruth);
   ious(i) = sum(intersection, 'all') ./ sum(union, 'all');
   
   precisions(i) = sum(intersection, 'all') ./ sum(vidThresholded, 'all');
   if (isnan(precisions(i)))
       precisions(i) = 0;
   end
   
   recalls(i) = sum(intersection, 'all') ./ sum(groundTruth, 'all');

   w.Send;
%    waitbar(progressCounter / length(thresholds), w);
end

w.Destroy;
% close(w);
end

