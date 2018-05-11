function [nominal_curve] = compute_nominal_curve_using_dtw(curves_for_nominal)
          
    % initialize nominal curve
    nominal_curve = curves_for_nominal{1};

    iter = 0;
    while (iter < 25)

        warped_curves = warp_the_curves(nominal_curve, curves_for_nominal);      
        nominal_curve = mean(warped_curves, 3);
        
        iter = iter + 1;        
    end   
end

