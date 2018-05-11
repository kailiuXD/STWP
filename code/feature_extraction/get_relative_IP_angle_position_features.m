function [features] = get_relative_IP_angle_position_features(joint_locations, body_model, n_desired_frames)

%{
    relative_joint_P_pairs = nchoosek(1:body_model.n_joints, 2);
   
    n_given_frames = size(joint_locations, 3);

    relative_joint_P_locations = joint_locations(:, relative_joint_P_pairs(:,1), :)...
       - joint_locations(:, relative_joint_P_pairs(:,2), :);

    S = size(relative_joint_P_locations);

    relative_joint_P_locations = reshape(relative_joint_P_locations, S(1)*S(2), S(3));
%}

    relative_joint_P_pairs = body_model.bones;
    
    n_given_frames = size(joint_locations, 3);

    relative_joint_P_locations = joint_locations(:, relative_joint_P_pairs(:,2), :)...
       - joint_locations(:, relative_joint_P_pairs(:,1), :);
   
    relative_joint_P_angle_index = compute_angles_index(relative_joint_P_locations);
    
    Si = size(relative_joint_P_angle_index);
    
%    disp(Si);

    relative_joint_P_angle_index = reshape(relative_joint_P_angle_index, Si(1)*Si(2), Si(3));
    
    
    relative_joint_I_locations = zeros(size(joint_locations,1),...
        size(joint_locations,2), n_given_frames);
    
    for ii = 1:(n_given_frames-1)
        relative_joint_I_locations(:, :, ii) = joint_locations(:, :, ii+1)...
            - joint_locations(:, :, ii);
        
    end
    relative_joint_I_locations(:, :, n_given_frames) = joint_locations(:, :, 1)...
        - joint_locations(:, :, n_given_frames);
    
    relative_joint_I_angle_index = compute_angles_index(relative_joint_I_locations);
    
    Si2 = size(relative_joint_I_angle_index);
        
    relative_joint_I_angle_index = reshape(relative_joint_I_angle_index, Si2(1)*Si2(2), Si2(3));
   
    relative_joint_IP_angle_locations = [relative_joint_P_angle_index ; relative_joint_I_angle_index];
    
    
    disp(size(relative_joint_IP_angle_locations, 1));
    
    
    valid_frame_indices = find(sum(relative_joint_IP_angle_locations));

    n_features = size(relative_joint_IP_angle_locations, 1);

    features = zeros(n_features, n_desired_frames);
    for k = 1:n_features
        features(k, :) = spline(valid_frame_indices, relative_joint_IP_angle_locations(k,valid_frame_indices),...
            1:((n_given_frames-1)/(n_desired_frames-1)):n_given_frames);
    end
        
end
