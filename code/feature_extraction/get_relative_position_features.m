function [features] = get_relative_position_features(joint_locations, body_model, n_desired_frames)

    relative_joint_pairs = nchoosek(1:body_model.n_joints, 2);
   
    n_given_frames = size(joint_locations, 3);

    relative_joint_locations = joint_locations(:, relative_joint_pairs(:,1), :)...
       - joint_locations(:, relative_joint_pairs(:,2), :);

    S = size(relative_joint_locations);
    relative_joint_locations = reshape(relative_joint_locations, S(1)*S(2), S(3));
                    
    valid_frame_indices = find(sum(relative_joint_locations));
        
    n_features = size(relative_joint_locations, 1);

    features = zeros(n_features, n_desired_frames);
    for k = 1:n_features
        features(k, :) = spline(valid_frame_indices, relative_joint_locations(k,valid_frame_indices),...
            1:((n_given_frames-1)/(n_desired_frames-1)):n_given_frames);
    end
        
end
