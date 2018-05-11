function [] = compute_kernels(features, savename)

    N = length(features);
    S = size(features{1});
    F = zeros(S(1)*S(2), N);

    for j = 1:N
        temp = features{j};
        F(:,j) = temp(:);        
    end   

    linear_kernel = F'*F;

    save(savename, 'linear_kernel');

end

