function [fly, select_pix, trial] = track_frame(vi, track_params, trial)
%{
    tracks single frame
    returns struct of x,y pixel locations, and fly size in pixels
%}
    hist_len = 14;
    
    c_frame = double(getsnapshot(vi));

    diff_frame = abs(track_params.bg-c_frame);
    pix_inds = find(diff_frame>track_params.thresh_val);

    [yvals, xvals] = ind2sub(track_params.frame_dim, pix_inds);
    tentative_x = round(median(xvals));
    tentative_y = round(median(yvals));
    fly.num_pix = length(yvals);
    
    % handle missed frames and make a note of it
    if isnan(tentative_y) || isnan(tentative_x)
        if trial.data.p > 1
            tentative_x = trial.data.xy(p-1,1);
            tentative_y = trial.data.xy(p-1,2);
            trial.data.tracked_frames(trial.data.p)= 0;
        else
            err('no fly found on first frame')
        end
    else
        trial.data.tracked_frames(trial.data.p)=1;
    end
    
    
    trial.data.xy(trial.data.p, :) = [tentative_x tentative_y];
    
    % get rid of spurious tracking results: kalman filter
    if trial.data.p < (3*hist_len)+1; % only use prior once we have enough observations
        
        trial.data.xy_filt(trial.data.p, :) = [tentative_x tentative_y];
        
    else
        
        z = trial.data.xy(trial.data.p-(3*hist_len):trial.data.p,1:2)';
        [x_kf, ~] = StandardKalmanFilter(z, hist_len, hist_len, 'EWMA');
        
        trial.data.xy_filt(trial.data.p, :) = round(x_kf(1:2, end)');
        
    end
    
    fly.x = trial.data.xy_filt(trial.data.p, 1);
    fly.y = trial.data.xy_filt(trial.data.p, 2);
    
    select_pix = c_frame((fly.y-30):(fly.y+30), (fly.x-30):(fly.x+30));
    
    
end