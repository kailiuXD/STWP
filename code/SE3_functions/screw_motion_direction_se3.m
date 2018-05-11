function [direction] = screw_motion_direction_se3(start_point, end_point)


    G = start_point\end_point;

    R = G(1:3, 1:3);
    t = G(1:3, 4);

    axis_angle = vrrotmat2vec(R);        
    w = axis_angle(1:3)*axis_angle(4);
    w = w(:);

    theta = norm(w);
    if (theta)
        skewmat = [    0, -w(3),  w(2);
                    w(3),     0, -w(1);
                   -w(2),  w(1),    0];

        skewmat_sqr = skewmat*skewmat;

        A =  eye(3) + skewmat*(1-cos(theta))/(theta^2) +...
            skewmat_sqr*(theta - sin(theta))/(theta^3);

    else
        A = eye(3);
    end

    direction = [w; A\t]';
end
