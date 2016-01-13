function trial = run_track_trial(vi,...
                            daqObj, ...
                            trial_name, ...
                            trial_time, ...
                            light_power, ...
                            track_params, ...
                            env_map)
%{
    
    run single trial
    input: 
        vi daqObj track_params env_map trial_name light_power trial_time

    output:
        struct

%}


flushdata(vi);

% collect everything into a struture
trial.name = trial_name;
trial.settings.track_params = track_params;
trial.settings.env_map = env_map;
trial.settings.trial_time = trial_time;
trial.settings.light_power = light_power;

% initialize memspace
trial.data.xy = nan(50*trial_time, 2);
trial.data.light = nan(50*trial_time, 1);
trial.data.tstamp = nan(50*trial_time, 1);
trial.data.counter = nan(50*trial_time, 1);
trial.data.tracked_frames = nan(50*trial_time, 1);

tic
tstamp = toc;
p = 0;

start(vi)
% this loop runs the trial
while tstamp < trial_time
    
    p = p+1;
    
    fly = track_frame(vi, track_params);
    
    % handle missed frames and make a note of it
    if isnan(fly.y) || isnan(fly.x)
        if p > 1
            fly.x = trial.data.xy(p-1,1);
            fly.y = trial.data.xy(p-1,2);
            trial.data.tracked_frames(p)= 0;
        end
    else
        trial.data.tracked_frames(p)=1;
    end
        
    
    do_light = env_map(round(fly.y), round(fly.x));
    
    
    if do_light == 1
        daqObj.outputSingleScan([0 light_power]);
    else
       daqObj.outputSingleScan([0 -4.99]); 
    end
    
    if p > 1
        
        if sqrt( ((fly.x - trial.data.xy(p-1,1) )^2) + ((fly.y - trial.data.xy(p-1,2))^2) ) > 12
            fly.x = trial.data.xy(p-1,1);
            fly.y = trial.data.xy(p-1,2);
            trial.data.tracked_frames(p)=-1;
        end
        
    end
    
    tstamp = toc;
    
    trial.data.xy(p,:) = [fly.x fly.y];
    trial.data.light(p) = do_light;
    trial.data.tstamp(p) = tstamp;

end
daqObj.outputSingleScan([0 -4.99]);

trial.data.p = p;

stop(vi);
flushdata(vi);

trial.data.pref_idx = (numel(find(trial.data.light==0))-numel(find(trial.data.light==1)))/trial.data.p;

save([trial_name '.mat'], 'trial')