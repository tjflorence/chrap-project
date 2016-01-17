close all

load('chrap_2x_on_2_hrs.mat')

f1 = figure('Position', [90 301 908 617], 'Color', 'w', 'visible', 'on');
set(f1,'Units', 'Inches', 'Position', [1.2361    1.9444   16.6528   10.7917]);
pos = get(f1, 'Position');
set(f1,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])

s1 = subplot(1,2,1);
imagesc(chrap_2x_on_2_hrs)
axis equal off
colormap(kjetsmooth)

c1 = colorbar()