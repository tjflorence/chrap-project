exp_struct(1).env_map = zeros(track_params.frame_dim);
mid_y = (track_params.frame_dim(1))/2;
mid_x = (track_params.frame_dim(2))/2;

exp_struct(1).env_map(1:mid_y, 1:mid_x) = 1;
exp_struct(1).env_map(mid_y:end, mid_x:end) = 1;

exp_struct(2).env_map