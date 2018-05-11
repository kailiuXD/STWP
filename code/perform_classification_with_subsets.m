function [] = perform_classification_with_subsets(root_dir, subject_labels,...
    action_labels, tr_subjects, te_subjects, action_sets)

    results_dir = [root_dir, '/results'];
    mkdir(results_dir);

    n_tr_te_splits = size(tr_subjects, 1);    

    n_action_sets = length(action_sets);
  
    C_val = 1;

    loadname = 'linear_kernel';

    dir = [root_dir, '/dtw_warped_pyramid_lf_fourier_kernels'];
    loadfile_tag = 'warped_pyramid_lf_fourier_kernels';    

    for set = 1:n_action_sets

        actions = unique(action_sets{set});
        n_classes = length(actions);      

        total_accuracy = zeros(n_tr_te_splits, 1);        
        cw_accuracy = zeros(n_tr_te_splits, n_classes);
        confusion_matrices = cell(n_tr_te_splits, 1);

        action_ind = ismember(action_labels, actions);  
        for i = 1:n_tr_te_splits         
            tr_subject_ind = ismember(subject_labels, tr_subjects(i,:));
            te_subject_ind = ismember(subject_labels, te_subjects(i,:));        

            tr_ind = (action_ind & tr_subject_ind);
            te_ind = (action_ind & te_subject_ind);                

            tr_labels = action_labels(tr_ind);
            te_labels = action_labels(te_ind);

            K_train_train = cell(n_classes, 1);
            K_test_train = cell(n_classes, 1);
            for class = 1:n_classes
                
                data = load ([dir, '/', loadfile_tag, '_split_',...
                    num2str(i), '_class_', num2str(class)], loadname);

                K = data.(loadname);

                K_train_train{class} = K(tr_ind, tr_ind);
                K_test_train{class} = K(te_ind, tr_ind);
            end

            [total_accuracy(i), cw_accuracy(i,:), confusion_matrices{i}] =...
                kernel_svm_one_vs_all_modified(K_train_train,...
                K_test_train, tr_labels, te_labels, C_val);

        end

        avg_total_accuracy = mean(total_accuracy);               
        avg_cw_accuracy = mean(cw_accuracy);

        avg_confusion_matrix = zeros(size(confusion_matrices{1}));
        for j = 1:length(confusion_matrices)
            avg_confusion_matrix = avg_confusion_matrix + confusion_matrices{j};
        end
        avg_confusion_matrix = avg_confusion_matrix / length(confusion_matrices);

        save ([results_dir, '/classification_results_as', num2str(set), '.mat'],...
            'total_accuracy', 'cw_accuracy', 'avg_total_accuracy',...
            'avg_cw_accuracy', 'confusion_matrices', 'avg_confusion_matrix');
    end

end
