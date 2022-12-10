function [vid_out_scaled, vid_scales_pyramid,threshold_data] = computeCombinedLf3d(vid_in, nAzimuths ...
    , nElevations, elHalfAngle, eccentricity, nScales, base_activation_threshold, base_facilitation_lengths ...
    , alpha, m1, m2, q_norm)
addpath(genpath(['./ComputeCombinedLf_functions']));
w = waitbar(0, 'starting per-resolution LF computation');
progress_counter = 0;
vid_in = PadVideoReplicate(vid_in,2*nScales);

vid_out_scaled = zeros(size(vid_in));
vid_scales_pyramid = cell(nScales);
%halfAngle parsing

[elevations,azimuths,is_zero_elevation] = createAzElArrays(nElevations,nAzimuths,elHalfAngle);
is_zero_elevation = false;
[spatial_facilitation_length,temporal_facilitation_length] = parseFacilitationLengths(base_facilitation_lengths);
[elevation_norm_factors] = recomputeElevationNormFactors(elevations,is_zero_elevation,eccentricity,elHalfAngle(1),elHalfAngle(end),nAzimuths);
total_orientations_number = length(azimuths) * (length(elevations));
total_iteration_number = 3 * nScales * total_orientations_number;

threshold_data = zeros(5,total_iteration_number/3);

for k = 1:nScales
    vid_in_scaled = safeResize(vid_in , [1/k, 1/k, 1/k] .* size(vid_in));
    vid_ori_n = zeros(size(vid_in_scaled));
    vid_ori_p = zeros(size(vid_in_scaled));
    curr_temp_fl = max(3, temporal_facilitation_length/k);
    curr_spat_fl = max(3, spatial_facilitation_length/k);
    facilitation_lengths = computeEllipsoidRadius(elevations, curr_temp_fl, curr_spat_fl);
    
    [angles_data] = createAngleDataTable(azimuths,elevations,...
        'additionalElevationData',{elevation_norm_factors,facilitation_lengths},...
        'additionalElevationNames',{'norm_factor','facilitation_length'});
    c_p_power_sum = zeros(size(vid_in_scaled));
    c_n_power_sum = zeros(size(vid_in_scaled));
    %power sum computation
    waitbar(progress_counter / total_iteration_number, w,['scale ',num2str(k),' power sum computation']);
    for i = 1:size(angles_data,1)
            [c_p,c_n] = calcGaborResponse(vid_in_scaled, angles_data.azimuth(i), angles_data.elevation(i));
            c_p_power_sum = c_p_power_sum + c_p.^q_norm;% todo-check that c_p/c_n are positive
            c_n_power_sum = c_n_power_sum + c_n.^q_norm;
            progress_counter = progress_counter + 1;
            waitbar(progress_counter / total_iteration_number, w);
    end
    activation_threshold_p = -inf;
    activation_threshold_n = -inf;
    %normalized threshold computation
    waitbar(progress_counter / total_iteration_number, w, ['scale ',num2str(k),' normalized threshold computation']);
    for i = 1:size(angles_data,1)
            [c_p,c_n] = calcGaborResponse(vid_in_scaled, angles_data.azimuth(i), angles_data.elevation(i));
            c_n_norm_factor = 1 + (c_n_power_sum - abs(c_n).^q_norm).^(1/q_norm);
            c_p_norm_factor = 1 + (c_p_power_sum - abs(c_p).^q_norm).^(1/q_norm);
            c_p_normed = c_p ./ c_p_norm_factor;
            c_n_normed = c_n ./ c_n_norm_factor;
            activation_threshold_p = max(max(c_p_normed(8:end-7,8:end-7,8:end-7),[],'all'),activation_threshold_p);
            activation_threshold_n = max(max(c_n_normed(8:end-7,8:end-7,8:end-7),[],'all'),activation_threshold_n);
            progress_counter = progress_counter + 1;
            waitbar(progress_counter / total_iteration_number, w);
    end
    %threshold
    activation_threshold_p = base_activation_threshold * activation_threshold_p;
    activation_threshold_n = base_activation_threshold * activation_threshold_n;
    total_activation_threshold = [activation_threshold_p, activation_threshold_n];
    
    % LF activation
    waitbar(progress_counter / total_iteration_number, w, ['scale ',num2str(k),' LF activation']);
    for i = 1:size(angles_data,1)
            [c_p,c_n] = calcGaborResponse(vid_in_scaled, angles_data.azimuth(i), angles_data.elevation(i));
            c_p_norm_factor = 1 + (c_p_power_sum - c_p.^q_norm).^(1/q_norm);
            c_n_norm_factor = 1 + (c_n_power_sum - c_n.^q_norm).^(1/q_norm);
            c_p_normed = c_p ./ c_p_norm_factor;
            c_n_normed = c_n ./ c_n_norm_factor;
            [lf_n, lf_p,threshold_data_local] = Gabor3DActivation(c_p_normed,c_n_normed,...
                angles_data.azimuth(i), angles_data.elevation(i), ...
                total_activation_threshold, angles_data.facilitation_length(i), alpha);
            threshold_data(:,(k-1)*total_iteration_number+i) = [1/k,threshold_data_local];
            %combining angles
            vid_ori_p = vid_ori_p+(lf_p*angles_data.norm_factor(i)).^m1;
            vid_ori_n = vid_ori_n+(lf_n*angles_data.norm_factor(i)).^m1;
            %waitbar handling
            progress_counter = progress_counter + 1;
            waitbar(progress_counter / total_iteration_number, w);
    end
    waitbar(progress_counter / total_iteration_number, w, ['finished scale ', num2str(k)]);
    vid_ori_p = vid_ori_p.^(1/m1);
    vid_ori_n = vid_ori_n.^(1/m1);
    
    curr_vid_scaled = imresize3(vid_ori_p.^m2 - vid_ori_n.^m2,size(vid_in));%todo: maybe do after scale\before orientation
    curr_vid_scaled = curr_vid_scaled/(k^m2);
    vid_scales_pyramid{k} = curr_vid_scaled;
    vid_out_scaled = vid_out_scaled + curr_vid_scaled;
    %waitbar handling
    
end
%rooting scales
vid_out_scaled = sign(vid_out_scaled).*abs(vid_out_scaled).^(1/m2);

%removing margins
vid_out_scaled = stripVideo(vid_out_scaled, 2*nScales);
vid_out_scaled = vid_out_scaled/max(abs(vid_out_scaled(:)));

close(w);
end