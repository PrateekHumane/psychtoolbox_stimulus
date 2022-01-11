Screen('Preference', 'SkipSyncTests', 1);

%% Open screen
AssertOpenGL;
try
    % Here we call some default settings for setting up Psychtoolbox
    PsychDefaultSetup(2);

    %Define default oldgammatable in case catch block is called too early
    oldgammatable = repmat(linspace(0,1,256)',[1 3]);

    screens=Screen('Screens');
    screenNumber=min(screens);
%     if (screenNumber == 3)
%         screenNumber = [1 2];
%     end
    [windowPtr, windowRect] = ...
        PsychImaging('OpenWindow', screenNumber, 0);
    %windowRect = [0 0 1920 1080];
    %Enable alpha blending with proper blend-function.
    %We need it for drawing of smoothed points:
    Screen('BlendFunction', windowPtr,...
        GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    %% Psychtoolbox setup code comes here
    HideCursor;
    %Let matlab command window ignore incoming keypresses
    KbName('UnifyKeyNames');
    
    %% Calculate screen and pixel dimensions
    x0      = windowRect(1);
    y0      = windowRect(2);
    xEnd    = windowRect(3);
    yEnd    = windowRect(4);
    screenWidth = (xEnd-x0);
    screenHeight= (yEnd-y0);
    [centerX, centerY] = RectCenter(windowRect);
	
	degPerCm = (2*atan(screenDiagonalSize/(2*viewingDistance))*180/pi)/screenDiagonalSize;
    % widthDegPerPixel = (fovWidth/2)/(screenWidth/2-0.5);
    % heightDegPerPixel= (fovHeight/2)/(screenHeight/2-0.5);
    degPerPix = degPerCm * (screenDiagonalSize/sqrt(screenWidth^2+screenHeight^2));    
    pixPerDeg = 1/degPerPix;    

    %% Save old LUT, define new LUT and define some colors
    %absmax, absmin and absmean luminance and derived colors are absolute,
    %independend of contrast
    %all intensities in [relmin,relmax] scale with contrast setting
%     [oldgammatable, dacbits, reallutsize] = ...
%         Screen('ReadNormalizedGammaTable', windowPtr);

    absMinIndex = 0;
    absMaxIndex = 1;
    absMeanIndex= 0.5;
    black   = [absMinIndex      absMinIndex         absMinIndex];
    white   = [absMaxIndex      absMaxIndex         absMaxIndex];
    gray    = [absMeanIndex     absMeanIndex        absMeanIndex];
    red     = [absMaxIndex      absMinIndex         absMinIndex];

    %% Compute interframe interval and frames per second
    Priority(MaxPriority(windowPtr));
    fps=Screen('FrameRate',windowPtr);
    ifi=Screen('GetFlipInterval', windowPtr);
    if fps==0
        fps=1/ifi;
    end
    Priority(0);

    %% General setup code goes here (e.g. stimulus rendering)

	fixRadius = round(pixPerDeg * fixRadius);

    %stimRadius = min([screenWidth screenHeight]);
    stimRadius = [screenWidth screenHeight];

    screenProperties.ifi = ifi;
    screenProperties.degPerPix = degPerPix;
    screenProperties.window = windowPtr;
    
	frameLineWidthPix = round(pixPerDeg * frameLineWidth);
	frameBlankWidthPix = round(pixPerDeg * frameBlankWidth);
	frameHeight = (frameLineWidthPix + frameBlankWidthPix) * 3;

	% no frame
	frameHeight = 0;

	diameter = stimRadius - frameHeight*2;
	radius = diameter/2;

    % create the textures now that we have the diameter, screenprops,
    % and have shown the loading screen
    GratingStimulus1
    stim = CheckerPulseStimulus(stimParams, 2);
    stim.createTextures(diameter,screenProperties);
    
    movieProperties.windowPtr = windowPtr;
    movieProperties.movieFile = 'test.mov';
    movieProperties.width = screenWidth;
    movieProperties.height = screenHeight;
    movieProperties.frameRate = fps;
    
    stim.createMovie(movieProperties);
    
    %% Clean up
    Priority(0);
    %Screen('LoadNormalizedGammaTable', windowPtr, oldgammatable);
    Screen('CloseAll');
    ShowCursor;

catch
    %% Clean up
    Priority(0);
    %Screen('LoadNormalizedGammaTable', windowPtr, oldgammatable);
    Screen('CloseAll');
    ShowCursor;

end