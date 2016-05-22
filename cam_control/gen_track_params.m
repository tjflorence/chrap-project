function track_params = gen_track_params(vi, num_frames, thresh, daqObj)

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

% grab single frame to get frame dimension
start(vi); 
pause(.01);
test_frame = getsnapshot(vi); 
stop(vi);
flushdata(vi);

frame_dims = size(test_frame);

% save space for frames in memory
frame_mat = nan(frame_dims(1), frame_dims(2), num_frames);

% acquire backgroung frames
start(vi);
disp('generating bg image')
disp(['expected_wait: ' num2str(num_frames/40, '%.4g') ' seconds'])
pause(.005)

daqObj.outputSingleScan([0 -4.5]);
for ii = 1:num_frames
    
    frame_mat(:,:,ii) = getsnapshot(vi);
    pause(.005)

end
daqObj.outputSingleScan([0 -4.99]);

stop(vi);
flushdata(vi);
disp('completed')

bg_frame = mean(frame_mat, 3); % average background frame
std_frame = std(frame_mat, [], 3); % std dev frame

track_params.bg = double(bg_frame);
track_params.max_std = max(max(std_frame));
track_params.frame_dim = size(bg_frame);
track_params.thresh_factor = thresh;
track_params.thresh_val = track_params.max_std*track_params.thresh_factor;

end