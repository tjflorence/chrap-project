function trial = run_PL_track_trial(vi,...
                            daqObj, ...
                            trial_name, ...
                            trial_time, ...
                            track_params, ...
                            env_map, pat_pos)
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

% initialize memspace
trial.data.xy = nan(50*trial_time, 2);
trial.data.xy_filt = nan(50*trial_time, 2);
trial.data.light_power = nan(50*trial_time, 1);
trial.data.tstamp = nan(50*trial_time, 1);
trial.data.counter = nan(50*trial_time, 1);
trial.data.tracked_frames = nan(50*trial_time, 1);
trial.data.select_pix = nan(61,61, 50*trial_time);

tic
tstamp = toc;
p = 0;

start(vi)

daqObj.outputSingleScan([0 -3]);
Panel_com('set_position', [pat_pos 1])

% this loop runs the trial
while tstamp < trial_time
    
    p = p+1;
    
    [fly,  select_pix, trial] = track_frame(vi, track_params, trial);
    
        
    light_power = env_map(fly.y, fly.x);
    daqObj.outputSingleScan([0 light_power]);
        
    tstamp = toc;
    trial.data.select_pix(:,:,p) = select_pix;
    trial.data.light_power(p) = light_power;
    trial.data.tstamp(p) = tstamp;

end

daqObj.outputSingleScan([0 light_power]);
Panel_com('all_off')

trial.data.p = p;

stop(vi);
flushdata(vi);

first_cool = find(trial.data.light_power < -4.9, 1, 'first');

if ~isempty(first_cool)
    trial.data.time_to_target = trial.data.tstamp(first_cool);
else
    trial.data.time_to_target = trial_time;
end

save([trial_name '.mat'], 'trial', '-v7.3')