function wavefront_propagation()
load para1.mat;
% save link link
load link
graphics_enable = 0; % Control of figure drawings
cmap = jet;
vr_threshold = 0.35; 
tau_r = 0.9;
tau_stdp = 0.01;
fire_time_q = 99 * ones(1,cc_count); % Interneuron q firing time
fired = zeros(1, cc_count); % Mark of action potential firings
weight_q = zeros(cc_count,cc_count);% Weights between interneuron q
direction = zeros(cc_count,2); 
vr = zeros(1, cc_count); % Reward cell membrane potential
vr_copy = zeros(1, cc_count); % Used for serial computation
t=0;
while (t<1.5)
    for i = 1:1:cc_count
        if fired(i) == 1 
            vr(i) = max(vr(i) + 1/tau_r * -vr(i),0); % Depression after firing action potential
        else
            vr(i) = min(vr(i) + 1/tau_r * (-vr(i) + vr_copy * link(:,i)),1); 
        end
        if (vr(i) > vr_threshold) && (fired(i) ~= 1)
            fire_time_q(i) = t;
            fired(i) = 1;
            link_cell = find(link(:,i)==1);
            link_number = size(link_cell);
            for j = 1:1:link_number(1)
                k = link_cell(j);
                if fire_time_q(i) > fire_time_q(k) && k~=i
                    delta_weight_q = exp(-(fire_time_q(k)-fire_time_q(i))/tau_stdp); % Interneuron q weight changes according to STDP learning rule
                    weight_q(k,i) = min(weight_q(k,i) + delta_weight_q,1);
                end
            end
        end
    end 
    vr_copy = vr;
    if t == 0.02 % Set an action potential at the beginning on goal reward cell representing reward
        vr_copy(goal_index) = 1;
        fired(goal_index) = 1;
        fire_time_q(goal_index) = 0.02;
    end
    if graphics_enable == 1
        figure(1)
        hold off 
        plot(1,1);
        figure(1)
        axis equal
        hold on
        color = cmap(ceil(vr * (length(cmap) -1))+1,:);
        scatter(place_cell_center(:,1),place_cell_center(:,2),[],color,'filled');        
        title({'Reward cell activity',sprintf('t = %f s',t)});
        drawnow
    end
    t = t + 0.02;
    %pause(0.02);
end

for i = 1:1:cc_count % Plot the action direction vector field
    pc_vector = [place_cell_center(:,1) - place_cell_center(i,1),place_cell_center(:,2) - place_cell_center(i,2)];
    direction(i,:) = pc_vector' * weight_q(:,i);
    direction(i,:) = direction(i,:) / norm(direction(i,:)) / 5;
end
if graphics_enable == 1
    figure(2)
    axis equal
    hold on
    quiver(place_cell_center(:,1),place_cell_center(:,2),direction(:,1),direction(:,2),0.3,'b');
end
for i = 1:1:cc_count
    weight_q(i,i) = 0;
end
save weight_q weight_q
save direction direction