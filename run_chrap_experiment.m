 disp('turn off fxn generator output, then hit space')
pause()

init_memspace

daqObj = daq.createSession('ni');
daqObj.addAnalogOutputChannel('Dev1', [0:1], 'Voltage');
daqObj.outputSingleScan([0 -4.99]);

disp('turn on fxn generator output, then hit space')
pause()
disp('thank you')

%% experiment settings: modify as needed
exp.settings.name = 'chrap-curve';
exp.settings.geno = 'HCxUAS-Chr';
exp.settings.datecode = datestr(now, 'yyyymmddHHMM');
exp.settings.notes = '1-2 day old, green lights off';
exp.settings.full_name = [exp.settings.datecode '_' exp.settings.geno '_' exp.settings.name];

exp.settings.std_thresh = 1.2;
exp.settings.bg_frames = 1000;
exp.settings.trial_time = 60; % trial time in seconds
exp.settings.light_power = [-4.99 -4 -3 -2 -1 -0];
exp.settings.reps_per_power = 3;
exp.settings.keep_frames = 0;
exp.settings.rand_order = 0;

exp.settings.rep_order = repmat(exp.settings.light_power, [1 exp.settings.reps_per_power]);


if exp.settings.rand_order
    rng(now)
    exp.settings.rep_order = exp.settings.rep_order(randperm(numel(exp.settings.rep_order)));
end
exp.completed = 0;

%% makes / moves to directory
cd('\\reiser_nas\tj\chrap-project')
mkdir(datestr(now, 'yyyymmdd'));
cd(datestr(now, 'yyyymmdd'));
mkdir(exp.settings.full_name);
cd(exp.settings.full_name);

save('metadata.mat', 'exp')

%% initializes camera, daq, env
[vi, cam_params] = init_cam();
track_params = gen_track_params(vi, exp.settings.bg_frames, exp.settings.std_thresh);
env_map = set_envmap(track_params);

exp.track_params = track_params;
exp.env_map = env_map;
exp.cam_params = cam_params;

%% run the actual experiment
f1 = figure('Position', [999 72 795 420], 'color', 'w');
plot([-100 100], [0 0], 'k')
ylim([-1 1])
xlim([exp.settings.light_power(1)-.5 exp.settings.light_power(end)+.5])

plot_labels = {'Off'};
for ii = 2:length(exp.settings.light_power)
    plot_labels{1, ii} = exp.settings.light_power(ii);
end
set(gca, 'XTick', exp.settings.light_power, ...
    'XTickLabel',plot_labels, ...
    'YTick', [-1 -.5 0 .5 1]);
xlabel('power')
ylabel('pref idx')

box off
hold on

keepFrame = exp.settings.keep_frames;

for ii = 1:length(exp.settings.rep_order)
   
    c_power = exp.settings.rep_order(ii);
    
    trial_name = ['trk_' num2str(round(c_power)) '_' num2str(ii, '%02d') '_subA'];
    
    disp(['running trial ' num2str(ii) '/' num2str(length(exp.settings.rep_order)) ' sub A'])
    disp(['current light power is ' num2str(c_power)])
    
    try
    trial = run_track_trial(vi,daqObj, ...
                    trial_name, exp.settings.trial_time, c_power, ...
                    track_params,env_map(1).lookup, keepFrame);
    catch
            stop(vi)
            trial = run_track_trial(vi,daqObj, ...
                    trial_name, exp.settings.trial_time, c_power, ...
                    track_params,env_map(1).lookup, keepFrame);
    end
    
    scatter(c_power, trial.data.pref_idx, 100, 'r');
    
    trial_name = ['trk_'   num2str(round(c_power)) '_' num2str(ii, '%02d') '_subB'];

    disp(['running trial ' num2str(ii) '/' num2str(length(exp.settings.rep_order)) ' sub B'])
    disp(['current light power is ' num2str(c_power)])

    try
    trial = run_track_trial(vi,daqObj, ...
                    trial_name, exp.settings.trial_time, c_power, ...
                    track_params,env_map(2).lookup, keepFrame);    
    catch
        stop(vi)
         trial = run_track_trial(vi,daqObj, ...
                    trial_name, exp.settings.trial_time, c_power, ...
                    track_params,env_map(2).lookup, keepFrame);  
    end
    scatter(c_power, trial.data.pref_idx, 100, 'r');
    
end

daqObj.outputSingleScan([0 -4.99]);

exp.completed = 1;
save('metadata.mat', 'exp')

cd('C:\Users\florencet\Documents\matlab_root')


