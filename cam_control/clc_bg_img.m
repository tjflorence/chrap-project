num_frames = 1000;

start(vi);
pause(.01);
test_frame = peekdata(vi, 1);
stop(vi);
flushdata(vi);

frame_dims = size(test_frame);

frame_mat = nan(frame_dims(1), frame_dims(2), num_frames);

start(vi);
pause(.001)
for ii = 1:num_frames
    
    frame_mat(:,:,ii) = peekdata(vi, 1);

end
stop(vi);
flushdata(vi);

bg_frame = mean(frame_mat, 3);
std_frame = std(frame_mat, [], 3);