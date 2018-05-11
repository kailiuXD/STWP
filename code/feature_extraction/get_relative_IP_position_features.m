function [features] = get_relative_IP_position_features(joint_locations, body_model, n_desired_frames)

    relative_joint_I_pairs = body_model.bones;
    
    n_given_frames = size(joint_locations, 3);

    
%{
    joint_A_locations = joint_locations;
    
    S0 = size(joint_A_locations);

  
   for ye0 = 1:S0(3)
        for lie0 = 1:S0(2)
            
            if(norm(joint_A_locations(:, lie0, ye0), 2) == 0)
                
            else
                joint_A_locations(:, lie0, ye0) = (joint_A_locations(:, lie0, ye0))/norm(joint_A_locations(:, lie0, ye0), 2);
            end
         end
   end

    
   joint_A_locations = reshape(joint_A_locations, S0(1)*S0(2), S0(3));
%}
    
    relative_joint_I_locations = joint_locations(:, relative_joint_I_pairs(:,2), :)...
       - joint_locations(:, relative_joint_I_pairs(:,1), :);
   
   S = size(relative_joint_I_locations);

  
   for ye = 1:S(3)
        for lie = 1:S(2)
             relative_joint_I_locations(:, lie, ye) = (relative_joint_I_locations(:, lie, ye))/norm(relative_joint_I_locations(:, lie, ye), 2);
         end
   end

   
    relative_joint_I_locations = reshape(relative_joint_I_locations, S(1)*S(2), S(3));
    
    
    %  20 joints movements vector
    relative_joint_P_locations = zeros(size(joint_locations,1),...
        size(joint_locations,2), n_given_frames);
    
    for ii = 1:(n_given_frames-1)
        relative_joint_P_locations(:, :, ii) = joint_locations(:, :, ii+1)...
            - joint_locations(:, :, ii);
        
    end
    relative_joint_P_locations(:, :, n_given_frames) = joint_locations(:, :, 1)...
        - joint_locations(:, :, n_given_frames);
    
    S1 = size(relative_joint_P_locations);
    

%{
    for ye1 = 1:S1(3)
        for lie1 = 1:S1(2)
%            disp(norm(relative_joint_P_locations(:, lie1, ye1), 2)); % 可能出现前后两帧某些点的位移为0，此时模为0

            if(norm(relative_joint_P_locations(:, lie1, ye1), 2) == 0)
                
            else
                relative_joint_P_locations(:, lie1, ye1) = (relative_joint_P_locations(:, lie1, ye1))/norm(relative_joint_P_locations(:, lie1, ye1), 2);
            end
        end
    end
%}

    
    relative_joint_P_locations = reshape(relative_joint_P_locations,S1(1)*S1(2), S1(3));

    
%{    
    if (sum(sum(joint_locations(:, body_model.hip_center_index, :))))
        error('Something wrong. Hip center is supposed to be the origin in every frame')
    end
    
    joint_locations(:, body_model.hip_center_index, :) = [];
    S = size(joint_locations);
    joint_A_locations = reshape(joint_locations, S(1)*S(2), S(3));
%}
    
    
    
    
    relative_joint_IP_locations = [relative_joint_I_locations; relative_joint_P_locations];
 %   relative_joint_IP_locations = [joint_A_locations ; relative_joint_I_locations];
 %   relative_joint_IP_locations = [joint_A_locations ; relative_joint_P_locations];
%    relative_joint_IP_locations = [relative_joint_I_locations ; relative_joint_P_locations];

%    relative_joint_IP_locations = relative_joint_P_locations;

    disp(size(relative_joint_IP_locations, 1));
    
    valid_frame_indices = find(sum(relative_joint_IP_locations));

    n_features = size(relative_joint_IP_locations, 1);

    features = zeros(n_features, n_desired_frames);
    for k = 1:n_features
        features(k, :) = spline(valid_frame_indices, relative_joint_IP_locations(k,valid_frame_indices),...
            1:((n_given_frames-1)/(n_desired_frames-1)):n_given_frames);
    end
        
end
