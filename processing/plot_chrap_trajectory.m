%function plot_chrap_condition_summary
close all

expdir = '/Volumes/tj/chrap-project/20160111/201601111849_uas-Chr_chrap-curve'

cd(expdir)
load('summary_data.mat')

jj = 6

f1 = figure('Position', [37 2 956 954], 'Color', 'w');

c_power = summary.conditions{jj};
c_files = dir(['*_' c_power '_*']);

c1 = [255 129 0]./255;
c2 = [255 25 64]./255;

row_p = 1;

s1 = subplot(3,3, 1:3);

for ii = 1:length(c_files)

    load(c_files(ii).name)
    
    if mod(ii,2) == 0
        ccolor = c1;
        jit = -.15;
    else
        ccolor = c2;
        jit = +.15;
    end
    
    plot([row_p+jit row_p+jit], [trial.data.pref_idx summary.pi_mean(jj)], 'Color', ccolor, 'linewidth', 1.5)
    
    hold on

    z1 = scatter(row_p+jit, trial.data.pref_idx, 300);
    set(z1, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', ccolor)
    
    plot([-100 100], [0 0], 'k')
    xlim([.5 3.5])
    
    if mod(ii,2) == 0;
        row_p = row_p+1;
    end
    

end

tnum = cell(1,3);
for kk = 2:2:length(c_files)
    
    
    split_name = strsplit(c_files(kk).name, '_');
    trial_num = split_name{3};
    
    tnum{kk/2} = trial_num;
    
    
end

plot([1-.15 3+.15], [summary.pi_mean(jj) summary.pi_mean(jj)], 'linewidth', 5, 'color', 'r')
box off
ylim([-1 1])
set(gca, 'XTick', [1 2 3], 'YTick', [-1 -.5 0 .5 1], 'FontSize', 25, ...
    'XTickLabel', {['rep 1: \newline trial ' tnum{1}], ['rep 2: \newline trial ' tnum{2}], ['rep 3: \newline trial ' tnum{3}]}) 

ylabel('quadrant preference')

s1 = subplot(3,3,4);
load(c_files(5).name)

bg_img = trial.settings.track_params.bg;
max_val = max(max(bg_img));
max_r = 600;

for xx = 1:size(bg_img, 1)
    for yy = 1:size(bg_img, 2)
    
        if sqrt( ((xx- (trial.settings.track_params.frame_dim(2)/2) )^2) ...
                + ((yy- (trial.settings.track_params.frame_dim(1)/2) )^2) ) > max_r
            bg_img(yy,xx) = max_val;
        end
        
    
    end
end

imagesc(bg_img)
axis equal off
colormap gray
hold on

z1 = fill([0 592 592 0], [600 600 0 0], c1);
set(z1, 'FaceAlpha', .5, 'Edgecolor', 'none');

z2 = fill([592 1184 1184 592], [600 600 1200 1200], c1);
set(z2, 'FaceAlpha', .5, 'Edgecolor', 'none');



