function process_PL_experiment

expdir = '/Users/florencet/Documents/matlab_root/chrap-project/meeting_and_analysis/20160120/20160119/201601190046_HCxUAS-Chr_chrap-PL';

cd(expdir)

tfiles = dir('trial*');

for ii = 1:length(tfiles)
   
    load(tfiles(ii).name)
    
    
end

    function trial = kfilt_trajectory(trial)
        

    end

    function calc_tspeed
    end

    function calc_time_to_target
    end


    function calc_time_at_target
    end

    function calc_quad_pref
    end
    
end