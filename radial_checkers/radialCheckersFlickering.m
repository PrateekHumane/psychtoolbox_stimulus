% Clear the workspace and the screen
sca;
close all;
clearvars;

Screen('Preference', 'SkipSyncTests', 1);

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Get the screen numbers
screens = Screen('Screens');
1
% Draw to the external screen if avaliable
screenNumber = max(screens);

%% General Parameters
%Resultfile directory
resultdir = './Results';
%Stimulus parameters  


fixSize = 10;%fixation dot radius in pixels
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
stimulus1

frameRate = 60;
timeStim = 0.4;
timeNone = 0.4;

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


%% General setup code goes here (e.g. stimulus rendering)
disp('0');
radius = min([screenWidth screenHeight]);
phase = 0;
cyclePerPixel = spatialF*degPerPix; %spatialF in cyclesPerDeg
[X,Y] = meshgrid(-(radius-1)/2:1:(radius-1)/2);
R = sqrt(X.^2+Y.^2);
T = atan2(-Y,X);
grating = zeros([size(R), 2]);
%grating(:,:,1) =  mean * ones(radius) + amplitude*sin(2*pi* cyclePerPixel * R ...
%	- phase*ones(radius) ) + 0.25*sin(2*pi*8/(2*pi)*T );
grating(:,:,1) =   mean * ones(radius) + amplitude*sin(2*pi* cyclePerPixel * R) .* sin(2*pi*8/(2*pi)*T );

%grating(:,:,1) =  mean * ones(radius) + 0.25*sin(2*pi*8/(2*pi)*T );

grating(:,:,2) = (R <= radius/2); % alpha mask
gratingTexture = Screen('MakeTexture', window, grating);
gratingRect = CenterRectOnPointd([0 0 radius radius],centerX,centerY);
disp('1');

fps=Screen('FrameRate',window);
frameCount = 0;
disp(fps);
moviePtr = Screen('CreateMovie', window, 'testmovie.avi',[],[], 1);

%while frameCount < fps*(timeStim+timeNone)
%	if frameCount < fps*timeStim
%		Screen('DrawTexture', window, gratingTexture, [],gratingRect, 0,0);
%	end	
%	% Screen('DrawingFinished', windowPtr);
%	Screen('AddFrameToMovie', window);
%	Screen('Flip', window);
%	frameCount = frameCount + 1;
%end


Screen('Flip', window);
Screen('AddFrameToMovie', window, [], [], [], timeNone*frameRate );

Screen('DrawTexture', window, gratingTexture, [],gratingRect, 0,0);
Screen('Flip', window);
Screen('AddFrameToMovie', window, [], [], [], timeStim*frameRate);


Screen('FinalizeMovie', moviePtr);
disp(frameCount);

disp('2');

% Flip to the screen
% Screen('Flip', window);
disp('3');

% Wait for a key press
KbStrokeWait;
disp('4');

% Clear the screen
sca;
