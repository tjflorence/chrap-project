function process_PL_experiment(expdir)


cd(expdir)

load('metadata.mat')

if expp.completed == 0
    cd('..')
    rmdir(expdir, 's')
else
    
    tfiles = dir('trial*');
    
    summary_data.mean_speed = nan(1,11);
    summary_data.time_to_target = nan(1,11);
    summary_data.time_at_target = nan(1,11);
    summary_data.quad_pref = nan(1,11);
    summary_data.dir_idx = nan(1,11);
    summary_data.PLI_30 = nan;
    summary_data.PLI_60 = nan;

    for ii = 1:length(tfiles)
   
        load(tfiles(ii).name)
        trial = calc_tspeed(trial, expp);
        trial = calc_theta(trial, expp);
        trial = calc_time_to_target(trial, expp);
        trial = calc_time_at_target(trial, expp);
        trial = calc_quad_pref(trial, expp);
        trial = calc_direction_idx(trial, expp);
        
        summary_data.mean_speed(ii) = nanmean(trial.data.speed(trial.data.speed>5));
        summary_data.time_to_target(ii) = trial.data.time_to_target;
        summary_data.time_at_target(ii) = trial.data.time_at_target;
        summary_data.quad_pref(ii) = trial.data.quad_pref_full;
        summary_data.dir_idx(ii) = trial.data.dir_idx;
        
        
        if ii == 11
           
            summary_data.PLI_30 = trial.data.quad_pref_30;
            summary_data.PLI_60 = trial.data.quad_pref_60;
            
        end
        
        
        save([trial.name '.mat'], 'trial', '-v7.3')
    
    end
    
    save('summary_data.mat', 'summary_data', '-v7.3')

end


end

  

function trial = calc_tspeed(trial, expp)
    
    mm_per_pix = 0.2073;
    
    
    if ~isfield(trial.data, 'xy_filt')
        trial.data.xy_filt = trial.data.xy;
    end
    
    x = trial.data.xy_filt(:,1);
    y = trial.data.xy_filt(:,2);
    t = trial.data.tstamp;
    
    x_diff = x(2:end)-x(1:end-1);
    y_diff = y(2:end)-y(1:end-1);
    t_diff = t(2:end)-t(1:end-1);
    
    dist = sqrt((x_diff.^2) + (y_diff.^2));
    
    dist_filt = medfilt1(dist, 11);
    
    trial.data.speed = (dist_filt./t_diff)*mm_per_pix;
    
     
end

function trial = calc_theta(trial, expp)

    xdiff = trial.data.xy(2:end, 1) - trial.data.xy(1:end-1, 1);
    ydiff = trial.data.xy(2:end, 2) - trial.data.xy(1:end-1, 2);

    trial.data.theta = [0 ; movingmean(atan2d(ydiff, xdiff), 15)];

end



function trial = calc_time_to_target(trial, expp)

    c_power = expp.settings.stim_power;
    
    at_target_ind = find(trial.data.light_power < c_power, 1, 'first');
    if ~isempty(at_target_ind)
        trial.data.time_to_target = trial.data.tstamp(at_target_ind);
    else
        trial.data.time_to_target = trial.settings.trial_time;
    end

end

function trial = calc_time_at_target(trial, expp)
    
    c_power = expp.settings.stim_power;

    hz = trial.data.p/trial.data.tstamp(trial.data.p);
    cool_inds = find(trial.data.light_power < c_power);
    
    if ~isempty(cool_inds)
        trial.data.time_at_target = numel(cool_inds)/hz;
    else
        trial.data.time_at_target = 0;
    end
    
end

function trial = calc_quad_pref(trial, expp)

    split_1 = strsplit(trial.name, 'quad');
    split_2 = strsplit(split_1{2}, 'd');
    
    target_Q = str2num(split_2{2});
  
    % first do for whole trial
    x_vals = trial.data.xy_filt(:,1);
    y_vals = trial.data.xy_filt(:,2);
    
    if target_Q == 1
        
        ind_t = find(x_vals < 600 & y_vals < 600);
        ind_d = find(x_vals > 600 & y_vals > 600);
        
    elseif target_Q == 2
        
        ind_t = find(x_vals > 600 & y_vals < 600);
        ind_d = find(x_vals < 600 & y_vals > 600);
        
    elseif target_Q == 3
        
        ind_t = find(x_vals > 600 & y_vals > 600);
        ind_d = find(x_vals < 600 & y_vals < 600);
        
    elseif target_Q == 4
        
        ind_d = find(x_vals > 600 & y_vals < 600);
        ind_t = find(x_vals < 600 & y_vals > 600);
        
    end

        
     trial.data.quad_pref_full = (numel(ind_t)-numel(ind_d))...
                                /(numel(ind_t)+numel(ind_d));
                            
                            
     % now find at 30 sec and 60 sec
     ind_30 = find(trial.data.tstamp> 30, 1, 'first');
     
    x_vals = trial.data.xy_filt(1:ind_30,1);
    y_vals = trial.data.xy_filt(1:ind_30,2);
    
    if target_Q == 1
        
        ind_t = find(x_vals < 600 & y_vals < 600);
        ind_d = find(x_vals > 600 & y_vals > 600);
        
    elseif target_Q == 2
        
        ind_t = find(x_vals > 600 & y_vals < 600);
        ind_d = find(x_vals < 600 & y_vals > 600);
        
    elseif target_Q == 3
        
        ind_t = find(x_vals > 600 & y_vals > 600);
        ind_d = find(x_vals < 600 & y_vals < 600);
        
    elseif target_Q == 4
        
        ind_d = find(x_vals > 600 & y_vals < 600);
        ind_t = find(x_vals < 600 & y_vals > 600);
        
    end

        
     trial.data.quad_pref_30 = (numel(ind_t)-numel(ind_d))...
                                /(numel(ind_t)+numel(ind_d));
                            
    % now at 60 seconds 
    ind_60 = find(trial.data.tstamp> 60, 1, 'first');
     
    x_vals = trial.data.xy_filt(1:ind_60,1);
    y_vals = trial.data.xy_filt(1:ind_60,2);
    
    if target_Q == 1
        
        ind_t = find(x_vals < 600 & y_vals < 600);
        ind_d = find(x_vals > 600 & y_vals > 600);
        
    elseif target_Q == 2
        
        ind_t = find(x_vals > 600 & y_vals < 600);
        ind_d = find(x_vals < 600 & y_vals > 600);
        
    elseif target_Q == 3
        
        ind_t = find(x_vals > 600 & y_vals > 600);
        ind_d = find(x_vals < 600 & y_vals < 600);
        
    elseif target_Q == 4
        
        ind_d = find(x_vals > 600 & y_vals < 600);
        ind_t = find(x_vals < 600 & y_vals > 600);
        
    end

        
     trial.data.quad_pref_60 = (numel(ind_t)-numel(ind_d))...
                                /(numel(ind_t)+numel(ind_d));
                            
    
end

function trial = calc_direction_idx(trial, expp)

    split_1 = strsplit(trial.name, 'quad');
    split_2 = strsplit(split_1{2}, 'd');
    
    target_Q = str2num(split_2{2});
  
    % first do for whole trial
    x_vals = trial.data.xy_filt(:,1);
    y_vals = trial.data.xy_filt(:,2);
    
    if target_Q == 1
        
        ind_t = find(x_vals < 600 & y_vals < 600);
        ind_d = find(x_vals > 600 & y_vals > 600);
        
    elseif target_Q == 2
        
        ind_t = find(x_vals > 600 & y_vals < 600);
        ind_d = find(x_vals < 600 & y_vals > 600);
        
    elseif target_Q == 3
        
        ind_t = find(x_vals > 600 & y_vals > 600);
        ind_d = find(x_vals < 600 & y_vals < 600);
        
    elseif target_Q == 4
        
        ind_d = find(x_vals > 600 & y_vals < 600);
        ind_t = find(x_vals < 600 & y_vals > 600);
        
    end

    if isempty(ind_t)
        ind_t = Inf;
    end
    
    if isempty(ind_d)
        ind_d = Inf;
    end
    
    if ind_t(1) < ind_d(1) 
        trial.data.dir_idx = 1;
    elseif ind_t(1) > ind_d(1) 
        trial.data.dir_idx = -1;
    else
         trial.data.dir_idx = 0;
    end
        
        

end

    
