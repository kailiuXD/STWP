function [q] = axis_angle_to_quaternions(axis_angle)

    axis_angle = axis_angle(:);

    theta = norm(axis_angle);
    if (theta)
        axis = axis_angle/theta;
        q = [axis*sin(theta/2); cos(theta/2)];
    else 
        q = [0, 0, 0, 1];
    end

end

