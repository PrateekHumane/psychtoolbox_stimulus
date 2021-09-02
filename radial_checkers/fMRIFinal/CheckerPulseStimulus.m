classdef CheckerPulseStimulus < handle
   properties
       tex
       stimParams
       numFrames       {mustBeNumeric}
       pulseTime       {mustBeNumeric}
       lastPulseTime   {mustBeNumeric}
       phaseDirection  {mustBeNumeric}
       phaseFrameOffset {mustBeNumeric}
   end
   methods (Access = public)
      function obj = CheckerPulseStimulus(checkerStimParams, pulseTime)
        if nargin>1  && isfield(checkerStimParams,'mean') ...
                     && isfield(checkerStimParams,'amplitude') ...
                     && isfield(checkerStimParams,'spatialF') ...
                     && isfield(checkerStimParams,'gratingSpeed') ...
                     && isfield(checkerStimParams,'cyclesPerRotation')

            % Passed in stim params
            obj.stimParams = checkerStimParams;
        else
            % Defualt Stim Parameters:
            obj.stimParams.mean = 0.5; % mean color
            obj.stimParams.amplitude = 0.5; % contrast
            obj.stimParams.spatialF = 0.5; %cycles per d
            obj.stimParams.gratingSpeed = 1; %deg per s
            obj.stimParams.cyclesPerRotation = 8; % checkers in one rotation
        end
	
		if nargin==2
            % Passed in pulse time 
			obj.pulseTime = pulseTime;
		else
            % Defualt pulse time 
			obj.pulseTime = 1;
		end 
	  end

      function obj = createTextures(obj, diameter,screenProperties)

        cyclePerPixel = obj.stimParams.spatialF*screenProperties.degPerPix; %spatialF in cyclesPerDeg
        [X,Y] = meshgrid(-(diameter-1)/2:1:(diameter-1)/2);
        R = sqrt(X.^2+Y.^2);
        T = atan2(-Y,X);

        % Calculation for deg/second -> frames/cycle
        % deg/second * cycles/deg * seconds/frame = cycles/frame
        % 1/cycles/frame = frames/cycle

        % number frames for one cycle
        numFrames=round(1/(obj.stimParams.gratingSpeed*obj.stimParams.spatialF*screenProperties.ifi)); % temporal period, in frames, of the drifting grating
        obj.numFrames = numFrames;
        for i=1:numFrames
            phase=(i/numFrames)*2*pi;
            grating = zeros([size(R), 2]);
            grating(:,:,1) = obj.stimParams.mean * ones(diameter) + obj.stimParams.amplitude*sin(2*pi* cyclePerPixel * R - phase*ones(diameter)) .* sin(2*pi*obj.stimParams.cyclesPerRotation/(2*pi)*T );
            grating(:,:,2) = (R <= diameter/2); % alpha mask
            obj.tex(i) = Screen('MakeTexture', screenProperties.window, grating);
        end

        obj.lastPulseTime = 0;
        obj.phaseDirection = 1;
        obj.phaseFrameOffset = 0;
      end
      
      function texture = getNextTexture(obj, timeProperties)
          
        if obj.lastPulseTime == 0
            obj.lastPulseTime = timeProperties.t;
        end

        if timeProperties.t > obj.lastPulseTime + obj.pulseTime
			obj.phaseDirection = obj.phaseDirection * -1;
            % offset so current frame is same number while going backwards
            obj.phaseFrameOffset = timeProperties.framecount;
			obj.lastPulseTime = timeProperties.t;	
            
        end
                
        if obj.phaseDirection == 1
            texture = obj.tex(mod(timeProperties.framecount,obj.numFrames)+1);
        else
            texture = obj.tex(mod(obj.phaseFrameOffset-(timeProperties.framecount-obj.phaseFrameOffset),obj.numFrames)+1);            
        end
      end
      
   end
end
