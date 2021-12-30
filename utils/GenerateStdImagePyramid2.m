function StdPyramid = GenerateStdImagePyramid2(Iseq, N, gamma)
FiltSize = 5;
StdPyramid = cell(1,N+2);
BlurredPyramid = cell(1,N+1);

BlurredPyramid{1} = Iseq;
seq_middle = ceil(size(Iseq,3)./2);

for i=2:N+1
    Ip = BlurredPyramid{i-1};
    BlurredPyramid{i} = impyramid(Ip, 'reduce');
    spatialVar = stdfilt(Ip,ones(FiltSize));
    temporalMedian = median(spatialVar, 3);
    temporalStd = std(spatialVar, 0, 3);
    StdPyramid{i} = temporalMedian - temporalStd;
end

ResizedImage = zeros(size(StdPyramid{2}));
for i = 2:N+1
    temp = imresize(StdPyramid{i}, size(StdPyramid{2}));
    ResizedImage = ResizedImage + ((abs(temp).^gamma) .* sign(temp)) ./ 2.^(i);
end
StdPyramid{N+2} = ResizedImage;
end