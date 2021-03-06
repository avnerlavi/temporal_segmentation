function StdPyramid = GenerateStdImagePyramid(Iseq,N)

    StdPyramid = cell(1,N+2);

    BlurredPyramid{1} = Iseq;
    seq_middle = ceil(size(Iseq,3)./2);
    S3 = std(stdfilt(Iseq(:,:,seq_middle + (-1:1)),ones(15)),0,3); 
    S5 = std(stdfilt(Iseq(:,:,seq_middle + (-2:2)),ones(15)),0,3);
    S7 = std(stdfilt(Iseq(:,:,seq_middle + (-3:3)),ones(15)),0,3);
    S1 = stdfilt(Iseq(:,:,seq_middle),ones(15));

    StdPyramid{1} = S3+S5+S7-S1;

    for i=2:N+1
        Ip = BlurredPyramid{i-1};
        BlurredPyramid{i} = impyramid(Ip, 'reduce');
        n = floor(15./(i-1));
        if(mod(n,2) == 0)
            n = n + 1;
        end
        StdPyramid{i} = std(stdfilt(Ip,ones(n)),0,3) - stdfilt(Ip(:, :, seq_middle),ones(n));

    end

    ResizedImage = zeros(size(StdPyramid{2}));
    gamma = 1;
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




