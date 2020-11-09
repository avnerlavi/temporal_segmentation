function [tl_col,tl_row,br_col,br_row] = find_bounding_box(I)
% function gets logical image I
% calculates the top-left corner point of bounding box rectungle
% the bounding box include all white (ones) of the image

    if (~any(I(:)))
        % all matrix is zero
        tl_col  = 1;
        tl_row  = 1;
        br_col  = size(I,2);
        br_row  = size(I,1);
        
%         col    = tl_col;
%         row    = tl_row;
%         width  = br_col-tl_col;
%         height = br_row-tl_row;
%         figure;imshow(I);
%         hold on
%         rectangle('Position', [row,col,width,height],'EdgeColor','r', 'LineWidth', 3)
        return
    end
    
    [rows,cols] = find(I);
    % top-left
    tl_col = min(cols);
    tl_row = min(rows);
    % bottom-right
    br_col = max(cols);
    br_row = max(rows);
    
%     col    = tl_col;
%     row    = tl_row;
%     width  = br_col-tl_col;
%     height = br_row-tl_row;
%     
%     figure;imshow(I);
%     hold on
%     rectangle('Position', [col,row,width,height],'EdgeColor','r', 'LineWidth', 3)
%     a=1;
end