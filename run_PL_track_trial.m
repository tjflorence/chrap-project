function trial = run_PL_track_trial(vi,...
                            daqObj, ...
                            trial_name, ...
                            trial_time, ...
                            track_params, ...
                            env_map, pat_pos)
%{
    
    run single PL trial
    input: 
        vi - video input object (camera object)
        daqObj - NI data acquisition object
        track_params - tracking parameters
        env_map - environment map (light intensity lookup table)
        trial_name - name of current trial
        light_power - baseline light power
        trial_time - time to run current trial

    output:
        trial - trial data summary struct

%}

% clear any video data in memory buffer
flushdata(vi);

% collect everything into a struture
trial.name = trial_name;
trial.settings.track_params = track_params;
trial.settings.env_map = env_map;
trial.settings.trial_time = trial_time;

% initialize memspace
trial.data.xy = nan(50*trial_time, 2); % raw xy position
trial.data.xy_filt = nan(50*trial_time, 2); % xy position after kalman filter
trial.data.light_power = nan(50*trial_time, 1); % instantaneous light power
trial.data.tstamp = nan(50*trial_time, 1); % frame timestamp
trial.data.counter = nan(50*trial_time, 1); % frame counter
trial.data.tracked_frames = nan(50*trial_time, 1); % boolean: is new tracked frame or is tossed frame
trial.data.select_pix = nan(61,61, 50*trial_time); % pixel data around fly center ...
                                                    % (used to recreate video frames, think cheap fmf)

tic
tstamp = toc;
p = 0;

% start camera
start(vi)

daqObj.outputSingleScan([0 -3]);
if pat_pos > 0
    Panel_com('set_position', [pat_pos 1])
else
    Panel_com('all_off');
end

% this loop runs the trial
while tstamp < trial_time
    
    % increment frame counter
    p = p+1;
    
    trial.data.p = p;
    
    % perform bg subtract tracking on current frame
    [fly,  select_pix, trial] = track_frame(vi, track_params, trial);
    
    % light power to output is simply xy index into environment map
    light_power = env_map(fly.y, fly.x);
    
    % these just smooth out any light intensity weirdness
    if light_power > -4.90
        light_power = normrnd(light_power, .1);
    else
        light_power = normrnd(light_power, .01);
    end
    if light_power < -4.99
        light_power = -4.99;
    end
    
    % output current light power
    daqObj.outputSingleScan([0 light_power]);
        
    tstamp = toc;
    trial.data.select_pix(:,:,p) = select_pix;
    trial.data.light_power(p) = light_power;
    trial.data.tstamp(p) = tstamp;

end

daqObj.outputSingleScan([0 light_power]);
Panel_com('all_off')



stop(vi);
flushdata(vi);

first_cool = find(trial.data.light_power < -4.9, 1, 'first');

if ~isempty(first_cool)
    trial.data.time_to_target = trial.data.tstamp(first_cool);
else
    trial.data.time_to_target = trial_time;
end

% must save as v7.3 (mat file size will be large)
save([trial_name '.mat'], 'trial', '-v7.3')


end