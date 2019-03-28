function navigation
load para1.mat
graphics_enable = 1; % Control of figure drawings
curr_index = 1;
curr_pos = [5 3];
Achievable_Map(7,5) = 0; % Block middle way
Achievable_Map(7,2) = 0; % Block left way
% Achievable_Map(7,10) = 0; % Block right way
% Achievable_Map(10,5) = 0; % Block up-middle way
if graphics_enable == 1
    figure(1)
    imagesc(Achievable_Map);
    axis equal
    axis off
    colormap gray
    set(gca,'YDir','normal');
    hold on
end
while(curr_index ~= goal_index)
    load direction
    load weight_q
    old_pos = curr_pos;
    pc_vector = [place_cell_center(:,1) - place_cell_center(curr_index,1),place_cell_center(:,2) - place_cell_center(curr_index,2)];
    a = direction(curr_index,:); % Preferred action direction
    c = find(link(:,curr_index) == 1);
    b = pc_vector(c,[1,2]);
    theta1 = acos(a*b'./norm(a)./norm(b)); 
    next_index = find(weight_q(:,curr_index)==max(weight_q(:,curr_index)));
    next_index = next_index(1);
    curr_pos = place_cell_center(next_index,:);
    x_index= round(place_cell_center(next_index,1));
    y_index= round(place_cell_center(next_index,2));
    if Achievable_Map(y_index,x_index) == 0 % Obstacle detected by laser scan sensor
        curr_pos = old_pos;
        link(next_index,curr_index) = 0; % Reward cell weight changes according to LTD
        save link link
        wavefront(); % Recalculate path by propagating wavefronts
        load direction
        next_index	= curr_index;
    end
    if graphics_enable == 1
        figure(1)
        plot([old_pos(1),curr_pos(1)],[old_pos(2),curr_pos(2)],'LineWidth',3,'Color','k');
        drawnow
    end
    curr_index = next_index;
end