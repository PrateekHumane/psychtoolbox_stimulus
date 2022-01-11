function scan = fMRIPresentStim(comment, paradigmNumber, stimOrder, writeMovie)

Screen('Preference', 'SkipSyncTests', 1);


%% Save input parameters
scan.comment = comment;
scan.paradigmNumber = paradigmNumber;

%% Defualt File specifc Parameters

% Default Frame Parameters:
frameLineWidth = 0.5; % in degrees
frameBlankWidth = 0.1; % in degrees

%% File specifc Parameters

%load in params
presentStimParams

%load in frame params


%% List of conditions
conditionNone	= 0;
conditionStim	= 1;
conditionEnd	= 2;

%% Chosse current paradigm and save it
switch paradigmNumber
    case 0
        paradigm = testParadigm;
    case 1
        paradigm = runParadigmTest;
    case 2
        paradigm = runParadigmFinal;
end
                
stim = generateStimulus(paradigmNumber);
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
        PsychImaging('OpenWindow', screenNumber, 0, [0 0 1920 1080]);
    %windowRect = [0 0 1920 1080];
    %Enable alpha blending with proper blend-function.
    %We need it for drawing of smoothed points:
    Screen('BlendFunction', windowPtr,...
        GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    %% Psychtoolbox setup code comes here
    HideCursor;
    %Let matlab command window ignore incoming keypresses
    KbName('UnifyKeyNames');
    
    psychtoolbox_forp_id=-1;
    
    if paradigmNumber ~= 0
        % List of vendor IDs for valid FORP devices:
        % vendorIDs = [1240 6171];
        
        Devices = PsychHID('Devices');
        % Loop through all KEYBOARD devices with the vendorID of FORP's vendor:
        disp(Devices);
        for i=1:size(Devices,2)
            psychtoolbox_forp_id=i;
            break;
        end
        
        if psychtoolbox_forp_id==-1
            error('No FORP-Device detected on your system');
        end
        psychtoolbox_forp_id=0;
    end
    
    keysOfInterest=zeros(1,256);
	keysOfInterest(KbName('t'))=1;
    keysOfInterest(KbName('5%'))=1;
	
    % only look for t as trigger
    % disp(psychtoolbox_forp_id);
	KbQueueCreate(psychtoolbox_forp_id, keysOfInterest);	
	KbQueueStart;
    
    [keyPress, keyTime, keyID] = KbCheck(-1);
    oldKeyID = keyID;

    %Set Timestamp counter [actualtime Condition; ...]
    vbl = [];

    %% Calculate screen and pixel dimensions
    x0      = windowRect(1);
    y0      = windowRect(2);
    xEnd    = windowRect(3);
    yEnd    = windowRect(4);
    screenWidth = (xEnd-x0);
    screenHeight= (yEnd-y0);
    [centerX, centerY] = RectCenter(windowRect);

    scan.windowRect = windowRect;
	
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
    scan.ifi = ifi;

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
    %stim(1) = OutwardStimulus('/home/prateek/McGill/BIC/psychtoolbox_stimulus/radial_checkers/fMRIFinal/GratingStimulus1.m',diameter,screenProperties);
    %stim(2) = PulseStimulus('/home/prateek/McGill/BIC/psychtoolbox_stimulus/radial_checkers/fMRIFinal/GratingStimulus1.m',1, diameter,screenProperties);

    Screen('TextSize',windowPtr,100);
    textMessage = 'Loading stimulus';
    textRect = Screen(windowPtr, 'TextBounds', textMessage);
    textWidth = textRect(3) - textRect(1);
    textHeight = textRect(4) - textRect(2);
    Screen('DrawText', windowPtr, textMessage,...
    centerX-(textWidth/2), centerY-(textHeight/2), white, black);

    Screen('Flip', windowPtr);
    
    if writeMovie
        movieProperties.windowPtr = windowPtr;
        movieProperties.width = screenWidth;
        movieProperties.height = screenHeight;
        movieProperties.frameRate = fps;
    end
    
    % create the textures now that we have the diameter, screenprops,
    % and have shown the loading screen
    for s = 1:length(stim)
        stim{s}.createTextures(diameter,screenProperties)
        % if video path is specified save the video
        if writeMovie
            movieProperties.movieFile = strcat('Videos/',int2str(s),'.avi');
            stim{s}.createMovie(movieProperties);
        end
    end
    
    gratingRect = CenterRectOnPointd([0 0 diameter(1) diameter(2)],centerX,centerY);

    frameRect = []
    for i=1:3
        padding = frameLineWidthPix*2*i+frameBlankWidthPix*2*(i-1);
        frameRect = [frameRect transpose(CenterRectOnPointd([0 0 diameter(1)+padding diameter(2)+padding],centerX,centerY))];
    end
    framePoly = [
        centerX-fixRadius centerY-fixRadius;
        centerX-fixRadius centerY-radius(2);
        centerX+fixRadius centerY-radius(2);
        centerX+fixRadius centerY-fixRadius;
        centerX+radius(1) centerY-fixRadius;
        centerX+radius(1) centerY+fixRadius;
        centerX+fixRadius centerY+fixRadius;
        centerX+fixRadius centerY+radius(2);
        centerX-fixRadius centerY+radius(2);
        centerX-fixRadius centerY+fixRadius;
        centerX-radius(1) centerY+fixRadius;
        centerX-radius(1) centerY-fixRadius;
    ];
    fixBackRect=CenterRectOnPointd([0 0 fixRadius*2*3 fixRadius*2*3],centerX,centerY);
    fixRect=CenterRectOnPointd([0 0 fixRadius*2 fixRadius*2],centerX,centerY);

    %% Experiment starts
    Priority(MaxPriority(windowPtr));

    %% Wait Screen
    Screen('FillRect', windowPtr, [0.5 0.5 0.5]);
    Screen('TextSize',windowPtr,100);
    textMessage = 'The experiment will start shortly';
    textRect = Screen(windowPtr, 'TextBounds', textMessage);
    textWidth = textRect(3) - textRect(1);
    textHeight = textRect(4) - textRect(2);

    Screen('DrawText', windowPtr, textMessage,...
        centerX-(textWidth/2), centerY-(textHeight/2), white, gray);

    Screen('Flip', windowPtr);
    Screen('BlendFunction', windowPtr, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
	
	scan.runs = {};

	for run = 1:runs
	
	    %% Prepare first conditionamplitude
	    state = conditionNone;
	    laststate = conditionNone;
	    trigger = true;
	
	    Screen('FillRect', windowPtr, gray);
	
		fixRect=CenterRectOnPointd([0 0 fixRadius*2 fixRadius*2],centerX,centerY)
	    Screen('FillOval', windowPtr, fixColor, fixRect);
	    currentConditionStartTime = 0;
	    currentStimulus = 0;
	
	    %% Wait for trigger
	    scan.runs{run}.triggerTimes = KbQueueWait;
	    
	    %% MAIN LOOP
	    while state~=conditionEnd
	        %% Flip screen and estimate time of next screen;
	        vbl         = [vbl ; [Screen('Flip', windowPtr) , state, trigger]];
	        t           = (vbl(end,1)-vbl(1,1));
	        nextT       = (vbl(end,1)-vbl(1,1))+ifi;
	        framecount  = floor((vbl(end,1) - vbl(1,1))/ifi) + 1;
	        scan.runs{run}.vbl = vbl;
	
	        timeProperties.t = t;
	        timeProperties.framecount = framecount;
	        
	        %% Drawing commands
	        switch state
	            case conditionStim
	                stimulusTexture = stim{stimRunIndices(run,mod(currentStimulus,length(stim))+1,stimOrder)}.getNextTexture(timeProperties);
	                Screen('DrawTexture', windowPtr, stimulusTexture, [],gratingRect, 0,0);
	                %Screen('FrameOval', windowPtr, [0  0 0],frameRect,frameLineWidthPix);
	                Screen('FramePoly', windowPtr, [0 0 0],framePoly);
	
	            case conditionNone
	        end
	
	        Screen('FillOval',  windowPtr, [1 0 0], fixRect);
	
	        Screen('DrawingFinished', windowPtr);
	
	        %% Process key Input
	        % Check for trigger
	        [ pressed, firstPress]=KbQueueCheck;	% Collect keyboard events since KbQueueStart was invoked
	        if pressed && (firstPress(KbName('t')) || firstPress(KbName('5%')))
	            scan.runs{run}.triggerTimes = [scan.runs{run}.triggerTimes firstPress(KbName('t'))||firstPress(KbName('5%'))];
	            trigger = true;
	        else
	            trigger = false;
	        end
	        
	        
	        [keyPress, keyTime, keyID] = KbCheck(-1);
	
	        if any(keyID-oldKeyID)
	            keyPressID = keyID;
	            oldKeyID = keyID;
	        else
	            keyPressID = zeros(size(keyID));
	        end
	
	        %% Update state
	        laststate = state;
	
	        state = paradigm(min(find(paradigm(:,1) > length(scan.runs{run}.triggerTimes)))-1,2);
	        if isempty(state) || keyPressID(KbName('Escape'))
	            state = conditionEnd;
	        end
	        if laststate == conditionStim && state ~= conditionStim
	            currentStimulus = currentStimulus+1;
	        end
	
	        %% Initialize new state
	        if state~=laststate
	            currentConditionStartTime = nextT;
	        end
	    end

	    Screen('FillRect', windowPtr, gray);
		Screen('Flip', windowPtr);
	
	end
    %% Clean up
    Priority(0);
    %Screen('LoadNormalizedGammaTable', windowPtr, oldgammatable);
    Screen('CloseAll');
    ShowCursor;
    filename = mfilename('fullpath');
    fid = fopen([filename '.m']);
    lineNumber = 0;
    while true
        lineNumber = lineNumber + 1;
        tLine = fgetl(fid);
        if ~ischar(tLine)
            break;
        else
            scan.program{lineNumber} = tLine;
        end
    end
    fclose(fid);
    save([resultdir '/' comment], 'scan');
catch
    %catch errors
    Priority(0);
    %Screen('LoadNormalizedGammaTable', windowPtr, oldgammatable);
    Screen('CloseAll');
    ShowCursor;
    filename = mfilename('fullpath');
    fid = fopen([filename '.m']);
    lineNumber = 0;
    while true
        lineNumber = lineNumber + 1;
        tLine = fgetl(fid);
        if ~ischar(tLine)
            break;
        else
            scan.program{lineNumber} = tLine;
        end
    end
    fclose(fid);
    save([resultdir '/' comment], 'scan');
    err = lasterror;
    disp(err.stack);
    rethrow(lasterror);
end
