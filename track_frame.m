function fly = track_frame(vi, track_params)
%{
    tracks single frame
    returns struct of x,y pixel locations, and fly size in pixels
%}
    c_frame = double(getsnapshot(vi));

    diff_frame = abs(track_params.bg-c_frame);
    pix_inds = find(diff_frame>track_params.thresh_val);

    [yvals, xvals] = ind2sub(track_params.frame_dim, pix_inds);
    fly.x = mean(xvals);
    fly.y = mean(yvals);
    fly.num_pix = length(yvals);
    
end