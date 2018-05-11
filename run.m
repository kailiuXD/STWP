
tic
for i = 3:3
    for j = 1:9
        skeletal_action_classification(i,j)
    end
end
toc

%{
clear all;
clc;
%%
e = 2; g = 1;
[x,y] = meshgrid(0:20,0:15);  % This makes regular grid
u = e*x-g*y;                  % Linear velocity field
v = g*x-e*y;
[phi,psi] = flowfun(u,v);  % Here comes the potential and streamfun.
%
contour(phi,20,'--r','Displayname','\phi')   % Contours of potential
hold on
contour(psi,20,'-g','Displayname','\psi')    % Contours of streamfunction
quiver(x,y,u,v,'Displayname','velocity')         % Now superimpose the velocity field
legend show;
%}