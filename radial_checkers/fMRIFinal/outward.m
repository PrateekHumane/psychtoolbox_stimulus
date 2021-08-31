function scan = fMRIConcentricCircleGratings(comment, paradigmNumber)

Screen('Preference', 'SkipSyncTests', 1);
%% Save input parameters
scan.comment = comment;
scan.paradigmNumber = paradigmNumber;

%% General Parameters
%Resultfile directory
resultdir = './Results';

%Stimulus parameters
fixRadius = 0.25; %fixation dot radius in degrees
fixColor = [1 0 0];

fovWidth        = 30;
fovHeight       = 22.5;

%% Defualt File specifc Parameters

% Defualt Stim Parameters:
mean = 0.5; % mean color
amplitude = 0.5; % contrast
spatialF = 0.5; %cycles per d
gratingSpeed = 1; %deg per s
gratingColor = 0; %black and white

% Default Frame Parameters:
frameLineWidth = 0.5; % in degrees
frameBlankWidth = 0.1; % in degrees


%% File specifc Parameters

%load in stimulus params
GratingStimulus1

%load in frame params


%% List of conditions
conditionNone	= 0;
conditionStim	= 1;
conditionEnd	= 2;

testParadigm = [
    0    conditionNone;
    3    conditionStim;
    20   conditionNone;
    21   conditionEnd;    
    ];

runParadigm = [
    28    conditionNone;
    40    conditionStim;
    52   conditionNone;
    21   conditionEnd;    
    ];

%% Chosse current paradigm and save it
switch paradigmNumber
    case 0
        paradigm = testParadigm;
    case 1
        paradigm = runParadigm;

end
                
%% Open screen
AssertOpenGL;
try
    % Here we call some default settings for setting up Psychtoolbox
    PsychDefaultSetup(2);

    %Define default oldgammatable in case catch block is called too early
    oldgammatable = repmat(linspace(0,1,256)',[1 3]);

    screens=Screen('Screens');
    screenNumber=max(screens);
    [windowPtr, windowRect] = ...
        PsychImaging('OpenWindow', screenNumber, 0);

    %Enable alpha blending with proper blend-function.
    %We need it for drawing of smoothed points:
    Screen('BlendFunction', windowPtr,...
        GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    %% Psychtoolbox setup code comes here
    HideCursor;
    %Let matlab command window ignore incoming keypresses
    ListenChar(2);
    KbName('UnifyKeyNames');
    
    psychtoolbox_forp_id=-1;
    
    if paradigmNumber ~= 0
        % List of vendor IDs for valid FORP devices:
        vendorIDs = [1240 6171];
        
        Devices = PsychHID('Devices');
        % Loop through all KEYBOARD devices with the vendorID of FORP's vendor:
        for i=1:size(Devices,2)
            if (strcmp(Devices(i).usageName,'Keyboard') || ...
                    strcmp(Devices(i).usageName,'Keypad')) && ...
                    ismember(Devices(i).vendorID, vendorIDs)
                psychtoolbox_forp_id=i;
                break;
            end
        end
        
        if psychtoolbox_forp_id==-1
            error('No FORP-Device detected on your system');
        end
    end
    
    keysOfInterest=zeros(1,256);
	keysOfInterest(KbName('t'))=1;
	% only look for t as trigger
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
    widthDegPerPixel = (fovWidth/2)/(screenWidth/2-0.5);
    heightDegPerPixel= (fovHeight/2)/(screenHeight/2-0.5);
    degPerPix = heightDegPerPixel;    
    pixPerDeg = 1/degPerPix;    

    %% Save old LUT, define new LUT and define some colors
    %absmax, absmin and absmean luminance and derived colors are absolute,
    %independend of contrast
    %all intensities in [relmin,relmax] scale with contrast setting
    [oldgammatable, dacbits, reallutsize] = ...
        Screen('ReadNormalizedGammaTable', screenNumber);

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
    stimRadius = min([screenWidth screenHeight]);

    screenProperties.ifi = ifi;
    screenProperties.degPerPix = degPerPix;
    screenProperties.window = windowPtr;
    
	frameLineWidthPix = round(pixPerDeg * frameLineWidth);
	frameBlankWidthPix = round(pixPerDeg * frameBlankWidth);
	fixRadius = round(pixPerDeg * fixRadius);
	frameHeight = (frameLineWidthPix + frameBlankWidthPix) * 3;
    
	diameter = stimRadius - frameHeight*2;
	radius = diameter/2;
	phase = 0;
	cyclePerPixel = spatialF*degPerPix; %spatialF in cyclesPerDeg
    stim1 = OutwardStimulus('/home/prateek/McGill/BIC/psychtoolbox_stimulus/radial_checkers/fMRIFinal/GratingStimulus1.m',diameter,screenProperties);

    gratingRect = CenterRectOnPointd([0 0 diameter diameter],centerX,centerY);

    
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

    %% Experiment starts
    Priority(MaxPriority(windowPtr));

    %% Wait Screen
    Screen('FillRect', windowPtr, [0.5 0.5 0.5]);
    Screen('TextSize',windowPtr,120);
    textMessage = 'Please wait for the experiment to start ...';
    textRect = Screen(windowPtr, 'TextBounds', textMessage);
    textWidth = textRect(3) - textRect(1);
    textHeight = textRect(4) - textRect(2);

    Screen('DrawText', windowPtr, textMessage,...
        centerX-(textWidth/2), centerY-(textHeight/2), white, gray);

    Screen('Flip', windowPtr);
    Screen('BlendFunction', windowPtr, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

    %% Prepare first conditionamplitude
    state = conditionNone;
    laststate = conditionNone;
    trigger = true;

    Screen('FillRect', windowPtr, gray);

	fixRect=CenterRectOnPointd([0 0 fixRadius*2 fixRadius*2],centerX,centerY)
    Screen('FillOval', windowPtr, fixColor, fixRect);
    currentConditionStartTime = 0;
    currentStimulus = 1;

    %% Wait for trigger
    scan.triggerTimes = KbQueueWait;
    
    %% MAIN LOOP
    while state~=conditionEnd
        %% Flip screen and estimate time of next screen;
        vbl         = [vbl ; [Screen('Flip', windowPtr) , state, trigger]];
        t           = (vbl(end,1)-vbl(1,1));
        nextT       = (vbl(end,1)-vbl(1,1))+ifi;
        framecount  = floor((vbl(end,1) - vbl(1,1))/ifi) + 1;
        scan.vbl = vbl;

        %% Drawing commands
        switch state
            case conditionStim
                Screen('DrawTexture', windowPtr, stim1.tex(mod(framecount,stim1.numFrames)+1), [],gratingRect, 0,0);
            case conditionNone
        end

        Screen('FrameOval', windowPtr, [0  0 0],frameRect,frameLineWidthPix);
        Screen('FramePoly', windowPtr, [0 0 0],framePoly);
        Screen('FillOval',  windowPtr, [1 0 0], fixRect);

        Screen('DrawingFinished', windowPtr);

        %% Process key Input
        % Check for trigger
        [ pressed, firstPress]=KbQueueCheck;	% Collect keyboard events since KbQueueStart was invoked
        if pressed && firstPress(KbName('t'))
            scan.triggerTimes = [scan.triggerTimes firstPress(KbName('t'))];
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

        state = paradigm(min(find(paradigm(:,1) > length(scan.triggerTimes)))-1,2);
        
        if laststate == conditionStim && state ~= conditionStim
            currentStimulus = currentStimulus+1;
            disp(currentStimulus);
        end
        if isempty(state) || keyPressID(KbName('Escape'))
            state = conditionEnd;
        end

        %% Initialize new state
        if state~=laststate
            currentConditionStartTime = nextT;
        end
    end
    %% Clean up
    Priority(0);
    Screen('CloseAll');
    Screen('LoadNormalizedGammaTable', screenNumber, oldgammatable);
    ShowCursor;
    ListenChar(0);
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
    Screen('CloseAll');
    Screen('LoadNormalizedGammaTable', screenNumber, oldgammatable);
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
    ListenChar(0);
    err = lasterror;
    disp(err.stack);
    rethrow(lasterror);
end