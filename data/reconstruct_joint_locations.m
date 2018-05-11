function [joint_locations] = reconstruct_joint_locations(rot_mat, bone1_joints,...
    bone2_joints, bone_lengths)

    n_angles = size(bone1_joints,1);
    rot_mat_missing = 0;
    for i = 1:n_angles
        if (isempty(rot_mat{i}))
            rot_mat_missing = 1;
        end
    end

    if (rot_mat_missing)
        joint_locations = [];
    else

        n_joints = n_angles + 1;
        joint_locations = zeros(3, n_joints);

        joint_locations(:,bone1_joints(1,1)) = [0,0,0];

        joint_locations(:,bone2_joints(1,2)) = bone_lengths(1)*rot_mat{1}*[1; 0; 0];
        for k = 2:(n_angles)
            bone1_global = joint_locations(:,bone1_joints(k,2)) - joint_locations(:,bone1_joints(k,1));
            R = vrrotvec2mat(vrrotvec([1, 0, 0], bone1_global));
            bone2_global = R*rot_mat{k}*[1;0;0];
            joint_locations(:,bone2_joints(k,2)) = bone_lengths(k)*bone2_global + joint_locations(:,bone2_joints(k,1));
        end
    end
        
end
