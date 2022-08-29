function EnhancedImg = ImgEnhance(AlgParams,InputImg)
% this function enhance the input image by noise reduction and contrast enhacment

% use only first layer of the image and convert to double
InputImgDuoble = double(InputImg(:,:,1));

% normalize to the range [0 1]
InputImgNormalized = InputImgDuoble/max(InputImgDuoble(:));

%% noise reduction
% create average filter
LowPassFilt = ones(AlgParams.LpfSize);
LowPassFilt = LowPassFilt/sum(LowPassFilt(:));

% filter the image
NoisReductImg = imfilter(InputImgNormalized,LowPassFilt ,'symmetric','same');

%% enhace contrast
%EnhancedImg = imadjust(NoisReductImg);
%EnhancedImg = histeq(NoisReductImg);
EnhancedImg = adapthisteq(NoisReductImg);
EnhancedImg = uint8(EnhancedImg*255);

%% shoe results
% % show input and adjust image
% figure;
% subplot(1,2,1); imshow(InputImg); title('Input image');
% subplot(1,2,2); imshow(EnhancedImg); title('Enhance image');
end