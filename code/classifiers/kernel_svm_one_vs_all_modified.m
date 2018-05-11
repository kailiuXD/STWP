% One-Vs-all SVM
% Final decision is based on max(w*x+b)

function [total_accuracy, class_wise_accuracy, confusion_matrix] =...
    kernel_svm_one_vs_all_modified(K_train_train, K_test_train,...
    training_labels, test_labels, C_val)    
    
    unique_classes = unique(training_labels);
    n_classes = length(unique_classes);
         
    n_train_samples = length(training_labels);
    n_test_samples = length(test_labels);
    
    training_accuracy = zeros(1, n_classes);

    test_prediction_labels = zeros(n_classes, n_test_samples);
    test_prediction_prob = zeros(n_classes, n_test_samples);

    for i = 1:n_classes          
        class = unique_classes(i);

        c_ind = (training_labels == class);
        tr_labels = -1*ones(n_train_samples, 1);        
        tr_labels(c_ind) = 1;                        
           
        class_imbalance_ratio = (n_train_samples - sum(c_ind)) / sum(c_ind);

        svm_model = svmtrain_lib(tr_labels,...
            [(1:n_train_samples)', K_train_train{i}],...                
            ['-t 4 -q -c ', num2str(C_val), ' -w1 ', num2str(class_imbalance_ratio)]);

        [~, temp] = svmpredict_lib(tr_labels,...
            [(1:n_train_samples)', K_train_train{i}], svm_model);         
        training_accuracy(i) = temp(1);

        predicted_labels = svmpredict_lib(test_labels,...
           [(1:n_test_samples)', K_test_train{i}], svm_model);

        test_prediction_labels(i, :) = predicted_labels;

        prob = K_test_train{i}(:, full(svm_model.SVs))*svm_model.sv_coef...
            - svm_model.rho*ones(n_test_samples,1);

        if (svm_model.Label(1) == -1)
            prob = -prob;
        end        

        test_prediction_prob(i, :) = prob';
        
    end

    [~, ind] = max(test_prediction_prob);
    final_predicted_labels = unique_classes(ind);
    
    class_wise_accuracy = zeros(n_classes, 1);    
    confusion_matrix = zeros(n_classes, n_classes);    
    for i = 1:n_classes
        temp = find(test_labels == unique_classes(i));
        class_wise_accuracy(i) =...
            length(find(final_predicted_labels(temp) == unique_classes(i)))...
            / length(temp);
        
         confusion_matrix(i, :) = hist(final_predicted_labels(temp), unique_classes) / length(temp);
    end
    
    total_accuracy = length(find(test_labels == final_predicted_labels))...
        / n_test_samples;
        
end
