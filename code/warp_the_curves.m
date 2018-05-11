function [warped_curves] = warp_the_curves(nominal_curve, curves)
    
    n_curves = length(curves);
    n_frames = size(nominal_curve , 2);
    
    warped_curves = zeros(size(nominal_curve,1), n_frames, n_curves);
    for i = 1:n_curves
        	      
        dist = (pdist2(nominal_curve', curves{i}')).^2;
        matches = dtw(dist);
         
        for j = 1:n_frames
            ind = find(matches(1,:) == j);
            [~,min_ind] = min(dist(j, matches(2,ind)));
            warped_curves(:,j,i) = curves{i}(:,matches(2, ind(min_ind)));            
        end

    end
end


