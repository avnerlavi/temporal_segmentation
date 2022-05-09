function [vidOut] = detailEnhancement3Dfunc(vidIn, Params, frames, verbose)

%TODO: check input validity to structs
%TODO: merge with computecombinedLF
resizeFactors = Params.resizeFactors;

vidIn = safeResize(vidIn, resizeFactors.*size(vidIn));
elevationHalfAngle = atand(tand(Params.elevationHalfAngle) * resizeFactors(1) / resizeFactors(3));

vidOut = ...
    computeCombinedLF_IN3D(vidIn, ...
    Params.azimuthNum, ...
    Params.elevationNum, ... 
    elevationHalfAngle, ...
    Params.numOfScales , ...
    Params.thresholdFraction, ...
    Params.percentileThreshold, ...
    Params.facilitationLength, ... 
    Params.alpha, ... 
    Params.m1, ...
    Params.m2, ...
    Params.normQ, ...
    Params.snapshotDir, ...
    frames ...
    );

if verbose 
    normFactor = max(abs(vidOut),[],'all');
    vidDisp = vidOut./(2*normFactor) +1/2;
    implay(vidDisp)
    maintainFitToWindow();
    disp(['max abs  = ',normFactor])
end

end

