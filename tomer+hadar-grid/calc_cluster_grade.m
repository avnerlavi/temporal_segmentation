function Grade = calc_cluster_grade (I)
% function gets logical image I
% and gives a grade to how dense the cluster
% using sum of distances from center

    CM = replace_block_with_center_of_mass(I);
    
    [colP,rowP] = find(~I); % coordinates of zeros (black) points 
    [colC,rowC] = find(~CM); % coordinates of new center
    
    P = [colP,rowP];
    C = [colC,rowC];
    
    % Grade is average of the euclidean dist between P points to Center point
    % Note: *** try replace mean with max ***
    Grade  = mean(sqrt(sum((C - P) .^ 2,2))); % maybe use pdist

end