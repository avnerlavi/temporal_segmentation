function [elevationNormFactor] = computeElevationNormFactor(Elevations, dElevation, eccentricity, ElevationMin, ElevationMax, nAzimuths)

if(ElevationMin == ElevationMax)
    elevationNormFactor = 1;
    return;
end
elevationStart = max(Elevations - dElevation/2, ElevationMin);
elevationEnd   = min(Elevations + dElevation/2, ElevationMax);
areaNormFactor = cosd(elevationStart) - cosd(elevationEnd);
areaNormFactor(Elevations==0) = areaNormFactor(Elevations==0).*nAzimuths; 
%areaNormFactor = areaNormFactor./sum(areaNormFactor);
stNormFactor = computeEllipsoidRadius(Elevations, eccentricity, 1);
%stNormFactor = stNormFactor./sum(stNormFactor);
elevationNormFactor = areaNormFactor.*stNormFactor;
%elevationNormFactor = elevationNormFactor./sum(elevationNormFactor);
%     figure()
%     plot(Elevations,areaNormFactor,Elevations,stNormFactor,Elevations,elevationNormFactor)
%     legend('area','space-time','total')
end

