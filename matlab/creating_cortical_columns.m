graphics_enable = 0; % Control of figure drawings
load para1.mat Map % Load maze
if graphics_enable == 1
    imagesc(Map);
    axis equal
    axis off
    colormap gray
    set(gca,'YDir','normal');
    save('Map.txt','-ascii');
    hold on
end
V_threshold = 0.45; % Threshold for creating a new cortical column
sigma1 = 0.35;
cc_count =1 ; % Cortical column count
pos = [5,2]; % Position of the robot
theta = pi/2; % Head direction
place_cell_center = zeros(500,2);
goal = [5 13];
link = zeros(500,500); % Links between cortical columns
vs = zeros(1,500); % Place cell membrane potential
vs(1)=exp(-((place_cell_center(1,1)-pos(1))^2+(place_cell_center(1,2)-pos(2))^2)/sigma1^2);
place_cell_center(1,:)=pos;
mv_count = 0;
old_index = 1;
if graphics_enable == 1
    plot(place_cell_center(1,1),place_cell_center(1,2),'or');
    hold on
end

while mv_count < 2000 % Move 2000 steps
%% Move
move_step = 0.2; 
old_theta= theta;
theta = theta + (2*rand()-1)*pi/10; % Turn a random angle from -18 to 18 degrees
old_pos = pos;
pos = pos+move_step*[cos(theta),sin(theta)];

%% Bump detection
x_index= round(pos(1));
y_index= round(pos(2));
if Map(y_index,x_index) == 0
    bump = 1;
    pos = old_pos; 
else
    bump = 0;
    mv_count = mv_count +1; 
    if graphics_enable == 1
        plot([old_pos(1),pos(1)],[old_pos(2),pos(2)],'r');
        title({'Rate map',sprintf('t = %d',mv_count)});
        hold on
        drawnow
    end
end

%% Creat cortical column
if bump == 0
    vs(1:cc_count)=exp(-((place_cell_center(1:cc_count,1)-pos(1)).^2+(place_cell_center(1:cc_count,2)-pos(2)).^2)/sigma1^2);
    [~,index] = max(vs(1:cc_count)); % Determine currently the most active place cell
    link(index,old_index)=1;
    link(old_index,index)=1; % Establsih bidirectional link between cortical columns
    [~,old_index] = max(vs(1:cc_count));
    if max(vs(1:cc_count)) < V_threshold % If every place cell activity is below the threshold, create a new cortical column 
        cc_count = cc_count +1;
        place_cell_center(cc_count,:)=pos;
        if graphics_enable == 1
            plot(place_cell_center(cc_count,1),place_cell_center(cc_count,2),'ob');
            hold on
        end
        
    end
end
end

place_cell_center = place_cell_center(1:cc_count,:);
link = link(1:cc_count,1:cc_count);
for i = 1:1:cc_count
    link(i,i) = 0;
end
vs(1:cc_count)=exp(-((place_cell_center(1:cc_count,1)-goal(1)).^2+(place_cell_center(1:cc_count,2)-goal(2)).^2)/sigma1^2);
[~,goal_index] = max(vs(1:cc_count));
save para1.mat
save link link

    





