function [features] = get_eigenjoints_features(joint_locations, body_model, n_desired_frames)

n_given_frames = size(joint_locations, 3);
truelie = size(joint_locations, 2);
truenewlie_I = truelie * (truelie - 1)/2;
truenewlie_P = truelie * truelie;


%{
    joint_A_locations = joint_locations;
    
    SA = size(joint_A_locations);

  
   for yeA = 1:SA(3)
        for lieA = 1:SA(2)
            
            if(norm(joint_A_locations(:, lieA, yeA), 2) == 0)
                
            else
                joint_A_locations(:, lieA, yeA) = (joint_A_locations(:, lieA, yeA))/norm(joint_A_locations(:, lieA, yeA), 2);
            end
         end
   end

   joint_A_locations = reshape(joint_A_locations, SA(1)*SA(2), SA(3));
%}

relative_joint_I = zeros(3, truenewlie_I, n_given_frames);
for ye0 = 1:n_given_frames
    xinlie0 = 1;
    for lie0 = 1:(truelie - 1)
        beijian0 = lie0 +1;
        for beijian1 = beijian0:truelie
            relative_joint_I(:, xinlie0, ye0) = joint_locations(:, lie0, ye0)...
               - joint_locations(:, beijian1, ye0);
           xinlie0 = xinlie0 +1;
        end
    end
end
   
   S = size(relative_joint_I);
   
%   disp(S(2));

  
   for ye = 1:S(3)
        for lie = 1:S(2)
             relative_joint_I(:, lie, ye) = (relative_joint_I(:, lie, ye))/norm(relative_joint_I(:, lie, ye), 2);
         end
   end

   
    relative_joint_I = reshape(relative_joint_I, S(1)*S(2), S(3));
    
    disp(S(1))
 
%{    
    %  400 joints movements vector
    relative_joint_P = zeros(3, truenewlie_P, n_given_frames);
    
    for ii = 1:(n_given_frames-1)
        newlie = 1;
        for beijianlie = 1:truelie
            for jianlie = 1:truelie
                relative_joint_P(:, newlie, ii) = joint_locations(:, jianlie, ii+1)...
                    - joint_locations(:, beijianlie, ii);
                newlie = newlie +1;
            end
        end
        
    end
    
    newlie = 1;
    for beijianlie = 1:truelie
        for jianlie = 1:truelie
            relative_joint_P(:, newlie, n_given_frames) = joint_locations(:, jianlie, 1)...
                - joint_locations(:, beijianlie, n_given_frames);
            newlie = newlie +1;
        end
    end
    
    S1 = size(relative_joint_P);
    disp(S1(2));

    
    for ye1 = 1:S1(3)
        for lie1 = 1:S1(2)
%            disp(norm(relative_joint_P_locations(:, lie1, ye1), 2)); % 可能出现前后两帧某些点的位移为0，此时模为0

            if(norm(relative_joint_P(:, lie1, ye1), 2) == 0)
                
            else
                relative_joint_P(:, lie1, ye1) = (relative_joint_P(:, lie1, ye1))/norm(relative_joint_P(:, lie1, ye1), 2);
            end
        end
    end

    
    relative_joint_P = reshape(relative_joint_P,S1(1)*S1(2), S1(3));
%}
    
 


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
    
   
    for ye1 = 1:S1(3)
        for lie1 = 1:S1(2)
%            disp(norm(relative_joint_P_locations(:, lie1, ye1), 2)); % 可能出现前后两帧某些点的位移为0，此时模为0

            if(norm(relative_joint_P_locations(:, lie1, ye1), 2) == 0)
                
            else
                relative_joint_P_locations(:, lie1, ye1) = (relative_joint_P_locations(:, lie1, ye1))/norm(relative_joint_P_locations(:, lie1, ye1), 2);
            end
        end
    end

    
    relative_joint_P_locations = reshape(relative_joint_P_locations,S1(1)*S1(2), S1(3));

    

%{
    % 20 movements angle
        relative_joint_P_locations = zeros(size(joint_locations,1),...
        size(joint_locations,2), n_given_frames);
    
    for ii = 1:(n_given_frames-1)
        relative_joint_P_locations(:, :, ii) = joint_locations(:, :, ii+1)...
            - joint_locations(:, :, ii);
        
    end
    relative_joint_P_locations(:, :, n_given_frames) = joint_locations(:, :, 1)...
        - joint_locations(:, :, n_given_frames);
    
    relative_joint_P_angle_index = compute_angles_index(relative_joint_P_locations);
    
    Si2 = size(relative_joint_P_angle_index);
        
    relative_joint_P_angle_index = reshape(relative_joint_P_angle_index, Si2(1)*Si2(2), Si2(3));
%}
    
    
%{
    relative_joint_PP = zeros(3, truenewlie_P, n_given_frames);
    
    for iii = 1:n_given_frames
        newnewlie = 1;
        for beibeijianlie = 1:truelie
            for jianjianlie = 1:truelie
                relative_joint_PP(:, newnewlie, iii) = joint_locations(:, jianjianlie, iii)...
                    - joint_locations(:, beibeijianlie, 1);
                newnewlie = newnewlie +1;
            end
        end
        
    end
    
    SS1 = size(relative_joint_PP);
    disp(SS1(2));

    
    for yeye1 = 1:SS1(3)
        for lielie1 = 1:SS1(2)
%            disp(norm(relative_joint_P_locations(:, lie1, ye1), 2)); % 可能出现前后两帧某些点的位移为0，此时模为0

            if(norm(relative_joint_PP(:, lielie1, yeye1), 2) == 0)
                
            else
                relative_joint_PP(:, lielie1, yeye1) = (relative_joint_PP(:, lielie1, yeye1))/norm(relative_joint_PP(:, lielie1, yeye1), 2);
            end
        end
    end

    
    relative_joint_PP = reshape(relative_joint_PP,SS1(1)*SS1(2), SS1(3));
%}
    
    
    
    relative_joint_IP = [relative_joint_I; relative_joint_P_locations];

    disp(size(relative_joint_IP, 1));
    
    valid_frame_indices = find(sum(relative_joint_IP));

    n_features = size(relative_joint_IP, 1);

    features = zeros(n_features, n_desired_frames);
    for k = 1:n_features
        features(k, :) = spline(valid_frame_indices, relative_joint_IP(k,valid_frame_indices),...
            1:((n_given_frames-1)/(n_desired_frames-1)):n_given_frames);
    end
        
end