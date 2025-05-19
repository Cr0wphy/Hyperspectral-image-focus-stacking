function [G_p, idx] = decompose3(G, n_levels, w)
%DECOMPOSE Summary of this function goes here
%   Detailed explanation goes here

channels = size(G,3);

% creating arrays of indices
G_px = [size(G,1) zeros(1,n_levels)];
G_py = [size(G,2) zeros(1,n_levels)];
G_ps = [ones(2,1) zeros(2,n_levels)];

G_p = [G zeros(size(G,1),ceil(size(G,2)/2),channels)];
clear G;


% start and end of every image level:
idx = zeros(2,2,n_levels+1);
% function reduce & initializing levels positions:
if n_levels == 0
    last_x_idx = G_ps(1,1):G_ps(1,1) + G_px(1) - 1;
    last_y_idx = G_ps(2,1):G_ps(2,1) + G_py(1) - 1;
    idx(:,1,1) = [last_x_idx(1); last_y_idx(1)];
    idx(:,2,1) = [last_x_idx(end); last_y_idx(end)];
end

for i=2:n_levels+1
    % position of last picture
    if i == 2
        last_x_idx = G_ps(1,i-1):G_ps(1,i-1) + G_px(i-1) - 1;
        last_y_idx = G_ps(2,i-1):G_ps(2,i-1) + G_py(i-1) - 1;
        idx(:,1,1) = [last_x_idx(1); last_y_idx(1)];
        idx(:,2,1) = [last_x_idx(end); last_y_idx(end)];
        
    end
    % reduction
    if i == 2
        [G_p_temp, ~]= reduce_g2(G_p(last_x_idx,last_y_idx,:),w);
    else
        % we dont need reduce, just expand + imresize, saving computing
        % time
        N = ceil(size(G_p_temp_next,1)/2);
        M = ceil(size(G_p_temp_next,2)/2);
        G_p_temp = imresize(G_p_temp_next,[N M],'method','nearest','Antialiasing',0);
    end
    % while making Gi*, make Gi+1,s as well
    [G_star_temp, G_p_temp_next] =  expand_g2(G_p_temp,w);
    
    G_p(last_x_idx,last_y_idx,:) = G_p(last_x_idx,last_y_idx,:) - G_star_temp(1:length(last_x_idx),1:length(last_y_idx),:);

    % size of new picture
    G_px(i) = size(G_p_temp,1);
    G_py(i) = size(G_p_temp,2);
    % assign new starting coordinate
    if mod(i,2) == 0
        G_ps(1,i) = G_ps(1,i-1);
        G_ps(2,i) = last_y_idx(end)+1;
    else
        G_ps(1,i) = last_x_idx(end)+1;
        G_ps(2,i) = G_ps(2,i-1);
    end
    % get new image coordinates, place new image
    new_x_idx = G_ps(1,i):G_ps(1,i) + G_px(i) - 1;
    new_y_idx = G_ps(2,i):G_ps(2,i) + G_py(i) - 1;
    G_p(new_x_idx,new_y_idx,:) = G_p_temp;
    last_x_idx = new_x_idx;
    last_y_idx = new_y_idx;
    idx(:,1,i) = [last_x_idx(1); last_y_idx(1)];
    idx(:,2,i) = [last_x_idx(end); last_y_idx(end)];
end


end

