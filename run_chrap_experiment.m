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
exp.settings.geno = 'uas-Chr';
exp.settings.datecode = datestr(now, 'yyyymmddHHMM');
exp.settings.notes = '6 days old';
exp.settings.full_name = [exp.settings.datecode '_' exp.settings.geno '_' exp.settings.name];

exp.settings.std_thresh = 1.2;
exp.settings.bg_frames = 1000;
exp.settings.trial_time = 30; % trial time in seconds
exp.settings.light_power = [-4.99 -4 -3 -2 -1 0];
exp.settings.reps_per_power = 3;

exp.settings.rep_order = repmat(exp.settings.light_power, [1 exp.settings.reps_per_power]);
exp.settings.rand_order = 1;

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
xlim([-5.5 0])

set(gca, 'XTick', [-4.99 -4 -3 -2 -1 0], ...
    'XTickLabel', {'Off', '-4', '-3', '-2', '-1', '0'}, ...
    'YTick', [-1 -.5 0 .5 1]);
xlabel('power')
ylabel('pref idx')

box off
hold on


for ii = 1:length(exp.settings.rep_order)
   
    c_power = exp.settings.rep_order(ii);
    
    trial_name = ['trk_' num2str(round(c_power)) '_' num2str(ii, '%02d') '_subA'];
    
    disp(['running trial ' num2str(ii) '/' num2str(length(exp.settings.rep_order)) ' sub A'])
    disp(['current light power is ' num2str(c_power)])
    
    try
    trial = run_track_trial(vi,daqObj, ...
                    trial_name, exp.settings.trial_time, c_power, ...
                    track_params,env_map(1).lookup);
    catch
            stop(vi)
            trial = run_track_trial(vi,daqObj, ...
                    trial_name, exp.settings.trial_time, c_power, ...
                    track_params,env_map(1).lookup);
    end
    
    scatter(c_power, trial.data.pref_idx, 100, 'r');
    
    trial_name = ['trk_'   num2str(round(c_power)) '_' num2str(ii, '%02d') '_subB'];

    disp(['running trial ' num2str(ii) '/' num2str(length(exp.settings.rep_order)) ' sub B'])
    disp(['current light power is ' num2str(c_power)])

    try
    trial = run_track_trial(vi,daqObj, ...
                    trial_name, exp.settings.trial_time, c_power, ...
                    track_params,env_map(2).lookup);    
    catch
        stop(vi)
         trial = run_track_trial(vi,daqObj, ...
                    trial_name, exp.settings.trial_time, c_power, ...
                    track_params,env_map(2).lookup);  
    end
    scatter(c_power, trial.data.pref_idx, 100, 'r');
    
end

daqObj.outputSingleScan([0 -4.99]);

exp.completed = 1;
save('metadata.mat', 'exp')

cd('C:\Users\florencet\Documents\matlab_root')

