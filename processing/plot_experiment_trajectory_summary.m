function plot_experiment_trajectory_summary(expdir)

homedir = pwd;

cd(expdir)
mkdir('plots')
cd('plots')

close all;

f1 = figure('Position', [64 78 1292 865], 'Color', 'w', 'visible', 'off');
set(f1, 'units', 'inches')
pos = get(f1, 'Position');
set(f1,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);

cmap = pmkmp(100);
tail_l = 75;

tfiles = dir('trial*');

for jj = 1:length(tfiles)
   
    s1 = subplot(3,5,jj);
    
    load(tfiles(jj).name)
    
    env_data = trial.settings.env_map;
    
    if jj < 11
        imagesc(env_data);
        colormap(gray);
        
        hold on
        
        [cX,cY] = circle([592 600],590,1000);
        l1 = plot(cX, cY, 'color', 'k', 'linewidth', 5)
        axis equal off
        
        freezeColors();


    else

        [cX,cY] = circle([592 600],590,1000);
        l1 = plot(cX, cY, 'color', 'k', 'linewidth', 5)
        set(gca, 'YDir', 'reverse')
        
        hold on
        
        axis equal off
        
        split_1 = strsplit(trial.name, 'quad');
        split_2 = strsplit(split_1{2}, 'd');
    
        target_Q = str2num(split_2{2});
  
        if target_Q == 1
        
            plot([240 560], [240 240], 'r:', 'linewidth', 2)
            plot([240 240], [240 560], 'r:', 'linewidth', 2)
            plot([560 560], [240 560], 'r:', 'linewidth', 2)
            plot([240 560], [560 560], 'r:', 'linewidth', 2)


        elseif target_Q == 2
        
            plot([240 560]+360, [240 240], 'r:', 'linewidth', 2)
            plot([240 240]+360, [240 560], 'r:', 'linewidth', 2)
            plot([560 560]+360, [240 560], 'r:', 'linewidth', 2)
            plot([240 560]+360, [560 560], 'r:', 'linewidth', 2) 
            
        elseif target_Q == 3
        
            plot([240 560]+360, [240 240]+360, 'r:', 'linewidth', 2)
            plot([240 240]+360, [240 560]+360, 'r:', 'linewidth', 2)
            plot([560 560]+360, [240 560]+360, 'r:', 'linewidth', 2)
            plot([240 560]+360, [560 560]+360, 'r:', 'linewidth', 2) 
        
        elseif target_Q == 4
        
            plot([240 560], [240 240]+360, 'r:', 'linewidth', 2)
            plot([240 240], [240 560]+360, 'r:', 'linewidth', 2)
            plot([560 560], [240 560]+360, 'r:', 'linewidth', 2)
            plot([240 560], [560 560]+360, 'r:', 'linewidth', 2) 
        
        end
        
    end


    hold on

    
    cHz = floor(trial.data.p/trial.data.tstamp(trial.data.p));
    
    flyX = medfilt1(trial.data.xy_filt(:,1), 5);
    flyY = medfilt1(trial.data.xy_filt(:,2), 5);
    
    flyX = flyX(1:cHz:trial.data.p);
    flyY = flyY(1:cHz:trial.data.p);
    
    th = trial.data.theta(1:cHz:trial.data.p);
    
    for ii = 1:length(flyX)
       
        tail_x =  tail_l*cosd(th(ii));
        tail_y = tail_l*sind(th(ii));
        
        k1 = scatter(flyX(ii), flyY(ii), 100);
        set(k1, 'MarkerEdgeColor', 'none', 'MarkerFaceColor', cmap(ii,:));
        
        plot([flyX(ii) flyX(ii)-tail_x], [flyY(ii) flyY(ii)-tail_y],...
            'LineWidth', 3.5, 'color', cmap(ii,:))
        
        
    end
    
    if jj == 1
        title('trials 1-5:', 'fontsize', 27)
    elseif jj == 6
        title('trials 6-10:', 'fontsize', 27)
    elseif jj == 11
        title('probe:', 'fontsize', 27)
    end
    
    
end

t1 = subplot(3,5,12);
cbar_mat = nan(90,15);
for ii = 1:90
    cbar_mat(ii,:) = ii;
end

imagesc((cbar_mat))
colormap(cmap)

axis equal tight 
box off

set(gca, 'YTick', [1 30 60 90], 'YTickLabel',{'0      ', '30      ', '60      ', '90      '},  'yaxislocation','right',...
    'XTick', [], 'Fontsize', 25)
ylabel('time (sec) \newline \newline', 'fontsize', 30, 'rotation', 270)

print(f1, ['trajectory_summary.pdf'], '-dpdf', '-r0', '-opengl');

cd(homedir)


end