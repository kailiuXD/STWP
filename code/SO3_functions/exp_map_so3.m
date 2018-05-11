function [end_point] = exp_map_so3(start_point, direction)

    direction = direction(:);
    if (norm(direction))
        end_point = start_point*vrrotvec2mat([direction/norm(direction); norm(direction)]);
    else
        end_point = start_point;
    end
end
