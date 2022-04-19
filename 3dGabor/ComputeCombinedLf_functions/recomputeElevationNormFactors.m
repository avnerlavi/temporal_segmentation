function [elevation_norm_factors] = recomputeElevationNormFactors(elevations,is_zero_elevation,eccentricity,min_angle,max_angle,azimuths_number)
if length(elevations) > 1 %single elevation norm factor
    delta_elevation = elevations(2)- elevations(1);
else
    delta_elevation = nan;
end
elevation_norm_factors = computeElevationNormFactor(elevations, delta_elevation, ...
    eccentricity, min_angle, max_angle, azimuths_number);
if(is_zero_elevation) %0 elev handling
    elevation_norm_0_factor = computeElevationNormFactor(0, delta_elevation, ...
        eccentricity, min_angle, max_angle, azimuths_number);
    elevation_norm_factors = [elevation_norm_0_factor,elevation_norm_factors(2:end)];
end

end

