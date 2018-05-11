function [rot_mats] = compute_joint_angles_in_local_coordinate_system(joint_locations, bone1_joints, bone2_joints)

if (size(joint_locations, 1) ~= 3)
    error('skeletons are expected to be 3 dimensional')
end

n_angles = size(bone1_joints, 1);

rot_mats = cell(n_angles, 1);

for i = 1:n_angles
    if (bone1_joints(i,2))
        bone1_global = joint_locations(:, bone1_joints(i, 2)) - joint_locations(:, bone1_joints(i, 1));
    else
        bone1_global = [1 0 0]' - joint_locations(:, bone1_joints(i, 1));
    end
    
    if (bone2_joints(i,2))
        bone2_global = joint_locations(:, bone2_joints(i, 2)) - joint_locations(:, bone2_joints(i, 1));
    else
        bone2_global = [1 0 0]' - joint_locations(:, bone2_joints(i, 1));
    end        
    
    if (isequal(bone1_global,[0;0;0]) || isequal(bone2_global,[0;0;0]))
        rot_mats{i} = [];
    else
        % Find the rotation matrix that converts bone1_global into x-axis
        R = vrrotvec2mat(vrrotvec(bone1_global, [1, 0, 0]));
        
        % Find the rotation matrix that converts R*bone1 into R*bone2
        % This rotation matrix gives us the rotation between both bones in a
        % coordinate system that is attached to bone 1.
        rot_mats{i} = vrrotvec2mat(vrrotvec(R*bone1_global, R*bone2_global));    
    end
end

