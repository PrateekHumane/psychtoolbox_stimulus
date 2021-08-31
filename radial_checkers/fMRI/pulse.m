function scan = fMRIConcentricCircleGratings(comment, paradigmNumber)

Screen('Preference', 'SkipSyncTests', 1);
%% Save input parameters
scan.comment = comment;
scan.paradigmNumber = paradigmNumber;

%% General Parameters
%Resultfile directory
resultdir = './Results';
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

pulseTime = 1; % in seconds


%% List of conditions
conditionNone           = 0;
conditionStim          = 1;
conditionEnd            = 2;

testParadigm = [
    0    conditionNone;
    3    conditionStim;
    20   conditionNone;
    21   conditionEnd;    
    ];

%% Chosse current paradigm and save it
switch paradigmNumber
    case 0
        paradigm = testParadigm;
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

	stimRadius = [screenWidth screenHeight];

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

    %% Initialize response task
    fixColor = red;
    
    %% General setup code goes here (e.g. stimulus rendering)
	frameLineWidthPix = round(pixPerDeg * frameLineWidth);
	frameBlankWidthPix = round(pixPerDeg * frameBlankWidth);
	fixRadius = round(pixPerDeg * fixRadius);
	frameHeight = (frameLineWidthPix + frameBlankWidthPix) * 3;
	
	diameter = stimRadius - frameHeight*2;
	radius = diameter/2;
	phase = 0;
	cyclePerPixel = spatialF*degPerPix; %spatialF in cyclesPerDeg
	[X,Y] = meshgrid(-radius(1):1:radius(1),-radius(2):1:radius(2));
	R = sqrt(X.^2+Y.^2);
	T = atan2(-Y,X);
	disp(diameter);
	disp(size(X));
	disp(size(R));
	% grating = zeros([size(R), 1]);
	%grating(:,:,1) =  mean * ones(diameter) + amplitude*sin(2*pi* cyclePerPixel * R ...
	%   - phase*ones(diameter) ) + 0.25*sin(2*pi*8/(2*pi)*T );
	grating =   mean * ones(size(R)) + amplitude*sin(2*pi* cyclePerPixel * R - phase*ones(size(R))) .* sin(2*pi*8/(2*pi)*T );
	
	%grating(:,:,1) =  mean * ones(diameter) + 0.25*sin(2*pi*8/(2*pi)*T );
	
	% grating(:,:,2) = (R <= diameter/2); % alpha mask
	gratingTexture = Screen('MakeTexture', windowPtr, grating);
	gratingRect = CenterRectOnPointd([0 0 diameter(1) diameter(2)],centerX,centerY);

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

	fixRect=CenterRectOnPointd([0 0 fixRadius*2 fixRadius*2],centerX,centerY);
    Screen('FillOval', windowPtr, fixColor, fixRect);
    currentConditionStartTime = 0;
	lastPulseTime = 0;
	phaseDirection = 1;

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
                Screen('DrawTexture', windowPtr, gratingTexture, [],gratingRect, 0,0);
            case conditionNone
        end
		frameRect = [];
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
		
		Screen('FrameRect', windowPtr, [0 0 0],frameRect,frameLineWidthPix);
		Screen('FramePoly', windowPtr, [0 0 0],framePoly);
		% Screen('FillOval', windowPtr, [0 0 0], fixBackRect);
		Screen('FillOval', windowPtr, [1 0 0], fixRect);

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
        phase = mod(phase+phaseDirection*ifi*gratingSpeed*pixPerDeg,2*pi); %deg/second * pix/deg
		grating =   mean * ones(size(R)) + amplitude*sin(2*pi* cyclePerPixel * R - phase*ones(size(R))) .* sin(2*pi*8/(2*pi)*T );
        gratingTexture = Screen('MakeTexture', windowPtr, grating);

        state = paradigm(min(find(paradigm(:,1) > length(scan.triggerTimes)))-1,2);
        if isempty(state) || keyPressID(KbName('Escape'))
            state = conditionEnd;
        end

		if lastPulseTime == 0
			lastPulseTime = t;
		end

		if t > lastPulseTime + pulseTime
			phaseDirection = phaseDirection * -1;
			lastPulseTime = t;	
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
