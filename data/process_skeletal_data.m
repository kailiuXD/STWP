function [] = process_skeletal_data(dataset)

    dbstop if error

    if (strcmp(dataset, 'UTKinect'))

        joints_order = [5, 9, 3, 2, 13, 17, 1, 6, 10, 7, 11, 8, 12, 14, 18, 15, 19, 16, 20, 4];

        directory = [dataset, '/joints'];
        load([directory, '/frame_indices']);
        load([dataset, '/body_model'])

        n_actions = 10;
        n_subjects = 10;
        n_instances = 2;

        bone1_joints = body_model.primary_pairs(:,1:2);    
        bone2_joints = body_model.primary_pairs(:,3:4);

        skeletal_data = cell(n_actions, n_subjects, n_instances);
        skeletal_data_validity = zeros(n_actions, n_subjects, n_instances);
        for s = 1:n_subjects        
            for e = 1:n_instances            
                file = [directory, '/', sprintf('joints_s%02i_e%02i.txt',s,e)];            
                fp = fopen(file);
                A = fscanf(fp,'%f');
                fclose(fp);

                frame_no = A(1:61:end);
                A(1:61:end) = [];
                n_frames = length(A) / 60;
                A = reshape(A, 3, 20, n_frames);

                [frame_no, unique_ind] = unique(frame_no);
                A = A(:,:, unique_ind);

                action_frame_limits = frame_indices{s,e};
                for a = 1:n_actions

                    if (~sum(isnan(action_frame_limits(a,:))))
                        skeletal_data_validity(a, s, e) = 1;                    

                        [~,ind1] = min(abs(frame_no - action_frame_limits(a,1)));
                        [~,ind2] = min(abs(frame_no - action_frame_limits(a,2)));

                        normalized_joint_locations = A(:,joints_order, ind1:ind2);
                        original_skeletal_data = zeros(size(normalized_joint_locations));

                        time_stamps = frame_no(ind1:ind2) - frame_no(ind1) + 1;

                        n_frames = ind2 - ind1 + 1;                    

                        hip_loc = zeros(3, n_frames);

                        frame_validity = ones(1,n_frames);
                        for n = 1:n_frames                    
                            temp = normalized_joint_locations(2,:, n);
                            normalized_joint_locations(2,:,n) = normalized_joint_locations(3,:,n);
                            normalized_joint_locations(3,:,n) = temp;

                            original_skeletal_data(:,:,n) = normalized_joint_locations(:,:,n);
                            
                            hip_loc(:,n) = normalized_joint_locations(:,body_model.hip_center_index,n);
                            normalized_joint_locations(:,:,n) = normalized_joint_locations(:,:,n) - repmat(hip_loc(:,n), 1, 20);

                            R = compute_relative_joint_angles(normalized_joint_locations(:,:,n),...
                                bone1_joints, bone2_joints);

                            reconstruct = 1;
                            for i = 1:body_model.n_primary_angles
                                if (isempty(R{i}))
                                    reconstruct = 0;
                                end
                            end

                            if (reconstruct)
                                normalized_joint_locations(:,:,n) = reconstruct_joint_locations(R,...
                                    bone1_joints, bone2_joints, body_model.bone_lengths);
                            else
                                frame_validity(n) = 0;
                            end     
                        end
                        frame_validity = (frame_validity == 1);

                        normalized_joint_locations = normalized_joint_locations(:,:,frame_validity);
                        time_stamps = time_stamps(frame_validity);

                        normalized_joint_locations = rotate_the_skeletons(normalized_joint_locations, body_model);

                        if (a == 5 && s == 9 && (e == 1 || e == 2))
                            skeletal_data{a, s, e}.original_skeletal_data = original_skeletal_data(:,:,1:2:end);
                            skeletal_data{a, s, e}.joint_locations = normalized_joint_locations(:,:,1:2:end);
                            skeletal_data{a, s, e}.time_stamps = time_stamps(1:2:end);                                                                    
                        else
                            skeletal_data{a, s, e}.original_skeletal_data = original_skeletal_data;
                            skeletal_data{a, s, e}.joint_locations = normalized_joint_locations;
                            skeletal_data{a, s, e}.time_stamps = time_stamps;
                        end

                        skeletal_data{a, s, e}.action = a;
                        skeletal_data{a, s, e}.subject = s;
                        skeletal_data{a, s, e}.instance = e;
                    end                
                end
            end
        end

        save([dataset, '/skeletal_data'], 'skeletal_data', 'skeletal_data_validity');


    elseif (strcmp(dataset, 'Florence3D'))

        load([dataset, '/body_model'])

        file = [dataset, '/', 'world_coordinates.txt'];

        bone1_joints = body_model.primary_pairs(:,1:2);    
        bone2_joints = body_model.primary_pairs(:,3:4);

        fp = fopen(file);
        A = fscanf(fp,'%f');
        fclose(fp);
        n_total_frames = length(A)/48;
        A = reshape(A, 48, n_total_frames);
        video_id = A(1,:);
        actor_id = A(2,:);
        action_id = A(3,:);
        A(1:3, :) = [];
        A = A/(10^3);

        n_videos = length(unique(video_id));
        skeletal_data = cell(n_videos, 1);

        for i = 1:n_videos
            ind = find(video_id == i);
            cur_video = A(:, ind);
            n_frames = length(ind);
            original_skeletal_data = zeros(3, 15, n_frames);
            normalized_joint_locations = zeros(3, 15, n_frames);

            time_stamps = 1:n_frames;

            hip_loc = zeros(3, n_frames);                

            frame_validity = ones(1,n_frames);
            for n = 1:n_frames            
                normalized_joint_locations(:, :, n) = reshape(cur_video(:,n), 3, 15);
                temp = normalized_joint_locations(2,:, n);
                normalized_joint_locations(2,:,n) = normalized_joint_locations(3,:,n);
                normalized_joint_locations(3,:,n) = temp;

                original_skeletal_data(:, :, n) = normalized_joint_locations(:, :, n);

                hip_loc(:,n) = normalized_joint_locations(:,body_model.hip_center_index,n);            
                normalized_joint_locations(:,:,n) = normalized_joint_locations(:,:,n) - repmat(hip_loc(:,n), 1, 15);

                R = compute_relative_joint_angles(normalized_joint_locations(:,:,n),...
                    bone1_joints, bone2_joints);

                reconstruct = 1;
                for p = 1:body_model.n_primary_angles
                    if (isempty(R{p}))
                        reconstruct = 0;
                    end
                end

                if (reconstruct)
                    normalized_joint_locations(:,:,n) = reconstruct_joint_locations(R,...
                        bone1_joints, bone2_joints, body_model.bone_lengths);
                else
                    frame_validity(n) = 0;                
                end                                                                                   
            end

            frame_validity = (frame_validity == 1);

            normalized_joint_locations = normalized_joint_locations(:,:,frame_validity);        
            time_stamps = time_stamps(frame_validity);

            normalized_joint_locations = rotate_the_skeletons(normalized_joint_locations, body_model);

            skeletal_data{i}.original_skeletal_data = original_skeletal_data;
            skeletal_data{i}.joint_locations = normalized_joint_locations;
            skeletal_data{i}.time_stamps = time_stamps;
            skeletal_data{i}.subject = unique(actor_id(ind));
            skeletal_data{i}.action = unique(action_id(ind));

        end       

        save([dataset, '/skeletal_data'], 'skeletal_data');

    elseif (strcmp(dataset, 'MSRAction3D'))
        
        dir = [dataset,'/real_world_coordinates'];
        load([dataset, '/files_used'])
        load([dataset, '/body_model'])

        n_actions = 20;
        n_subjects = 10;
        n_instances = 3;

        bone1_joints = body_model.primary_pairs(:,1:2);    
        bone2_joints = body_model.primary_pairs(:,3:4);

        skeletal_data = cell(n_actions, n_subjects, n_instances);
        skeletal_data_validity = zeros(n_actions, n_subjects, n_instances);
        for a = 1:n_actions
            for s = 1:n_subjects
                for e = 1:n_instances  

                    name = sprintf('a%02i_s%02i_e%02i',a,s,e);
                    if(sum(strmatch(name, files_used)))
                        skeletal_data_validity(a, s, e) = 1;
                        file = [dir, '/', sprintf('a%02i_s%02i_e%02i_skeleton3D.txt',a,s,e)];            
                        fp = fopen(file);
                        A = fscanf(fp,'%f');
                        fclose(fp);
                        n_frames = length(A) / 80;
                        A = reshape(A, 4, 20, n_frames);

                        normalized_joint_locations = A(1:3,:,:);     
                        original_skeletal_data = zeros(size(normalized_joint_locations));
                        hip_loc = zeros(3, n_frames);  
                        frame_validity = ones(n_frames, 1);
                        time_stamps = 1:n_frames;

                        for n = 1:n_frames                    
                            temp = normalized_joint_locations(2,:, n);
                            normalized_joint_locations(2,:,n) = normalized_joint_locations(3,:,n);
                            normalized_joint_locations(3,:,n) = temp;

                            original_skeletal_data(:,:,n) = normalized_joint_locations(:,:,n);

                            hip_loc(:,n) = normalized_joint_locations(:,body_model.hip_center_index,n);
                            normalized_joint_locations(:,:,n) = normalized_joint_locations(:,:,n) -...
                                repmat(hip_loc(:,n), 1, 20);


                            % relative 3D angles
                            R = compute_relative_joint_angles(normalized_joint_locations(:,:,n),...
                                bone1_joints, bone2_joints);

                            reconstruct = 1;
                            for i = 1:body_model.n_primary_angles
                                if (isempty(R{i}))
                                    reconstruct = 0;
                                end
                            end
                            if (reconstruct)
                                normalized_joint_locations(:,:,n) = reconstruct_joint_locations(R,...
                                    bone1_joints, bone2_joints, body_model.bone_lengths);                            
                            else
                                frame_validity(n) = 0;
                            end   
                        end
                        frame_validity = (frame_validity == 1);

                        normalized_joint_locations = normalized_joint_locations(:,:,frame_validity);
                        time_stamps = time_stamps(frame_validity);                        

                        skeletal_data{a, s, e}.original_skeletal_data = original_skeletal_data;
                        skeletal_data{a, s, e}.joint_locations = normalized_joint_locations;
                        skeletal_data{a, s, e}.time_stamps = time_stamps;                        
                    end
                end
            end
        end

        save([dataset, '/skeletal_data'], 'skeletal_data', 'skeletal_data_validity');

    else
        error('Unknwon dataset');
    end

end
