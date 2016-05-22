function plot_adaptation_check(expdir)

%{

 makes summary plot to examine early-trial vs late-trial responses to light
 exposure at a given intensity

%}

    cd(expdir)
    
    close all
    
    
    f1 = figure('Position', [90 301 908 617], 'Color', 'w', 'visible', 'off');
    set(f1,'Units', 'Inches', 'Position', [1.2361    5.6528   16.8611    7.0833]);
    pos = get(f1, 'Position');
    set(f1,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])

    load('metadata.mat')
    load('summary_data.mat')
    
    light_conditions = {'-5', '-4', '-3', '-2', '-1', '0'};
    xvals = 1:3;
    
    cMap = [141, 211, 199; ...
        255, 255, 179; ...
        190, 186, 218; ...
        251, 128, 114; ...
        128, 177, 211; ...
        253, 180, 98]./255;
    
    
    jitter_vals = .075*randn(length(light_conditions));
    jitter_vals = sort(jitter_vals);
    
 
    s1 = subplot(1,3,1:2);
    
    plot([-100 100], [0 0], 'k', 'linewidth', 2)
    hold on
    
    
    
    for ii = 1:6
       
        jval = jitter_vals(ii);
        plot(xvals+jval, per_trial(ii).mean_by_trial, 'LineWidth', 6, 'Color', 'k')
        p_h{ii} = plot(xvals+jval, per_trial(ii).mean_by_trial, 'LineWidth', 5, 'Color', cMap(ii,:));
        hold on
        
        z1 = scatter(xvals+jval, per_trial(ii).mean_by_trial, 600);
        set(z1, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', cMap(ii,:));
        
    end
    

        
    xlim([.75 3.25])
    ylim([-1 1])
    
    box off

    set(gca, 'XTick', [1 2 3], 'YTick', [-1 -.5 0 .5 1],...
        'XTickLabel', {'rep 1', 'rep 2', 'rep 3'}, 'FontSize', 25)
    
 l_h = legend([p_h{1}, p_h{2}, p_h{3}, p_h{4}, p_h{5}, p_h{6}], 'power = -5', 'power = -4', 'power = -3', 'power = -2', 'power = -1', 'power = 0')
 set(l_h, 'position', [.65 .6 .15 .3], 'fontsize', 20)
 
ylabel('      pref idx\newline(avg both reps)', 'fontsize', 30)


cd(expdir)
mkdir('plots')
cd('plots')

print(f1, ['adaptation_check.pdf'], '-dpdf', '-r0', '-opengl');
cd('..')
close all


end