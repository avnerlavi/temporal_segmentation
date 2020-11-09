function CM_Mask = cmmask(input_video_matrix,GridSize,TimeStep)

    cm_func = @(x) replace_block_with_center_of_mass(x.data);
    grade_func = @(x) calc_cluster_grade(x.data);

    CM_Matrix = input_video_matrix;

    % For each frame calculate the center of mass of each grid cell
    % Mass is defined to be zeros of the image
    for i = 1:size(input_video_matrix,3)
        CM_Matrix(:,:,i) = blockproc(input_video_matrix(:,:,i),[GridSize GridSize],cm_func);
    end
        
    for i = 1:TimeStep:size(CM_Matrix,3)-TimeStep

        % logical AND will accumulate the zeros
        accumulate_img = all(CM_Matrix(:,:,i:i + TimeStep - 1), 3);
        
        % grading each grid cell using grade_func
        Grade_grid = blockproc(accumulate_img,[GridSize GridSize],grade_func);     
        med_grade = mean(Grade_grid(:), 'omitnan'); % this messes up values for frames that include NaN
        
        % Creating a masking for each frame in the video
        % One means need to keep pixel, Zero means pixel can be dropped
        mask = repelem(Grade_grid<=med_grade,GridSize,GridSize);
        mask = mask(1:size(accumulate_img,1),1:size(accumulate_img,2));
        CM_Mask(:,:,i:i+TimeStep-1) = repmat(mask,1,1,TimeStep);
    end
    
end