function [new_samples, new_time_stamps] = piecewise_screw_motion_interpolation_se3(anchor_points, time_stamps, n_total_points)

    time_stamps = time_stamps - time_stamps(1);

    n_anchor_points = size(anchor_points, 3);
    body_velocity = zeros(6, n_anchor_points-1);
    for n = 1:(n_anchor_points-1)
        temp = screw_motion_direction_se3(anchor_points(:,:,n), anchor_points(:,:,n+1));       
        temp = temp / (time_stamps(n+1) - time_stamps(n));
        body_velocity(:,n) = temp;
    end
    
    total_time = time_stamps(end);
    
    new_time_interval = total_time/(n_total_points-1);
   
    new_samples = zeros(4,4,n_total_points);
    new_time_stamps = zeros(n_total_points, 1);
   
    previous_anchor_point_index = 1;   
    time_till_next_anchor_point = time_stamps(previous_anchor_point_index+1) - time_stamps(previous_anchor_point_index);   
    new_samples(:,:,1) = anchor_points(:,:,1);
    new_time_stamps(1) = 0;
    for i = 2:n_total_points
       
        temp_time = time_till_next_anchor_point;
        for anchor_point_idx = (previous_anchor_point_index+1):n_anchor_points
            if (temp_time < new_time_interval - 10^-10)
                temp_time = temp_time + time_stamps(anchor_point_idx+1) - time_stamps(anchor_point_idx);
            else
                break;
            end               
        end           
        previous_anchor_point_index = anchor_point_idx - 1;
        time_till_next_anchor_point = temp_time - new_time_interval;
        new_time_stamps(i) = time_stamps(previous_anchor_point_index+1) - time_till_next_anchor_point;
        time_from_previous_anchor_point = new_time_stamps(i) - time_stamps(previous_anchor_point_index);

        new_samples(:,:,i) = screw_motion_endpoint_se3(anchor_points(:,:,previous_anchor_point_index),...
	    body_velocity(:,previous_anchor_point_index)*time_from_previous_anchor_point);
    end
end
