function track_params = gen_track_params(vi, num_frames, thresh)

%{
generates tracking parameters for online fly tracking
inputs: 
- vi: videoinput object (camera object)
- num_frames: number of frames to use to generate background image
- thresh: threshold (in standard deviations) to count as something real in
    background (1.5 is good)

returns:
track_params, a structure which includes
- bg: the background image (mean of num_frame frames)
- std_frame: std deviation of num_frame frames
- frame_dim: the expected frame dimension
- thresh: threshold (in standard deviations) to count as something real in
    background
%}

start(vi);
pause(.01);
test_frame = peekdata(vi, 1);
stop(vi);
flushdata(vi);

frame_dims = size(test_frame);

frame_mat = nan(frame_dims(1), frame_dims(2), num_frames);

start(vi);
disp('generating bg image')
disp(['expected_wait: ' num2str(num_frames/100, '%.4g') ' seconds'])
pause(.005)
for ii = 1:num_frames
    
    frame_mat(:,:,ii) = getsnapshot(vi);
    pause(.005)

end
stop(vi);
flushdata(vi);
disp('completed')

bg_frame = mean(frame_mat, 3);
std_frame = std(frame_mat, [], 3);

track_params.bg = double(bg_frame);
track_params.max_std = max(max(std_frame));
track_params.frame_dim = size(bg_frame);
track_params.thresh_factor = thresh;
track_params.thresh_val = track_params.max_std*track_params.thresh_factor;

end