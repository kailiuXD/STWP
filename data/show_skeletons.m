function [] = show_skeletons(dataset)

load ([dataset, '/skeletal_data'])

if (strcmp(dataset, 'UTKinect'))

    J = [20     1     2     1     8    10     2     9    11     3     4     7     7     5     6    14    15    16    17;
          3     3     3     8    10    12     9    11    13     4     7     5     6    14    15    16    17    18    19];
    
    n_subjects = 10;
    n_actions = 10;
    n_instances = 2;
        
    for a = 1:n_actions
        for s = 1:n_subjects
            for e = 1:n_instances
                if (skeletal_data_validity(a,s,e))
                    S = skeletal_data{a, s, e}.original_skeletal_data;
                    n_frames = size(S,3);
                    for n = 1:n_frames            
                        plot3(S(1,:,n),S(2,:,n),S(3,:,n),'r.');
                        axis([-2 2 -4 4 -2 2])                           
                        grid on
                        xlabel('x-axis')
                        ylabel('y-axis')
                        zlabel('z-axis')
                        title([num2str(a), ' ', num2str(s), ' ', num2str(e)])
                        for j = 1:size(J,2)
                            c1 = J(1,j);
                            c2 = J(2,j);
                            line([S(1, c1, n) S(1, c2, n)], [S(2, c1, n) S(2, c2, n)], [S(3, c1, n) S(3, c2, n)]);
                        end                    
                        pause(1/30)
                    end
                end
            end
        end        
    end       
 
elseif (strcmp(dataset, 'Florence3D'))    
    
    J = [1   2   2   2   4   5   7    8     3     3     10   11    13    14;
         2   3   4   7   5   6   8    9    10     13    11   12    14    15];

    for i = 1:length(skeletal_data) 
        S = skeletal_data{i}.original_skeletal_data;
        n_frames = size(S,3);                  
        for n = 1:n_frames
            plot3(S(1,:,n),S(2,:,n),S(3,:,n),'r.');             
            axis([-2 2 -4 4 -2 2])    
            grid on
            xlabel('x-axis')
            ylabel('y-axis')
            zlabel('z-axis')
            title([num2str(skeletal_data{i}.subject), ' ', num2str(skeletal_data{i}.action)])
            for j = 1:size(J,2)
                c1 = J(1,j);
                c2 = J(2,j);
                line([S(1, c1, n) S(1, c2, n)], [S(2, c1, n) S(2, c2, n)], [S(3, c1, n) S(3, c2, n)]);
            end            
            pause(1/10)
        end
    end
    
else
    error('Unknown dataset')
    
end
