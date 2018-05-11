function [rot_mats] = get_rotations_in_local_coordinates(joint_locations, body_model, option)

    if (strcmp(option, 'relative_pairs'))
        bone1_joints = body_model.relative_body_part_pairs(:,1:2);
        bone2_joints = body_model.relative_body_part_pairs(:,3:4);

    elseif (strcmp(option, 'absolute_pairs'))
        bone1_joints = body_model.absolute_body_part_pairs(:,1:2);
        bone2_joints = body_model.absolute_body_part_pairs(:,3:4);

    elseif (strcmp(option, 'joint_angle_pairs'))
        bone1_joints = body_model.joint_angle_pairs(:,1:2);
        bone2_joints = body_model.joint_angle_pairs(:,3:4);

    else
        error('Unknown option')
    end

    % relative 3D angles
    rot_mats = compute_joint_angles_in_local_coordinate_system(joint_locations, bone1_joints, bone2_joints);

end
