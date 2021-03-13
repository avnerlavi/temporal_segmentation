function [CC_matrix] = colorVideoCC(binaryVidIn)
inputSize = size(binaryVidIn);
CC_matrix = zeros([inputSize(1), inputSize(2), 3, inputSize(3)]);
CC = bwconncomp(binaryVidIn);
randColors = zeros(CC.NumObjects, 3);
for i=1:CC.NumObjects
   randColors(i, :) = [rand(), rand(), rand()];
end

for i=1:CC.NumObjects    
    [x,y,t] = ind2sub(size(binaryVidIn), CC.PixelIdxList{i});
    for j=1:length(t)
        CC_matrix(x(j),y(j),:,t(j)) = randColors(i, :);   
    end
end
end

