function [joint_locations] = rotate_the_skeletons(joint_locations, body_model)

    n_frames = size(joint_locations, 3);
        
    for k = 1:n_frames
        if(sum(joint_locations(:, body_model.hip_center_index, k)))
            error('Hip center is supposed to be the origin')
        end    

        hip_axis = joint_locations(:, body_model.right_hip_index, k) -...
            joint_locations(:, body_model.left_hip_index, k);
        
        % Find the rotation matrix that converts the ground plane projection of hip-axis into x-axis
        R = vrrotvec2mat(vrrotvec([hip_axis(1), hip_axis(2), 0], [1, 0, 0]));
            
        joint_locations(:,:,k) = R*joint_locations(:,:,k);
    end
end