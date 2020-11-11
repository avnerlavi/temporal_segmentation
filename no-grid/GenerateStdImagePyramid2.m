function StdPyramid = GenerateStdImagePyramid(Iseq,N)
NRSigma = 2;
NRPow = 2;
FiltSize = 5;
    StdPyramid = cell(1,N+2);

    BlurredPyramid{1} = Iseq;
     seq_middle = ceil(size(Iseq,3)./2);
%     S3 = std(stdfilt(Iseq(:,:,seq_middle + (-1:1)),ones(FiltSize)),0,3); 
%     S5 = std(stdfilt(Iseq(:,:,seq_middle + (-2:2)),ones(FiltSize)),0,3);
%     S7 = std(stdfilt(Iseq(:,:,seq_middle + (-3:3)),ones(FiltSize)),0,3);
%     S1 = stdfilt(Iseq(:,:,seq_middle),ones(FiltSize));
% 
%     StdPyramid{1} = S3+S5+S7-S1;

    for i=2:N+1
        Ip = BlurredPyramid{i-1};
        BlurredPyramid{i} = impyramid(Ip, 'reduce');
        n = floor(FiltSize./(i-1));
%         if(mod(n,2) == 0)
%             n = n + 1;
%         end
        
        %StdPyramid{i} = (stdfilt(Ip(:, :, seq_middle),ones(FiltSize)).^NRPow)./(std(stdfilt(Ip,ones(FiltSize)),0,3).^NRPow+NRSigma);
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