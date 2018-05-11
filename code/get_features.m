function [features] = get_features(feature_type, joint_locations, body_model, n_desired_frames)

    if (strcmp(feature_type, 'absolute_joint_positions'))

        features = get_absolute_position_features(joint_locations,...
            body_model, n_desired_frames);

    elseif (strcmp(feature_type, 'relative_joint_positions'))

        features = get_relative_position_features(joint_locations,...
            body_model, n_desired_frames);

    elseif (strcmp(feature_type, 'joint_angles_quaternions'))

        features = get_joint_angle_quaternions(joint_locations,...
            body_model, n_desired_frames);

    elseif (strcmp(feature_type, 'SE3_lie_algebra_absolute_pairs'))

        features = get_se3_lie_algebra_features(joint_locations, body_model,...
            n_desired_frames, 'absolute_pairs');

    elseif (strcmp(feature_type, 'SE3_lie_algebra_relative_pairs'))

        features = get_se3_lie_algebra_features(joint_locations, body_model,...
            n_desired_frames, 'relative_pairs');
        
    elseif (strcmp(feature_type, 'relative_joint_IP_positions'))

        features = get_relative_IP_position_features(joint_locations,...
            body_model, n_desired_frames);

    elseif (strcmp(feature_type, 'relative_IP_se3'))

        features = get_relative_IP_position_se3_features(joint_locations,...
            body_model, n_desired_frames,'relative_I_pairs');
        
        
    elseif (strcmp(feature_type, 'relative_joint_IP_angle_positions'))

        features = get_relative_IP_angle_position_features(joint_locations,...
            body_model, n_desired_frames);
        
        
    elseif (strcmp(feature_type, 'eigenjoints'))

        features = get_eigenjoints_features(joint_locations, body_model,...
            n_desired_frames);
        
        
    elseif (strcmp(feature_type, 'trajectory_3'))

        features = get_trajectory_3_features(joint_locations,...
            body_model, n_desired_frames);

    else
        error('Unknown feature type');
    end
end
