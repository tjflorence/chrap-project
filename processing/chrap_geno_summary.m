cd('/Users/florencet/Documents/matlab_root/chrap-project')

geno(1).strterm = '*Empty*'
geno(1).p = 1;
geno(2).strterm = '*Gr28*'
geno(2).p = 1;
geno(3).strterm = '*HC*'
geno(3).p = 1;

%% Collect experiment files
datadir = '/Users/florencet/Documents/matlab_root/chrap-project/meeting_and_analysis/20160118';

cd(datadir)
dayfiles = dir('2016*');

for ii = 1:length(dayfiles)

	cd(dayfiles(ii).name)

		for jj = 1:length(geno)

				gtype_exp = dir(geno(jj).strterm);
				for kk = 1:length(gtype_exp)

						geno(jj).exps(geno(jj).p).expdir = [datadir '/' dayfiles(ii).name ...
						'/' gtype_exp(kk).name];

						geno(jj).p = geno(jj).p+1;

				end



		end

	cd('..')

end


%% Collect summary data from each experiment
for ii = 1:length(geno)
    
    geno(ii).summary_data = nan(length(geno(ii).exps), 6);
    
end

for ii = 1:length(geno)
    
    for jj = 1:length(geno(ii).exps)
        cd(geno(ii).exps(jj).expdir)
        
        load('summary_data.mat')
        for kk = 1:length(summary.pi_mean)
           
            geno(ii).summary_data(jj,kk) = summary.pi_mean(kk);
            
        end
          
    end
    
    geno(ii).summary_mean = mean(geno(ii).summary_data);
    geno(ii).summary_SEM = std(geno(ii).summary_data)./sqrt(size(geno(ii).summary_data,1));
   
end

%% Now plot. Make 2 versions of the plot
% 1) each individual experiment represented as a scatter plot (offset) and 
% jittered, behind confplots
% confplots only
% 2) Conplot

close all

f1 = figure('Units', 'Inches', 'Position', [0.4583    4.9583   12.8750    8.2778],...
    'Color', 'w', 'visible', 'on');

pos = get(f1, 'Position');
set(f1,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);

xvals = [1 2 3 4 5 6];
xlabels = {'off', '6.2', '12.4', '18.4', '24.4', '30.1'};

plot([0 0], [-100 100], 'k')
hold on
confplot(xvals-.1, geno(1).summary_mean, geno(1).summary_SEM, geno(1).summary_SEM, [0 0 0]);
confplot(xvals, geno(2).summary_mean, geno(2).summary_SEM, geno(2).summary_SEM, [0 0 1]);
confplot(xvals+.1, geno(3).summary_mean, geno(3).summary_SEM, geno(3).summary_SEM, [1 0 0]);
xlim([.5 6.5])
ylim([-.3 .9])

plot([-100 1000], [0 0], 'k')

box off

set(gca, 'YTick', [-.3 0 .3 .6 .9], 'XTickLabel', {'Off', '6', '12', '18',  '24', '30'},...
    'Fontsize', 25);

ylabel('pref idx (-1:1)', 'Fontsize', 30)
xlabel('\newlinered (630 nm) intensity\newline      (uW/mm^2)')

text(.55, .85, ['HC-gal4 x UAS-Chr (n = ' num2str(size(geno(3).summary_data, 1)) ')'],...
    'Fontsize', 20, 'color', 'r');
text(.55, .77, ['GR28.b-gal4 x UAS-Chr (n = ' num2str(size(geno(2).summary_data, 1)) ')'],...
    'Fontsize', 20, 'color', 'b');
text(.55, .69, ['Empty-gal4 x UAS-Chr (n = ' num2str(size(geno(1).summary_data, 1)) ')'],...
    'Fontsize', 20, 'color', 'k');



cd('/Users/florencet/Documents/matlab_root/chrap-project')


print(f1, ['genotype_summary.pdf'], '-dpdf', '-r0', '-opengl');







