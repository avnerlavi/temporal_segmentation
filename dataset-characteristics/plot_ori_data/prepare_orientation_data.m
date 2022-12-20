function [data_out] = prepare_orientation_data(data_in,n_az,n_el,close_az)
   % zero_data = data_in(1);
   % data_in = data_in(2:end);
    data_out = reshape(data_in,[n_el, n_az]);
  %  zero_data = repmat(zero_data,[1,n_az]);
  %  data_out = [zero_data;data_out];
    if(close_az)
        data_out= [data_out,data_out(:,1)];
    end
end

