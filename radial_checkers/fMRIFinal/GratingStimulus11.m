% Stimulus parameters

% stimulus 11:
% red and green
% low spatial frequency
% fast 

stimParams.mean= 0.5; %black and white
stimParams.amplitude = 1; % contrast

%stimParams.spatialF = 2; %cycles per d
syms x;
symSpatialFreqFun = int((2-0.04*x),[0,x]);
stimParams.spatialFreqFun = matlabFunction(symSpatialFreqFun);

stimParams.gratingSpeed = 16; %deg per s

% # cycles so that spatialF is same at 5 deg radially and circularly
stimParams.cyclesPerRotation = round(stimParams.spatialFreqFun(5)*2*pi*5); % cycles/deg * (2*PI*R) deg where R=5 degrees

% grating colors
colorBlackAndWhite = 0;
colorBlueAndYellow = 1;
colorRedAndGreen   = 2;

stimParams.gratingColor = colorRedAndGreen;