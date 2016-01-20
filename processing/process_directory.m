%{

    process all files in directory

%}
homedir = pwd;
datadir = '/Users/florencet/Documents/matlab_root/chrap-project/meeting_and_analysis/20160118';

cd(datadir)

dayfiles = dir('2016*');
for ii = 1:length(dayfiles)

    cd([datadir '/' dayfiles(ii).name])
    expfiles = dir('*_chrap-curve');
    
    for jj = 1:length(expfiles)
        

        cd([expfiles(jj).name])
        load('metadata.mat')
        
        if exp.completed == 0
            cd('..')
            rmdir(expfiles(jj).name, 's')
            
        elseif ~ isfield(exp, 'processed')
            
            chrap_exp_summary(pwd)
            plot_adaptation_check(pwd)
            plot_chrap_trajectory(pwd)
            exp.processed = 1;
            
            save('metadata.mat', 'exp')
            
            cd('..')
        else
            
            cd('..')
            
        end
        
        
    end

end

cd(homedir)