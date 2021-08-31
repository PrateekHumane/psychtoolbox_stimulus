% Clear the workspace and the screen
sca; 
close all;
clearvars;

Screen('Preference', 'SkipSyncTests', 1);

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Get the screen numbers
screens = Screen('Screens');

% Draw to the external screen if avaliable
screenNumber = max(screens);

%% General Parameters
%Resultfile directory
resultdir = './Results';
%Stimulus parameters
fixRadius= 0.25;%fixation dot radius in degrees 
fovWidth        = 30;
fovHeight       = 22.5;

% Define black and white
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white / 2;
inc = white - grey;

%% File specifc Parameters

mean = 0.5; % mean color
amplitude = 0.5;

%load in stimulus
GratingStimulus1

frameRate = 60;
timeStim = 0.4;
timeNone = 0.4;

frameLineWidth = 0.5; % in degrees
frameBlankWidth = 0.1; % in degrees

% Open an on screen window
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey);

% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');


x0      = windowRect(1);
y0      = windowRect(2);
xEnd    = windowRect(3);
yEnd    = windowRect(4);
screenWidth = (xEnd-x0);
screenHeight= (yEnd-y0);
[centerX, centerY] = RectCenter(windowRect);

widthDegPerPixel = (fovWidth/2)/(screenWidth/2-0.5);
heightDegPerPixel= (fovHeight/2)/(screenHeight/2-0.5);
degPerPix = heightDegPerPixel;
pixPerDeg = 1/degPerPix;

stimRadius = min([screenWidth screenHeight]);

screenProperties.ifi = ifi;
screenProperties.degPerPix = degPerPix;
screenProperties.window = window;

%% General setup code goes here (e.g. stimulus rendering)
disp('0');

frameLineWidthPix = round(pixPerDeg * frameLineWidth);
frameBlankWidthPix = round(pixPerDeg * frameBlankWidth);
fixRadius = round(pixPerDeg * fixRadius);
frameHeight = (frameLineWidthPix + frameBlankWidthPix) * 3;

diameter = stimRadius - frameHeight*2;
radius = diameter/2;
[X,Y] = meshgrid(-(diameter-1)/2:1:(diameter-1)/2);
R = sqrt(X.^2+Y.^2);
T = atan2(-Y,X);

% Calculation for deg/second -> frames/cycle
% deg/second * cycles/deg * seconds/frame = cycles/frame
% 1/cycles/frame = frames/cycle

% number frames for one cycle
numFrames=round(1/(gratingSpeed*spatialF*ifi)); % temporal period, in frames, of the drifting grating
gratingRect = CenterRectOnPointd([0 0 diameter diameter],centerX,centerY);
disp('1');

fps=Screen('FrameRate',window);
frameCount = 0;
disp(fps);

%while frameCount < fps*(timeStim+timeNone)
%	if frameCount < fps*timeStim
%		Screen('DrawTexture', window, gratingTexture, [],gratingRect, 0,0);
%	end	
%	% Screen('DrawingFinished', windowPtr);
%	Screen('AddFrameToMovie', window);
%	Screen('Flip', window);
%	frameCount = frameCount + 1;
%end
try
    stim1 = OutwardStimulus('/home/prateek/McGill/BIC/psychtoolbox_stimulus/radial_checkers/fMRIFinal/GratingStimulus1.m',diameter,screenProperties);
catch
    disp('error');
end
  
frameRect = []
for i=1:3
	padding = frameLineWidthPix*2*i+frameBlankWidthPix*2*(i-1);
	frameRect = [frameRect transpose(CenterRectOnPointd([0 0 diameter+padding diameter+padding],centerX,centerY))];
end
framePoly = [
	centerX-fixRadius centerY-fixRadius;
	centerX-fixRadius centerY-radius;
	centerX+fixRadius centerY-radius;
	centerX+fixRadius centerY-fixRadius;
	centerX+radius centerY-fixRadius;
	centerX+radius centerY+fixRadius;
	centerX+fixRadius centerY+fixRadius;
	centerX+fixRadius centerY+radius;
	centerX-fixRadius centerY+radius;
	centerX-fixRadius centerY+fixRadius;
	centerX-radius centerY+fixRadius;
	centerX-radius centerY-fixRadius;
];
fixBackRect=CenterRectOnPointd([0 0 fixRadius*2*3 fixRadius*2*3],centerX,centerY);
fixRect=CenterRectOnPointd([0 0 fixRadius*2 fixRadius*2],centerX,centerY);

vbl = [];
framecount = 1;
% % Animation loop:
movieDurationSecs=5;
movieDurationFrames=round(movieDurationSecs * frameRate);
movieFrameIndices=mod(0:(movieDurationFrames-1), numFrames) + 1;
 
% Screen('DrawTexture', window, tex(1) , [],gratingRect, 0,0);
% 
% Screen('FrameOval', window, [0 0 0],frameRect,frameLineWidthPix);
% Screen('FramePoly', window, [0 0 0],framePoly);
% % Screen('FillOval', window, [0 0 0], fixBackRect);
% Screen('FillOval',  window, [1 0 0], fixRect);
% Screen('Flip', window);
disp(stim1); 
while framecount < movieDurationFrames
    %disp(movieFrameIndices(framecount)); 

    Screen('DrawTexture', window, stim1.tex(movieFrameIndices(framecount)), [],gratingRect, 0,0);

    Screen('FrameOval', window, [0  0 0],frameRect,frameLineWidthPix);
    Screen('FramePoly', window, [0 0 0],framePoly);
    % Screen('FillOval', window, [0 0 0], fixBackRect);
    Screen('FillOval',  window, [1 0 0], fixRect);
    vbl = [vbl; Screen('Flip', window)];
    framecount  = floor((vbl(end,1) - vbl(1,1))/ifi) + 1;
end 



disp('2');

% Flip to the screen
 Screen('Flip', window);
disp('3');

% Wait for a key press
KbStrokeWait;
disp('4');
Screen('CloseAll');

% Clear the screen
sca;
