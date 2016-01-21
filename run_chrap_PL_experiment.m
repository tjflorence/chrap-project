
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
expp.settings.name = 'chrap-PL';
expp.settings.geno = 'HCxUAS-Chr';
expp.settings.datecode = datestr(now, 'yyyymmddHHMM');
expp.settings.notes = '1-2 day old, gaussblur border, lifted';
expp.settings.full_name = [expp.settings.datecode '_' expp.settings.geno '_' expp.settings.name];

expp.settings.std_thresh = 1.2;
expp.settings.bg_frames = 1000;
expp.settings.trial_time = 90; % trial time in seconds
expp.settings.light_power = [-3];
expp.settings.stim_power = [-4];
expp.settings.keep_frames = 0;
expp.settings.edge_type = 'exp';

expp.settings.pattern_x = [41 185 137 89 0];
rng(now);

rotvec = [-1*ones(1,5) ones(1,5)];
expp.settings.rotvec = [0 rotvec(randperm(length(rotvec)))];
pdice = [1 2;...
        4 3];

t = datevec(now);
s = RandStream('mcg16807','Seed',round(t(end)*100));
RandStream.setGlobalStream(s);
init_rot = randperm(4);
pdice = rot90(pdice, init_rot(1));
expp.settings.quad_order = nan(1, 11);
for ii = 1:length(expp.settings.quad_order)
   
    pdice = rot90(pdice, expp.settings.rotvec(ii));
    expp.settings.quad_order(ii) = pdice(1,1);
    
end

expp.completed = 0;

%% makes / moves to directory
cd('D:\chrap-project\PL\')
mkdir(datestr(now, 'yyyymmdd'));
cd(datestr(now, 'yyyymmdd'));
mkdir(expp.settings.full_name);
cd(expp.settings.full_name);

save('metadata.mat', 'expp')

%% initializes camera, daq, env
[vi, cam_params] = init_cam();

track_params = gen_track_params(vi, expp.settings.bg_frames, expp.settings.std_thresh, daqObj);

env_map = set_PL_envmap(track_params, expp.settings.edge_type);

expp.track_params = track_params;
expp.env_map = env_map;
expp.cam_params = cam_params;

%% run the actual experiment
f1 = figure('Position', [999 72 795 420], 'color', 'w');
plot([-100 100], [0 0], 'k')
ylim([0 expp.settings.trial_time])
xlim([.5 11.5])

set(gca, 'XTick', [1 5 10 11], ...
    'XTickLabel',{'1', '5', '10', 'probe'}, ...
    'YTick', [0 100 200 300]);
xlabel('trial')
ylabel('time to target')

box off
hold on
drawnow

%disp('running pre-trial')
%trial_name = 'ante_00_quad_2';
%pat_x = expp.settings.pattern_x(5);
%c_map = expp.env_map(2).lookup;

%try
%trial = run_PL_track_trial(vi,daqObj, ...
%         trial_name, expp.settings.trial_time, ...
%           track_params,c_map, pat_x);
%catch 
%    stop(vi)
%    trial = run_PL_track_trial(vi,daqObj, ...
%         trial_name, expp.settings.trial_time, ...
%           track_params,c_map, pat_x);
%end
       
%disp('pre trial completed')



for ii = 1:length(expp.settings.quad_order)
   
    c_quad = expp.settings.quad_order(ii);
    
    if ii < 11
        
        trial_name = ['trial_' num2str(ii, '%02d') '_train_quad' num2str(c_quad, '%02d')];
        pat_x = expp.settings.pattern_x(c_quad);
        c_map = expp.env_map(c_quad).lookup;
        
    else
        
        trial_name = ['trial_' num2str(ii, '%02d') '_probe_quad' num2str(c_quad, '%02d')];
        pat_x = expp.settings.pattern_x(c_quad);
        c_map = expp.env_map(5).lookup;

    end
    
    disp(['running trial ' num2str(ii) '/' num2str(length(expp.settings.quad_order))])
    
    try
        
            trial = run_PL_track_trial(vi,daqObj, ...
                    trial_name, expp.settings.trial_time, ...
                    track_params,c_map, pat_x);
    catch
            try
                
            stop(vi)
            trial = run_PL_track_trial(vi,daqObj, ...
                    trial_name, expp.settings.trial_time, ...
                    track_params,c_map, pat_x);
                
            catch
                            stop(vi)
            trial = run_PL_track_trial(vi,daqObj, ...
                    trial_name, expp.settings.trial_time, ...
                    track_params,c_map, pat_x);
            end
    end
    
    scatter(ii, trial.data.time_to_target, 100, 'r');
    hold on
    drawnow
    

    
end
expp.completed = 1;
save('metadata.mat', 'expp')

figure
imagesc(env_map(1).lookup)
hold on
plot(trial.data.xy(:,1), trial.data.xy(:,2), 'r')
scatter(trial.data.xy(1:1500,1), trial.data.xy(1:1500,2), 'r')
axis equal

Panel_com('all_off')
daqObj.outputSingleScan([0 -4.99]);


cd('C:\Users\florencet\Documents\matlab_root')


