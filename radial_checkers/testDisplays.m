Screen('Preference', 'SkipSyncTests', 1);
% Clear the workspace and the screen
sca;
close all;
clearvars;
% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);


screens=Screen('Screens');
disp(screens);

% for i = 1:length(screens)
screenNumber = screens(1);
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
disp(screenNumber);
[windowPtr, windowRect] = Screen('OpenWindow', screenNumber,0, [0 0 1000 1000]);

[centerX, centerY] = RectCenter(windowRect);

Screen('FillRect', windowPtr, [0.5 0.5 0.5]);
Screen('TextSize',windowPtr,120);
textMessage = 'Please wait for the experiment to start ...';
textRect = Screen(windowPtr, 'TextBounds', textMessage);
textWidth = textRect(3) - textRect(1);
textHeight = textRect(4) - textRect(2);

Screen('DrawText', windowPtr, textMessage,...
    centerX-(textWidth/2), centerY-(textHeight/2), white, [0.5 0.5 0.5]);

Screen('Flip', windowPtr); 

KbStrokeWait;

% Clear the screen
sca; 