function [features] = get_relative_IP_position_se3_features(joint_locations, body_model, n_desired_frames, option)

    lie_algebra_dim = 6;
    matrix_dim = 4;
    
    n_given_frames = size(joint_locations, 3);
    
    SE = get_rotations_and_translations_in_local_coordinates(joint_locations(:,:,1), body_model, option);
    n_relative_bone_pairs = length(SE);

    se3_features = cell(n_relative_bone_pairs, 1);
    feature_validity = cell(n_relative_bone_pairs, 1);
    for i = 1:n_relative_bone_pairs
        se3_features{i} = zeros(matrix_dim, matrix_dim, n_given_frames);       
        feature_validity{i} = ones(n_given_frames,1);
    end    

    for n = 1:n_given_frames
        SE = get_rotations_and_translations_in_local_coordinates(joint_locations(:,:,n), body_model, option);

        for i = 1:n_relative_bone_pairs
            if (~isempty(SE{i}))               
                se3_features{i}(:,:,n) = SE{i};
            else
                feature_validity{i}(n) = 0;
            end
        end
    end

    time_stamps = cell(n_relative_bone_pairs, 1);
    for i = 1:n_relative_bone_pairs    
        se3_features{i} = se3_features{i}(:,:,feature_validity{i} == 1);
        time_stamps{i} = find(feature_validity{i} == 1) - 1;
    end

    features = zeros(n_relative_bone_pairs*lie_algebra_dim, n_desired_frames);
    
    for i = 1:n_relative_bone_pairs
        interp_se3_features =...
            piecewise_screw_motion_interpolation_se3(se3_features{i},...
            time_stamps{i}, n_desired_frames);
                
        interp_se3_feat_lie_algebra_approx = zeros(lie_algebra_dim, n_desired_frames);  
        for n = 1:n_desired_frames
            interp_se3_feat_lie_algebra_approx(:,n) =...
                screw_motion_direction_se3(eye(4), interp_se3_features(:,:,n));
        end
        
        features(((i-1)*lie_algebra_dim + 1):(i*lie_algebra_dim), :) =...
            interp_se3_feat_lie_algebra_approx;
    end
    
end
