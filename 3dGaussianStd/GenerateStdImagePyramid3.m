function StdPyramid = GenerateStdImagePyramid3(vid,N)
sigmaL = [5,5,9];
sigmaS = [5,5,0.1];
sigmaT = [0.1,0.1,9];
StdPyramid = cell(1,N+2);
BlurredPyramid = cell(1,N+1);

BlurredPyramid{1} = vid;
Glong = Gaussian3D([0,0],0,sigmaL,[]);
Gshort = Gaussian3D([0,0],0,sigmaS,[]);
Gtime = Gaussian3D([0,0],0,sigmaT,[]);
for i=2:N+1
    Ip = BlurredPyramid{i-1};
    BlurredPyramid{i} = impyramid(Ip, 'reduce');
%     M2Long = imfilter(Ip.^2,Glong);
%     M1Long = imfilter(double(Ip),Glong).^2;
%     varLong = M2Long-M1Long;
    M2Short = imfilter(Ip.^2,Gshort);
    M1Short = imfilter(double(Ip),Gshort).^2;
    %varShort = M2Short-M1Short;
    stdShort = sqrt(M2Short-M1Short);
    M2Time = imfilter(stdShort.^2,Gtime);
    M1Time = imfilter(stdShort,Gtime).^2;
    stdTime = sqrt(M2Time-M1Time);
    StdPyramid{i} = stdShort - stdTime;
%     StdPyramid{i} = sqrt(abs(varShort)) - sqrt(abs(varLong));
end

ResizedImage = zeros(size(StdPyramid{2}));
gamma = 2;
for i = 2:N+1
    M2Long = imresize3(StdPyramid{i}, size(StdPyramid{2}));
    ResizedImage = ResizedImage + ((abs(M2Long).^gamma) .* sign(M2Long)) ./ 2.^(i);
end
StdPyramid{N+2} = ResizedImage;
end

% function Inorm = Norm(I)
%     I = I - min(I(:));
%     Inorm = I./max(I(:));
% end