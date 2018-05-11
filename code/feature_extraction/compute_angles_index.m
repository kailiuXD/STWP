function [relative_joint_angle_index] = compute_angles_index(relative_joint_locations)

    S = size(relative_joint_locations);
    relative_joint_angle_index = zeros(24, S(2), S(3));
    
    for kk = 1:S(3)
        for kkk = 1:S(2)
            x = relative_joint_locations(1, kkk, kk);
            y = relative_joint_locations(2, kkk, kk);
            z = relative_joint_locations(3, kkk, kk);


            a = [1, 0];
            b = [x, y];
            c = [y, z];
            d = [z, x];

            if (norm(b) == 0)
                angle_xy_index = 8;

            else
                cos_ab = dot(a,b)/(norm(a) * norm(b));

                angle_x = acos(cos_ab);

                if (y <= 0)
                    angle_x = (2 * pi - angle_x);
                end

%                disp(angle_x);
                
                if (angle_x == 0)
                    angle_xy_index = 8;
                else
                    angle_xy_index = ceil(angle_x/(pi/4));
                end

            end
            
            relative_joint_angle_index(angle_xy_index, kkk, kk) = norm(b) + relative_joint_angle_index(angle_xy_index, kkk, kk);
            
            
           if (norm(c) == 0)
                angle_yz_index = 8;

            else
                cos_ac = dot(a,c)/(norm(a) * norm(c));

                angle_y = acos(cos_ac);

                if (z <= 0)
                    angle_y = (2 * pi - angle_y);
                end

%                disp(angle_y);
                
                if (angle_y == 0)
                    angle_yz_index = 8;
                else
                    angle_yz_index = ceil(angle_y/(pi/4));
                end

            end
            
            relative_joint_angle_index((8 + angle_yz_index), kkk, kk) = norm(c) + relative_joint_angle_index((8 + angle_yz_index), kkk, kk);
            
            
            if (norm(d) == 0)
                angle_zx_index = 8;

            else
                cos_ad = dot(a,d)/(norm(a) * norm(d));

                angle_z = acos(cos_ad);

                if (x <= 0)
                    angle_z = (2 * pi - angle_z);
                end

%                disp(angle_z);
                
                if (angle_z == 0)
                    angle_zx_index = 8;
                else
                    angle_zx_index = ceil(angle_z/(pi/4));
                end

            end
            
            relative_joint_angle_index((16 + angle_zx_index), kkk, kk) = norm(c) + relative_joint_angle_index((16 + angle_zx_index), kkk, kk);
            
            
        end
    end
    
%    disp(size(relative_joint_angle_index));

end

