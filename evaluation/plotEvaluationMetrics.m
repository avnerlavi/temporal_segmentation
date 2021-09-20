function plotHandle = plotEvaluationMetrics(thresholds, precisions, recalls, ious)
figure;
subplot(2,2,1);
plot(thresholds, precisions);
xlim([min(thresholds), max(thresholds)]);
xlabel('threshold');
ylim([0, 1]);
ylabel('precision');

subplot(2,2,2);
plot(thresholds, recalls);
xlim([min(thresholds), max(thresholds)]);
xlabel('threshold');
ylim([0, 1]);
ylabel('recall');

subplot(2,2,3);
plot(thresholds, ious);
xlim([min(thresholds), max(thresholds)]);
xlabel('threshold');
ylim([0, 1]);
ylabel('IoU');

subplot(2,2,4);
plot(recalls, precisions);
xlim([0, 1]);
xlabel('recall');
ylim([0, 1]);
ylabel('precision');

plotHandle = get(groot,'CurrentFigure');
end