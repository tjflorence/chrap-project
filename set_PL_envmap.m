function env_map = set_PL_envmap(track_params)
%{
    
    creates 2x2 tilemap lookup table for tracking
    modify here to change punished world

%}

env_map(1).lookup = -3*ones(track_params.frame_dim);
env_map(1).lookup(300:550, 300:550) = -4.99;

G = fspecial('gaussian',[100 100],50);
env_map(1).lookup = imfilter(env_map(1).lookup,G,'same');
env_map(1).lookup(env_map(1).lookup>-3)=-3;

env_map(2).lookup = rot90(env_map(1).lookup, -1);
env_map(3).lookup = rot90(env_map(2).lookup, -1);
env_map(4).lookup = rot90(env_map(3).lookup, -1);
env_map(5).lookup = -3*ones(track_params.frame_dim);

end