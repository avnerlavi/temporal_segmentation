function [elevations,azimuths,is_zero_elevation] = createAzElArrays(elevations_number,azimuths_number,elevation_range)
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
%creating elevations
elevations = linspace(min_angle, max_angle, elevations_number);
is_zero_elevation = min_angle == 0;
% if(is_zero_elevation == 0) %0 elev handling
%     elevations = elevations(2:end);
% end
%creating azimuths
azimuths = linspace(0,360,azimuths_number+1);
azimuths = azimuths(1:end-1);
end

