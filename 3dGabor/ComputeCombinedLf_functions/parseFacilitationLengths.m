function [spatial_facilitation_length,temporal_facilitation_length] = parseFacilitationLengths(base_facilitation_lengths)
if(length(base_facilitation_lengths) == 2)
    spatial_facilitation_length = base_facilitation_lengths(1);
    temporal_facilitation_length = base_facilitation_lengths(2);
elseif(length(base_facilitation_lengths) == 1)
    spatial_facilitation_length = base_facilitation_lengths;
    temporal_facilitation_length = base_facilitation_lengths;
else
    error('Invalid parameter length, baseFacilitationLengths needs to be of length 1 or 2');
end
end

