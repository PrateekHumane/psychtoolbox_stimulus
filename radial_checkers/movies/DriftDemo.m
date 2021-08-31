function DriftDemo
% DriftDemo
% ___________________________________________________________________
%
% Display an animated grating using the new Screen('DrawTexture') command.
% In Psychtoolbox-3 Screen('DrawTexture') replaces
% Screen('CopyWindow').
%
% This is a very simple, bare bones demo on how to do frame animation. For
% much more efficient ways to draw gratings and gabors, have a look at
% DriftDemo2, DriftDemo3, DriftDemo4, ProceduralGaborDemo, GarboriumDemo,
% ProceduralGarboriumDemo and DriftWaitDemo.
%
% CopyWindow vs. DrawTexture:
%
% In the OS 9 Psychtoolbox, Screen ('CopyWindow") was used for all
% time-critical display of images, in particular for display of the movie
% frames in animated stimuli. In contrast, Screen('DrawTexture') should not
% be used for display of all graphic elements, but only for display of
% MATLAB matrices. For all other graphical elements, such as lines, rectangles,
% and ovals we recommend that these be drawn directly to the  display
% window during the animation rather than rendered to offscreen windows
% prior to the animation.
% _________________________________________________________________________
%
% see also: PsychDemos, MovieDemo

% HISTORY
%  6/28/04    awi     Adapted from Denis Pelli's DriftDemo.m for OS 9
%  7/18/04    awi     Added Priority call.  Fixed.
%  9/8/04     awi     Added Try/Catch, cosmetic changes to comments and see also.
%  4/23/05    mk      Added Priority(0) in catch section, moved Screen('OpenWindow')
%                     before first call to Screen('MakeTexture') in
%                     preparation of future improvements to 'MakeTexture'.
%  2/28/09    mk      Smallish refinements, cleanups, updated comments.
Screen('Preference', 'SkipSyncTests', 1);


%% General Parameters
%Stimulus parameters
fixRadius= 0.25;%fixation dot radius in degrees

fovWidth        = 30;
fovHeight       = 22.5;

%% File specifc Parameters

mean = 0.5; % mean color
amplitude = 0.5; 

%load in stimulus
GratingStimulus1

frameLineWidth = 0.5; % in degrees
frameBlankWidth = 0.1; % in degrees



try
    % This script calls Psychtoolbox commands available only in OpenGL-based
    % versions of the Psychtoolbox. (So far, the OS X Psychtoolbox is the
    % only OpenGL-base Psychtoolbox.)  The Psychtoolbox command AssertPsychOpenGL will issue
    % an error message if someone tries to execute this script on a computer without
    % an OpenGL Psychtoolbox.
    AssertOpenGL;

    % Get the list of screens and choose the one with the highest screen number.
    % Screen 0 is, by definition, the display with the menu bar. Often when
    % two monitors are connected the one without the menu bar is used as
    % the stimulus display.  Chosing the display with the highest dislay number is
    % a best guess about where you want the stimulus displayed.
    screens=Screen('Screens');
    screenNumber=max(screens);

      % Find the color values which correspond to white and black: Usually
    % black is always 0 and white 255, but this rule is not true if one of
    % the high precision framebuffer modes is enabled via the
    % PsychImaging() commmand, so we query the true values via the
    % functions WhiteIndex and BlackIndex:
    white=WhiteIndex(screenNumber);
    black=BlackIndex(screenNumber);

    % Round gray to integral number, to avoid roundoff artifacts with some
    % graphics cards:
    gray=round((white+black)/2);

    % This makes sure that on floating point framebuffers we still get a
    % well defined gray. It isn't strictly neccessary in this demo:
    if gray == white
        gray=white / 2;
    end

    % Contrast 'inc'rement range for given white and gray values:
    inc=white-gray;

    % Open a double buffered fullscreen window and select a gray background
    % color:
    [w,windowRect]=Screen('OpenWindow',screenNumber, gray);
    
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

    frameLineWidthPix = round(pixPerDeg * frameLineWidth);
    frameBlankWidthPix = round(pixPerDeg * frameBlankWidth);
    fixRadius = round(pixPerDeg * fixRadius);
    frameHeight = (frameLineWidthPix + frameBlankWidthPix) * 3;

    diameter = stimRadius - frameHeight*2;
    radius = diameter/2;
    phase = 0;
    cyclePerPixel = spatialF*degPerPix; %spatialF in cyclesPerDeg
    [X,Y] = meshgrid(-(diameter-1)/2:1:(diameter-1)/2);
    R = sqrt(X.^2+Y.^2);
    T = atan2(-Y,X);

    numFrames=12; % temporal period, in frames, of the drifting grating
    for i=1:numFrames
        phase=(i/numFrames)*2*pi;
        grating = zeros([size(R), 2]);
        %grating(:,:,1) =  mean * ones(diameter) + amplitude*sin(2*pi* cyclePerPixel * R ...
        %	- phase*ones(diameter) ) + 0.25*sin(2*pi*8/(2*pi)*T );
        grating(:,:,1) =   mean * ones(diameter) + amplitude*sin(2*pi* cyclePerPixel * R) .* sin(2*pi*8/(2*pi)*T );

        %grating(:,:,1) =  mean * ones(diameter) + 0.25*sin(2*pi*8/(2*pi)*T );

        grating(:,:,2) = (R <= diameter/2); % alpha mask
        tex(i) = Screen('MakeTexture', w, grating);
    end
    gratingRect = CenterRectOnPointd([0 0 diameter diameter],centerX,centerY);

    % Run the movie animation for a fixed period.
    movieDurationSecs=5;
    frameRate=Screen('FrameRate',screenNumber);

    % If MacOSX does not know the frame rate the 'FrameRate' will return 0.
    % That usually means we run on a flat panel with 60 Hz fixed refresh
    % rate:
    if frameRate == 0
        frameRate=60;
    end

    fps=Screen('FrameRate',w)
    ifi=Screen('GetFlipInterval', w)
    % Convert movieDuration in seconds to duration in frames to draw:
    movieDurationFrames=round(movieDurationSecs * frameRate);
    movieFrameIndices=mod(0:(movieDurationFrames-1), numFrames) + 1;

    disp(frameRate);
    disp(movieDurationFrames);
    % Use realtime priority for better timing precision:
    priorityLevel=MaxPriority(w);
    Priority(priorityLevel);
    vbl = [];
    framecount = 1;
    % Animation loop:
    while framecount < movieDurationFrames
        % Draw image:
        % disp(mod(framecount,numFrames));
        Screen('DrawTexture', w, tex(movieFrameIndices(mod(framecount,numFrames)+1)), [],gratingRect, 0,0);
        % Show it at next display vertical retrace. Please check DriftDemo2
        % and later, as well as DriftWaitDemo for much better approaches to
        % guarantee a robust and constant animation display timing! This is
        % very basic and not best practice!
        vbl = [vbl; Screen('Flip', w)];
        framecount  = floor((vbl(end,1) - vbl(1,1))/ifi) + 1;
    end
    disp(size(vbl));
    disp(framecount);
    Priority(0);

    % Close all textures. This is not strictly needed, as
    % Screen('CloseAll') would do it anyway. However, it avoids warnings by
    % Psychtoolbox about unclosed textures. The warnings trigger if more
    % than 10 textures are open at invocation of Screen('CloseAll') and we
    % have 12 textues here:
    Screen('Close');

    % Close window:
    sca;

catch
    %this "catch" section executes in case of an error in the "try" section
    %above.  Importantly, it closes the onscreen window if its open.
    sca;
    Priority(0);
    psychrethrow(psychlasterror);
end %try..catch..