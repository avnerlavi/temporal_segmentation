function [stdDiff, temporalStdVid] = computeStdDiffFeature(spatialStdVid, temporalVar, azimuth, elevation)
temporalStdVid = Std3DActivation(spatialStdVid, temporalVar, azimuth, elevation);
stdDiff = max(minMaxNorm(spatialStdVid) - minMaxNorm(temporalStdVid), 0);
end

