function [features] = get_joint_angle_quaternions(joint_locations, body_model, n_desired_frames)

    quaternion_dim = 4;
    matrix_dim = 3;

    n_given_frames = size(joint_locations, 3);
  
    R = get_rotations_in_local_coordinates(joint_locations(:,:,1), body_model, 'joint_angle_pairs');
    
    n_relative_bone_pairs = length(R);
    
    disp(n_relative_bone_pairs);

    angle_features = cell(n_relative_bone_pairs, 1);
    feature_validity = cell(n_relative_bone_pairs, 1);
    for i = 1:n_relative_bone_pairs
        angle_features{i} = zeros(matrix_dim, matrix_dim, n_given_frames);       
        feature_validity{i} = ones(n_given_frames,1);
    end

    for n = 1:n_given_frames

        R = get_rotations_in_local_coordinates(joint_locations(:,:,n), body_model, 'joint_angle_pairs');

        for i = 1:n_relative_bone_pairs
            if (~isempty(R{i}))               
                angle_features{i}(:,:,n) = R{i};
            else
                feature_validity{i}(n) = 0;
            end
        end
    end

    time_stamps = cell(n_relative_bone_pairs, 1);
    for i = 1:n_relative_bone_pairs    
       angle_features{i} = angle_features{i}(:,:,feature_validity{i} == 1);
       time_stamps{i} = find(feature_validity{i} == 1) - 1;
    end
   
    features = zeros(n_relative_bone_pairs*quaternion_dim, n_desired_frames);
    
    for i = 1:n_relative_bone_pairs
        interp_angle_features =...
            piecewise_geodesic_interpolation_so3(angle_features{i},...
            time_stamps{i}, n_desired_frames);        
                
        interp_angle_feat_quaternions = zeros(quaternion_dim, n_desired_frames);  
        for n = 1:n_desired_frames
            interp_angle_feat_quaternions(:,n) =...
               axis_angle_to_quaternions(log_map_so3(eye(3), interp_angle_features(:,:,n)));
        end
        
        features(((i-1)*quaternion_dim + 1):(i*quaternion_dim), :) =...
            interp_angle_feat_quaternions;
    end

end
