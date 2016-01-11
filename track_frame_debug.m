start(vi)
pause(1)

tvec = nan(5000,1);

tic
for ii = 1:length(tvec)

c_frame = double(getsnapshot(vi));

diff_frame = abs(track_params.bg-c_frame);
pix_inds = find(diff_frame>track_params.thresh_val);

[yvals, xvals] = ind2sub(track_params.frame_dim, pix_inds);
fly_x = mean(xvals);
fly_y = mean(yvals);

tvec(ii) = toc;
end

dvec = diff(tvec);

stop(vi)
hist(dvec, 100)