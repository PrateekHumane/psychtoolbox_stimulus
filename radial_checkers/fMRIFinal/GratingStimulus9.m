% Stimulus parameters

% stimulus 1:
% red and green
% high spatial frequency
% fast 

stimParams.mean= 1; %black and white
stimParams.amplitude = 0.5; % contrast

%stimParams.spatialF = 2; %cycles per d
syms x;
symSpatialFreqFun = int((8-0.16*x),[0,x]);
stimParams.spatialFreqFun = matlabFunction(symSpatialFreqFun);

stimParams.gratingSpeed = 16; %deg per s

% # cycles so that spatialF is same at 5 deg radially and circularly
stimParams.cyclesPerRotation = round(stimParams.spatialFreqFun(5)*2*pi*5); % cycles/deg * (2*PI*R) deg where R=5 degrees

% grating colors
colorBlackAndWhite = 0;
colorBlueAndYellow = 1;
colorRedAndGreen   = 2;

stimParams.gratingColor = colorRedAndGreen;