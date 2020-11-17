function StdPyramid = GenerateStdImagePyramid2(Iseq,N)
FiltSize = 5;
StdPyramid = cell(1,N+2);
BlurredPyramid = cell(1,N+1);

BlurredPyramid{1} = Iseq;
seq_middle = ceil(size(Iseq,3)./2);

for i=2:N+1
    Ip = BlurredPyramid{i-1};
    BlurredPyramid{i} = impyramid(Ip, 'reduce');
%     n = floor(FiltSize./(i-1));
%     if(mod(n,2) == 0)
%         n = n + 1;
%     end
    
    StdPyramid{i} = stdfilt(Ip(:, :, seq_middle),ones(FiltSize))-(std(stdfilt(Ip,ones(FiltSize)),0,3));
end

ResizedImage = zeros(size(StdPyramid{2}));
gamma = 2;
for i = 2:N+1
    temp = imresize(StdPyramid{i}, size(StdPyramid{2}));
    ResizedImage = ResizedImage + ((abs(temp).^gamma) .* sign(temp)) ./ 2.^(i);
end
StdPyramid{N+2} = ResizedImage;
end

% function Inorm = Norm(I)
%     I = I - min(I(:));
%     Inorm = I./max(I(:));
% end