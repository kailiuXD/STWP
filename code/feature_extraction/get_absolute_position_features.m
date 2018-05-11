function [features] = get_absolute_position_features(joint_locations, body_model, n_desired_frames)

    n_given_frames = size(joint_locations, 3);
    
    if (sum(sum(joint_locations(:, body_model.hip_center_index, :))))
        error('Something wrong. Hip center is supposed to be the origin in every frame')
    end
    
    joint_locations(:, body_model.hip_center_index, :) = [];
    S = size(joint_locations);
    joint_locations = reshape(joint_locations, S(1)*S(2), S(3));

    valid_frame_indices = find(sum(joint_locations));
        
    n_features = size(joint_locations, 1);

    features = zeros(n_features, n_desired_frames);
    for k = 1:n_features
        features(k, :) = spline(valid_frame_indices, joint_locations(k,valid_frame_indices),...
            1:((n_given_frames-1)/(n_desired_frames-1)):n_given_frames);
    end
    
end
