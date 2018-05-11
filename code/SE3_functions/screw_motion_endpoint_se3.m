function [end_point] = screw_motion_endpoint_se3(start_point, direction)

    direction = direction(:);
    w = direction(1:3);
    v = direction(4:6);
   
    theta = norm(w);
    if (theta)
        R = vrrotvec2mat([w/theta; theta]);

        skewmat = [    0, -w(3),  w(2);
                    w(3),     0, -w(1);
                   -w(2),  w(1),    0];

        skewmat_sqr = skewmat*skewmat;

        A =  eye(3) + skewmat*(1-cos(theta))/(theta^2) +...
            skewmat_sqr*(theta - sin(theta))/(theta^3);
    else
        R = eye(3);
        A = eye(3);
    end

    end_point = start_point*[R, A*v; [0,0,0,1]];   
end
