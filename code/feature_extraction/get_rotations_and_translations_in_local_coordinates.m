function [se3_points] = get_rotations_and_translations_in_local_coordinates(joint_locations, body_model, option)
    
    if (strcmp(option, 'relative_pairs'))
        bone1_joints = body_model.relative_body_part_pairs(:,1:2);
        bone2_joints = body_model.relative_body_part_pairs(:,3:4);

    elseif (strcmp(option, 'absolute_pairs'))
        bone1_joints = body_model.absolute_body_part_pairs(:,1:2);
        bone2_joints = body_model.absolute_body_part_pairs(:,3:4);
        
    elseif (strcmp(option, 'relative_I_pairs'))
        bone1_joints = body_model.relative_body_I_pairs(:,1:2);
        bone2_joints = body_model.relative_body_I_pairs(:,3:4);
        
    else
        error('Unknown option')
    end
        
    n_bone_pairs = size(bone1_joints, 1);

    se3_points = cell(n_bone_pairs, 1);

    for i = 1:n_bone_pairs
        bone1_st = joint_locations(:,bone1_joints(i,1));

        if (bone1_joints(i,2))
            bone1_end = joint_locations(:, bone1_joints(i, 2));
        else
            bone1_end = [1 0 0]';        
        end
        bone2_st = joint_locations(:, bone2_joints(i, 1));
        bone2_end = joint_locations(:, bone2_joints(i, 2));

        bone1_end = bone1_end - bone1_st;
        bone2_st = bone2_st - bone1_st;
        bone2_end = bone2_end - bone1_st;
        bone1_st = bone1_st - bone1_st;

        if (isequal(bone1_end - bone1_st,[0;0;0]) || isequal(bone2_end - bone2_st,[0;0;0]))
            se3_points{i} = [];
        else
            % Find the rotation matrix that converts bone1_global into x-axis
            R = vrrotvec2mat(vrrotvec(bone1_end, [1, 0, 0]));

            bone1_end = R*bone1_end;
            bone2_st = R*bone2_st;
            bone2_end = R*bone2_end;


            % Find the rotation matrix that converts bone1 into bone2
            % This rotation matrix gives us the rotation between both bones in a
            % coordinate system that is attached to bone 1.
            R = vrrotvec2mat(vrrotvec(bone1_end - bone1_st, bone2_end - bone2_st));
            t = bone2_st - bone1_st;
            se3_points{i} = [R t; [0, 0, 0, 1]];
        end
    end

end
