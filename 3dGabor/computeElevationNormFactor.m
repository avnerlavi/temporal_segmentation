function [normFactor] = computeElevationNormFactor(Elevations, dElevation, a)
if length(Elevations) > 1
    elevationStart = Elevations(j) - dElevation/2;
    elevationEnd = min(Elevations(j) + dElevation/2, Elevations(end));
    elevationNormFactor = sqrt(a*cosd(Elevations(j))^2 + sind(Elevations(j))^2)*(cosd(elevationStart) - cosd(elevationEnd));
else
    elevationNormFactor = 1;
end
end

