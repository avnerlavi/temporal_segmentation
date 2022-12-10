function [] = plot_orientation_data(query_data)
scales = unique(query_data(1,:));
n_az = length(unique(query_data(2,:)));
n_el = length(unique(query_data(3,:)));
plot_scale  = max(query_data(4:5,:),[],'all');
    for i = 1:scales
        query_in_scale = query_data(:,query_data(1,:)==i);
        azimuths = prepare_orientation_data(query_in_scale(2,:),n_az,n_el,true);
        azimuths(1,:) = azimuths(2,:);
        azimuths(:,end) = azimuths(:,1) + 360;
        elevations = prepare_orientation_data(query_in_scale(3,:),n_az,n_el,true);
        data_n =  prepare_orientation_data(query_in_scale(4,:),n_az,n_el,true);
        data_p =  prepare_orientation_data(query_in_scale(5,:),n_az,n_el,true);
        x = sind(elevations).*cosd(azimuths);
        y = sind(elevations).*sind(azimuths);
        z = cosd(elevations);
        figure()
        subplot(1,2,1)
        surf(x.*data_n, y.*data_n, z.*data_n)
        xlim([-plot_scale,plot_scale])
        ylim([-plot_scale,plot_scale])
        zlim([0,plot_scale])
        title('Negative Response')
        xlabel('x')
        ylabel('y')
        zlabel('t')
        subplot(1,2,2)
        surf(x.*data_p, y.*data_p, z.*data_p)
        xlim([-plot_scale,plot_scale])
        ylim([-plot_scale,plot_scale])
        zlim([0,plot_scale])
        title('Positive Response')
        xlabel('x')
        ylabel('y')
        zlabel('t')
    end
end

