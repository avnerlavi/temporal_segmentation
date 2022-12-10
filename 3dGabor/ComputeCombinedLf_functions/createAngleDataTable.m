function [angles_data] = createAngleDataTable(azimuths,elevations,varargin)
%parsing
parser = inputParser;
addRequired(parser, 'azimuths');
addRequired(parser, 'elevations');
addParameter(parser, 'additionalElevationData', {}, @iscell);
addParameter(parser, 'additionalElevationNames', {}, @iscell);
addParameter(parser, 'additionalAzimuthData', {}, @iscell);
addParameter(parser, 'additionalAzimuthNames', {}, @iscell);

parse(parser, azimuths, elevations, varargin{:});
azimuths_number = length(azimuths);
elevations_number = length(elevations);
%validating
if(length(parser.Results.additionalElevationData) ~= length(parser.Results.additionalElevationNames) ...
        || length(parser.Results.additionalAzimuthData) ~= length(parser.Results.additionalAzimuthNames))
    error('Data and name arrays need to have the same length')
end
%building table
[azimuth_mat,elevation_mat] = meshgrid(azimuths,elevations);
angles_data = table(azimuth_mat(:),elevation_mat(:),'VariableNames',{'azimuth','elevation'});
for i=1:length(parser.Results.additionalElevationData)
    variable_data = parser.Results.additionalElevationData{i};
    if(length(variable_data)==elevations_number)
        variable_data = repmat(variable_data,[1,azimuths_number]);
    elseif(length(variable_data)==1)
        variable_data = variable_data*ones(size(angles_data,1),1);
    else
        error('All additional Elevation data need to have the same number of entries as elevations, or be a constant.')
    end
    angles_data.(parser.Results.additionalElevationNames{i}) = variable_data(:);
end
for i=1:length(parser.Results.additionalAzimuthData)
    variable_data = parser.Results.additionalAzimuthData{i};
    if(length(variable_data)==azimuths_number)
        variable_data = repmat(variable_data,[elevations_number,1]);
    elseif(length(variable_data)==1)
        variable_data = variable_data*ones(size(angles_data,1),1);
    else
        error('All additional Azimuth data need to have the same number of entries as azimuths, or be a constant.')
    end
    angles_data.(parser.Results.additionalAzimuthNames{i}) = variable_data(:);
end

%removing zero duplication
% zero_el = angles_data(angles_data.elevation==0,:);
% first_azimuth = zero_el(1,:).azimuth;
% angles_data(angles_data.elevation==0 & angles_data.azimuth~=first_azimuth,:)=[];

end

