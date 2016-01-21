
disp('turn off fxn generator output, then hit space')
pause()

init_memspace

daqObj = daq.createSession('ni');
daqObj.addAnalogOutputChannel('Dev1', [0:1], 'Voltage');
daqObj.outputSingleScan([0 -4.99]);

disp('turn on fxn generator output, then hit space')
pause()
disp('thank you')

Panel_com('set_pattern_id', [2])
Panel_com('all_off')

%% experiment settings: modify as needed
exp.settings.name = 'chrap-PL';
exp.settings.geno = 'HCxUAS-Chr';
exp.settings.datecode = datestr(now, 'yyyymmddHHMM');
exp.settings.notes = '1-2 day old, gaussblur border, lifted';
exp.settings.full_name = [exp.settings.datecode '_' exp.settings.geno '_' exp.settings.name];

exp.settings.std_thresh = 1.2;
exp.settings.bg_frames = 1000;
exp.settings.trial_time = 90; % trial time in seconds
exp.settings.light_power = [-3];
exp.settings.stim_power = [-4];
exp.settings.keep_frames = 0;

exp.settings.pattern_x = [41 185 137 89 0];
rotvec = [-1*ones(1,5) ones(1,5)];
exp.settings.rotvec = [0 rotvec(randperm(length(rotvec)))];
pdice = [1 2;...
        4 3];

exp.settings.quad_order = nan(1, 11);
for ii = 1:length(exp.settings.quad_order)
   
    pdice = rot90(pdice, exp.settings.rotvec(ii));
    exp.settings.quad_order(ii) = pdice(1,1);
    
end

exp.completed = 0;

%% makes / moves to directory
cd('D:\chrap-project\PL\')
mkdir(datestr(now, 'yyyymmdd'));
cd(datestr(now, 'yyyymmdd'));
mkdir(exp.settings.full_name);
cd(exp.settings.full_name);

save('metadata.mat', 'exp')

%% initializes camera, daq, env
[vi, cam_params] = init_cam();

track_params = gen_track_params(vi, exp.settings.bg_frames, exp.settings.std_thresh, daqObj);

env_map = set_PL_envmap(track_params);

exp.track_params = track_params;
exp.env_map = env_map;
exp.cam_params = cam_params;

%% run the actual experiment
f1 = figure('Position', [999 72 795 420], 'color', 'w');
plot([-100 100], [0 0], 'k')
ylim([0 exp.settings.trial_time])
xlim([.5 11.5])

set(gca, 'XTick', [1 5 10 11], ...
    'XTickLabel',{'1', '5', '10', 'probe'}, ...
    'YTick', [0 100 200 300]);
xlabel('trial')
ylabel('time to target')

box off
hold on
drawnow

disp('running pre-trial')
trial_name = 'ante_00_quad_2';
pat_x = exp.settings.pattern_x(5);
c_map = exp.env_map(2).lookup;

try
trial = run_PL_track_trial(vi,daqObj, ...
         trial_name, exp.settings.trial_time, ...
           track_params,c_map, pat_x);
catch 
    stop(vi)
    trial = run_PL_track_trial(vi,daqObj, ...
         trial_name, exp.settings.trial_time, ...
           track_params,c_map, pat_x);
end
       
disp('pre trial completed')



for ii = 1:length(exp.settings.quad_order)
   
    c_quad = exp.settings.quad_order(ii);
    
    if ii < 11
        
        trial_name = ['trial_' num2str(ii, '%02d') '_train_quad' num2str(c_quad, '%02d')];
        pat_x = exp.settings.pattern_x(c_quad);
        c_map = exp.env_map(c_quad).lookup;
        
    else
        
        trial_name = ['trial_' num2str(ii, '%02d') '_probe_quad' num2str(c_quad, '%02d')];
        pat_x = exp.settings.pattern_x(c_quad);
        c_map = exp.env_map(5).lookup;

    end
    
    disp(['running trial ' num2str(ii) '/' num2str(length(exp.settings.quad_order))])
    
    try
        
            trial = run_PL_track_trial(vi,daqObj, ...
                    trial_name, exp.settings.trial_time, ...
                    track_params,c_map, pat_x);
    catch
            try
                
            stop(vi)
            trial = run_PL_track_trial(vi,daqObj, ...
                    trial_name, exp.settings.trial_time, ...
                    track_params,c_map, pat_x);
                
            catch
                            stop(vi)
            trial = run_PL_track_trial(vi,daqObj, ...
                    trial_name, exp.settings.trial_time, ...
                    track_params,c_map, pat_x);
            end
    end
    
    scatter(ii, trial.data.time_to_target, 100, 'r');
    hold on
    drawnow
    

    
end
exp.completed = 1;
save('metadata.mat', 'exp')

figure
imagesc(env_map(1).lookup)
hold on
plot(trial.data.xy(:,1), trial.data.xy(:,2), 'r')
scatter(trial.data.xy(1:1000,1), trial.data.xy(1:1000,2), 'k')
axis equal

Panel_com('all_off')
daqObj.outputSingleScan([0 -4.99]);


cd('C:\Users\florencet\Documents\matlab_root')


