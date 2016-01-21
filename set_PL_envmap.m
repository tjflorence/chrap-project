function env_map = set_PL_envmap(track_params, edge_type)
%{
    
    creates 2x2 tilemap lookup table for tracking
    modify here to change punished world

%}

env_map(1).lookup = -3*ones(track_params.frame_dim);
env_map(1).lookup(300:500, 300:500) = -4.99;

    
if strcmp(edge_type, 'gauss')
    
    G = fspecial('gaussian',[100 100],50);
    env_map(1).lookup = imfilter(env_map(1).lookup,G,'same');
    env_map(1).lookup(env_map(1).lookup>-3)=-3;
    
elseif strcmp(edge_type, 'exp')
    
    % locate center of cool spot
    cool_inds = find(env_map(1).lookup < -4.9);
    [cool_y, cool_x] = ind2sub(size(env_map(1).lookup), cool_inds);
    
    center_x = round(median(cool_x));
    center_y = round(median(cool_y));
    
    edge_width = 100+40;
    edge_dist = 75-40;
    
    edge_vec = 1:edge_width;
    edge_vec = fliplr(edge_vec);
    
    for ii = edge_vec
       
        y_start = (center_y-edge_dist)-ii;
        y_end = (center_y+edge_dist)+ii;
        
        x_start = (center_x-edge_dist)-ii;
        x_end = (center_x+edge_dist)+ii;
        
        c_prop = exp(ii/20)/exp(max(edge_vec)/20);
        c_val = -5+(c_prop*2);
        
        
        env_map(1).lookup(y_start:y_end, x_start:x_end) = c_val;
        
    end
    
    
    env_map(1).lookup((center_y-edge_dist):(center_y+edge_dist), ...
                        (center_x-edge_dist):(center_x+edge_dist)) = -4.99;
    
    env_map(1).lookup(env_map(1).lookup<-4.99) = -4.99;
end


env_map(2).lookup = rot90(env_map(1).lookup, -1);
env_map(3).lookup = rot90(env_map(2).lookup, -1);
env_map(4).lookup = rot90(env_map(3).lookup, -1);
env_map(5).lookup = -3*ones(track_params.frame_dim);

end