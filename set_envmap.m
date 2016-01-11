function env_map = set_envmap()
%{
    
    creates 2x2 tilemap lookup table for tracking

%}

env_map(1).lookup = zeros(track_params.frame_dim);
mid_y = (track_params.frame_dim(1))/2;
mid_x = (track_params.frame_dim(2))/2;

env_map(1).lookup(1:mid_y, 1:mid_x) = 1;
env_map(1).lookup(mid_y:end, mid_x:end) = 1;

env_map(2).env_map = fliplr(exp_struct(1).env_map);

end