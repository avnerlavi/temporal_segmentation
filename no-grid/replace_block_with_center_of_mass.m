function CM = replace_block_with_center_of_mass (I)
% function gets logical image I
% calculates the center of black pixels (zeros)
% and drawing a black pixel (zero) in the center of mass

    A = single(not(I));
    tot_mass = sum(A(:));
    CM = true(size(I));
    if (tot_mass == 0)
        return;
    end
    [ii,jj] = ndgrid(1:size(A,1),1:size(A,2));
    R = sum(ii(:).*A(:))/tot_mass;
    C = sum(jj(:).*A(:))/tot_mass;
    %out = [tot_mass,R,C];
    CM(round(R), round(C)) = 0;

end