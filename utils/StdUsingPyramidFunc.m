function [vidPyr] = StdUsingPyramidFunc(vidIn, params)

dims = params.resizeFactors .* size(vidIn);
vidResized = safeResize(vidIn, dims);
vidPyr = zeros([size(vidResized, 1), size(vidResized, 2)...
    , size(vidResized, 3) + params.segmentLength]);

for i = ceil(params.segmentLength/2) : size(vidResized,3) - ceil(params.segmentLength/2)
    temp = GenerateStdImagePyramid2(...
        vidResized(:,:,i-ceil(params.segmentLength/2)+1:i+floor(params.segmentLength/2))...
        , params.pyramidLevel);
    
    vidPyr(:,:,i) = temp{end};
end

vidPyr = vidPyr(:,:,ceil(params.segmentLength/2):end - ceil(params.segmentLength/2));
vidPyr = minMaxNorm(vidPyr);
end

