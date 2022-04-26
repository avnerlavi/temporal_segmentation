function ...
    [elevations,...
    azimuths,...
    cclf_params,...
    elevation_norm_factors,...
    total_orientations_number,...
    total_iteration_number] = InputHandle(...
    elevations_number,...
    azimuths_number,...
    scales_number,...
    base_facilitation_lengths...
    ,elevation_range...
    ,eccentricity)

cclf_params = struct;

%halfAngle parsing
if(length(elevation_range) == 2)
    cclf_params.min_angle = elevation_range(1);
    cclf_params.max_angle = elevation_range(2);
elseif(length(elevation_range) == 1)
    cclf_params.min_angle = 0;
    cclf_params.max_angle = elevation_range;
else
    error('Invalid parameter length, elHalfAngle needs to be of length 1 or 2');
end
cclf_params.is_zero_elevation = min_angle == 0;
if(length(base_facilitation_lengths) == 2)
    cclf_params.spatial_facilitation_length = base_facilitation_lengths(1);
    cclf_params.temporal_facilitation_length = base_facilitation_lengths(2);
elseif(length(base_facilitation_lengths) == 1)
    cclf_params.spatial_facilitation_length = base_facilitation_lengths;
    cclf_params.temporal_facilitation_length = base_facilitation_lengths;
else
    error('Invalid parameter length, baseFacilitationLengths needs to be of length 1 or 2');
end
%creating elevations + norm factors
elevations = linspace(min_angle, max_angle, elevations_number);
if length(elevations) > 1 %single elevation norm factor
    cclf_params.delta_elevation = elevations(2)- elevations(1);
else
    cclf_params.delta_elevation = nan;
end
if(cclf_params.is_zero_elevation) %0 elev handling
    elevations = elevations(2:end);
    elevation_norm_0_factor = computeElevationNormFactor(0, cclf_params.delta_elevation, ...
        eccentricity, min_angle, max_angle, azimuths_number);
end
elevation_norm_factors = computeElevationNormFactor(elevations, cclf_params.delta_elevation, ...
    eccentricity, min_angle, max_angle, azimuths_number);
elevation_norm_factors(end+1) = elevation_norm_0_factor;
%creating azimuths
azimuths = linspace(0,360,azimuths_number+1);
azimuths = azimuths(1:end-1);

total_orientations_number = length(azimuths) * length(elevations) + 1;
total_iteration_number = 2 * scales_number * total_orientations_number;
end

