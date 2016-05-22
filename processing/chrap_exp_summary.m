function chrap_exp_summary(expdir)

%{

    Collects summary data for light-avoidance 
    intensity tuning experiment 
    
    
%}

% set summary power conditions
summary.conditions = {'-5', '-4', '-3', '-2', '-1', '0'};
summary.pi_mean = nan(1,5);
summary.pi_std = nan(1,5);


cd(expdir);


for jj = 1:length(summary.conditions)
    
    c_power = summary.conditions{jj}; % set current power to collect
    c_files = dir(['*_' c_power '_*']); % find these trials

    c_PI = nan(2,3); % 3 reps, + A/B conditions
    p = 0; % pointer to current trial
    
    % collect all trials into summary matrix
    for ii = 1:3
   
        p = p+1;
        load(c_files(p).name)
        c_PI(1,ii) = trial.data.pref_idx;
    
        p = p+1;
        load(c_files(p).name)
        c_PI(2,ii) = trial.data.pref_idx;
    
    
    end

    mean_by_trial = mean(c_PI); % average A/B conditions
    std_by_trial = std(c_PI);
    mean_by_condition = mean(mean_by_trial); % average conditions
    std_by_condition = std(mean_by_trial);

    per_trial(jj).all_PI = c_PI;
    per_trial(jj).mean_by_trial = mean_by_trial;
    per_trial(jj).std_by_trial = std_by_trial;
    
    summary.pi_mean(jj) = mean_by_condition;
    summary.pi_std(jj) = std_by_condition;
    
    
end

% save summary data
save('summary_data.mat', 'summary', 'per_trial')