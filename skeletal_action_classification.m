function [] = skeletal_action_classification(dataset_idx, feature_idx)

      
    dbstop if error
    
    addpath(genpath('./code'))
    addpath(genpath('./data'))

    feature_types = {'absolute_joint_positions', 'relative_joint_positions',...
                     'joint_angles_quaternions', 'SE3_lie_algebra_absolute_pairs',...
                     'SE3_lie_algebra_relative_pairs', 'relative_joint_IP_positions',...
                     'relative_joint_IP_angle_positions', 'relative_IP_se3',...
                     'eigenjoints', 'trajectory_3'};

    if (feature_idx > 10)
        error('Feature index should be less than 11');
    end

    datasets = {'UTKinect', 'Florence3D', 'MSRAction3D', 'G3D', 'MSRPairs'};

    if (dataset_idx > 5)
        error('Dataset index should be less than 6');
    end

    
    % All the action sequences in a dataset are interpolated to have same
    % length. 'desired_frames' is the reference length.
    if (strcmp(datasets{dataset_idx}, 'UTKinect'))       
        desired_frames = 74;  

    elseif (strcmp(datasets{dataset_idx}, 'Florence3D'))
        desired_frames = 35;
        
    elseif (strcmp(datasets{dataset_idx}, 'MSRAction3D'))
        desired_frames = 76;
        
    elseif (strcmp(datasets{dataset_idx}, 'G3D'))
        desired_frames = 100;
    
    elseif (strcmp(datasets{dataset_idx}, 'MSRPairs'))
        desired_frames = 111;
        
    else
        error('Unknown dataset')
    end
    
    
    directory = [datasets{dataset_idx}, '_experiments/', feature_types{feature_idx}];
    mkdir(directory)

    
    % Training and test subjects
    tr_info = load(['data/', datasets{dataset_idx}, '/tr_te_splits']);
    n_tr_te_splits = size(tr_info.tr_subjects, 1);

    
    %% Skeletal representation
    disp ('Generating skeletal representation')
    generate_features(directory, datasets{dataset_idx}, feature_types{feature_idx}, desired_frames);


    
    %% Temporal modeling
    disp ('Temporal modeling')
    labels = load([directory, '/labels'], 'action_labels', 'subject_labels');
    
    n_actions = length(unique(labels.action_labels));

    mkdir([directory, '/dtw_warped_features']);
    mkdir([directory, '/dtw_warped_fourier_features']);
    mkdir([directory, '/dtw_warped_pyramid_lf_fourier_kernels']);                

    for tr_split = 1:n_tr_te_splits
        for tr_action = 1:n_actions
            % DTW
            loadname = [directory, '/features'];
            data = load(loadname, 'features');

            savename = [directory, '/dtw_warped_features/warped_features_split_',...
                num2str(tr_split), '_class_', num2str(tr_action)];
            dname1 = [directory, '/dtw_warped_features/warped_features_split_',...
                num2str(tr_split), '_class_', num2str(tr_action),'.mat'];

            get_warped_features(data.features, labels.action_labels,...
                labels.subject_labels, tr_info.tr_subjects(tr_split, :), tr_action, savename);


            % Fourier feature computation
            loadname = [directory, '/dtw_warped_features/warped_features_split_',...
                num2str(tr_split), '_class_', num2str(tr_action)];    
            data = load(loadname, 'warped_features');

            savename = [directory, '/dtw_warped_fourier_features/warped_fourier_features_split_',...
                num2str(tr_split), '_class_', num2str(tr_action)];
            dname2 = [directory, '/dtw_warped_fourier_features/warped_fourier_features_split_',...
                num2str(tr_split), '_class_', num2str(tr_action),'.mat'];

            generate_fourier_features(data.warped_features, savename, desired_frames);                           


            % Compute linear kernel from fourier features
            loadname = [directory, '/dtw_warped_fourier_features/warped_fourier_features_split_',...
                num2str(tr_split), '_class_', num2str(tr_action)];
            data = load(loadname);   

            savename = [directory, '/dtw_warped_pyramid_lf_fourier_kernels/',...
                'warped_pyramid_lf_fourier_kernels_split_',...
                num2str(tr_split), '_class_', num2str(tr_action)];

            compute_kernels(data.pyramid_lf_fourier_features, savename);
 %           delete(dname1)
 %           delete(dname2)
        end
    end

    
    %% Classification
    disp ('Classification')
    perform_classification(directory, labels.subject_labels, labels.action_labels,...
        tr_info.tr_subjects, tr_info.te_subjects);

    if (strcmp(datasets{dataset_idx}, 'MSRAction3D'))
        perform_classification_with_subsets(directory, labels.subject_labels,...
            labels.action_labels, tr_info.tr_subjects, tr_info.te_subjects,...
            tr_info.action_sets);
    end    
end
