function [ImageOut,W] = softTissueEnhancementPerFrame(ImageIn)
c1 = 1/2;
c2 = 1/2;
V = 0.38;
W_high = 4*c1*(ImageIn-V).*(max(ImageIn,[],'all')-ImageIn);
W_high = W_high./(max(ImageIn,[],'all')-V).^2;

W_low = -4*c2*(V-ImageIn).*(ImageIn);
W_low = W_low./(3*V.^2);
W = W_high.*double(ImageIn>=V)+W_low.*double(ImageIn<V);
%ImageOut = W;
[~,k_remote] = calculateRemoteLocalFilters(1*sqrt(2),3*sqrt(2),3,9);
k_remote = k_remote/max(k_remote,[],'all');
G = imfilter(ImageIn,k_remote);
ImageOut = ImageIn+W.*G/max(G,[],'all');
end

