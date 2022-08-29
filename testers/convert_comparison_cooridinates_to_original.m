function [x_orig,y_orig,location_x,location_y] = convert_comparison_cooridinates_to_original(video_size,x,y)
    margin = 10; %hard coded in compareVids
    extended_size = video_size + margin;
    x_orig = mod(x - 1, extended_size(2)) + 1;
    y_orig = mod(y - 1, extended_size(1)) + 1;
    if(x_orig > video_size(2) || x_orig > video_size(1))
        error('coordinate is in margin')
    end
    location_x = floor((x - 1)/extended_size(2)) + 1;
    location_y = floor((y - 1)/extended_size(1)) + 1;
end

