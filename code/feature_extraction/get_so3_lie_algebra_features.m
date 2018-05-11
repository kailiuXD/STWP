function [features] = get_so3_lie_algebra_features(joint_locations, body_model, n_desired_frames, option)

    lie_algebra_dim = 3;
    matrix_dim = 3;

    n_given_frames = size(joint_locations, 3);

    R = get_rotations_in_local_coordinates(joint_locations(:,:,1), body_model, option);
    n_relative_bone_pairs = length(R);

    so3_features = cell(n_relative_bone_pairs, 1);
    feature_validity = cell(n_relative_bone_pairs, 1);
    for i = 1:n_relative_bone_pairs
        so3_features{i} = zeros(matrix_dim, matrix_dim, n_given_frames);       
        feature_validity{i} = ones(n_given_frames,1);
    end

    for n = 1:n_given_frames
        R = get_rotations_in_local_coordinates(joint_locations(:,:,n), body_model, option);
        for i = 1:n_relative_bone_pairs
            if (~isempty(R{i}))               
                so3_features{i}(:,:,n) = R{i};
            else
                feature_validity{i}(n) = 0;
            end
        end
    end

    time_stamps = cell(n_relative_bone_pairs, 1);
    for i = 1:n_relative_bone_pairs    
       so3_features{i} = so3_features{i}(:,:,feature_validity{i} == 1);
       time_stamps{i} = find(feature_validity{i} == 1) - 1;
    end
   
    features = zeros(n_relative_bone_pairs*lie_algebra_dim, n_desired_frames);
    
    for i = 1:n_relative_bone_pairs
        interp_so3_features =...
            piecewise_geodesic_interpolation_so3(so3_features{i},...
            time_stamps{i}, n_desired_frames);        
                
        interp_so3_feat_lie_algebra_approx = zeros(lie_algebra_dim, n_desired_frames);  
        for n = 1:n_desired_frames
            interp_so3_feat_lie_algebra_approx(:,n) =...
                log_map_so3(eye(3), interp_so3_features(:,:,n));
        end
        
        features(((i-1)*lie_algebra_dim + 1):(i*lie_algebra_dim), :) =...
            interp_so3_feat_lie_algebra_approx;
    end
         
end
