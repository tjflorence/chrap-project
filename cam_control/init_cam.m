function [vi, cam_params] = init_cam()

%{ 
 Initializes camera object
 
 General camera notes:
 I. ROI and Framerate
    - to get square frame, set ROIPosition to [368 0 1184 1200])
    - this gets frame rate above 100 fps
    - unfortunately, ROI for this camera can only be set in increments
        of 16
 II. The following source values have to set to 'Manual', or the camera
        will continuously adjust them. We don't want this for bg-subtract
        tracking
    ExposureMode
    FrameRatePercentageMode
    GainMode
    GammaMode
    ShutterMode
%}

vi = videoinput('pointgrey', 1);
set(vi, ...
    'ROIPosition', [368 0 1184 1200], ...
    'FramesPerTrigger', Inf);

src = getselectedsource(vi);
set(src, ...
    'ExposureMode', 'Manual', ...
    'FrameRatePercentageMode', 'Manual', ...
    'GainMode', 'Manual', ...
    'GammaMode', 'Manual',...
    'ShutterMode', 'Manual');

cam_params.xy = [1184 1200];
cam_params.max_Hz = 100;

end