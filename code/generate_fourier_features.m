function [] = generate_fourier_features(features, savename, n_coeffs)

    N = length(features);

    if (nargin == 2)

        frame_lengths = zeros(N,1);
        for i = 1:N
            frame_lengths(i) = size(features{i}, 2);
        end

        n_coeffs = max(frame_lengths);
    end

    pyramid_lf_fourier_features = cell(N,1);
    for j = 1:N
        pyramid_lf_fourier_features{j} =...
            get_fourier_coeffs_pyramid(features{j}, n_coeffs);
    end

    save(savename, 'pyramid_lf_fourier_features', '-v7.3');
end
