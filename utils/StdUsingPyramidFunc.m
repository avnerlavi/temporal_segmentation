function [vidPyr] = StdUsingPyramidFunc(vidIn, params)

vidResized = safeResize(vidIn, params.resizeFactors .* size(vidIn));
    
pyrLevel = 0;

vidPyr = zeros([ceil(size(vidResized,1)/2^pyrLevel)...
    , ceil(size(vidResized,2)/2^pyrLevel), size(vidResized,3)]);

for i = ceil(params.segmentLength/2) : size(vidResized,3) - ceil(params.segmentLength/2)
    temp = GenerateStdImagePyramid2(...
        vidResized(:,:,i-ceil(params.segmentLength/2)+1:i+floor(params.segmentLength/2))...
        , params.pyramidLevel);
    
    vidPyr(:,:,i) = temp{end};
end

vidPyr = vidPyr(:,:,ceil(params.segmentLength/2):size(vidIn,3) - ceil(params.segmentLength/2));
vidPyr = minMaxNorm(vidPyr);
end

