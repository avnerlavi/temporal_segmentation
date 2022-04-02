function [spatial_facilitation_length,temporal_facilitation_length,...
    elevation_norm_0_factor,elevation_norm_factors,...
    total_orientations_number,total_iteration_number] = InputHandle(elevations_number,azimuths_number,scales_number,...
    base_facilitation_lengths,elevation_range,eccentricity)

%halfAngle parsing
if(length(elevation_range) == 2)
    min_angle = elevation_range(1);
    max_angle = elevation_range(2);
elseif(length(elevation_range) == 1)
    min_angle = 0;
    max_angle = elevation_range;
else
    error('Invalid parameter length, elHalfAngle needs to be of length 1 or 2');
end
if(length(base_facilitation_lengths) == 2)
    spatial_facilitation_length = base_facilitation_lengths(1);
    temporal_facilitation_length = base_facilitation_lengths(2);
elseif(length(base_facilitation_lengths) == 1)
    spatial_facilitation_length = base_facilitation_lengths;
    temporal_facilitation_length = base_facilitation_lengths;
else
    error('Invalid parameter length, baseFacilitationLengths needs to be of length 1 or 2');
end
%creating elevations + norm factors
elevations = linspace(min_angle, max_angle, elevations_number);
if length(elevations) > 1 %single elevation norm factor
    delta_elevation = elevations(2)- elevations(1);
else
    delta_elevation = nan;
end
if(min_angle == 0) %0 elev handling
    elevations = elevations(2:end);
    elevation_norm_0_factor = computeElevationNormFactor(0, delta_elevation, ...
        eccentricity, min_angle, max_angle, azimuths_number);
end
elevation_norm_factors = computeElevationNormFactor(elevations, delta_elevation, ...
    eccentricity, min_angle, max_angle, azimuths_number);
%creating azimuths
azimuths = linspace(0,360,azimuths_number+1);
azimuths = azimuths(1:end-1);

total_orientations_number = length(azimuths) * length(elevations) + 1;
total_iteration_number = 2 * scales_number * total_orientations_number;
end

