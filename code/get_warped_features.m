function [] = get_warped_features(features, action_labels,...
    subject_labels, tr_subjects, tr_action, savename)
   
    tr_subject_ind = ismember(subject_labels, tr_subjects);
    tr_action_ind = ismember(action_labels, tr_action);

    features_for_nominal = features(tr_subject_ind & tr_action_ind);

    nominal_features = compute_nominal_curve_using_dtw(features_for_nominal);
    warped_features_matrix = warp_the_curves(nominal_features, features);

    N = length(features);
    warped_features = cell(N, 1);
    for i = 1:N
        warped_features{i} = warped_features_matrix(:,:,i);
    end

    save(savename, 'nominal_features', 'warped_features', '-v7.3');

end
    
