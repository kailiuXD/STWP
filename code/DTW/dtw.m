function [point_matches, final_dist] = dtw(distances_for_dtw)


    [p,q] = dpfast(distances_for_dtw);
    
    if (p(1) ~= 1 && q(1) ~= 1)
        error('Something wrong with DTW');
        
    elseif (p(1) ~= 1)
        q = [repmat(q(1), 1, p(1)-1), q];
        p = [1:(p(1)-1), p];        
        
    elseif (q(1) ~= 1)
        p = [repmat(p(1), 1, q(1)-1), p];
        q = [1:(q(1)-1), q];        
    end
    
    final_dist = 0;
    for i = 1:length(p)
        final_dist = final_dist + distances_for_dtw(p(i), q(i));
    end

    point_matches = [p; q];
end