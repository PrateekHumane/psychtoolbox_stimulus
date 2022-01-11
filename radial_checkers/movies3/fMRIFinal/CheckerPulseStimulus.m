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
        if nargin>=1  && isfield(checkerStimParams,'mean') ...
                     && isfield(checkerStimParams,'amplitude') ...
                     && isfield(checkerStimParams,'spatialF') ...
                     && isfield(checkerStimParams,'gratingSpeed') ...
                     && isfield(checkerStimParams,'gratingColor') ...                     
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
            obj.stimParams.gratingColor = 0; %black and white            
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
		radius = diameter/2;
        [X,Y] = meshgrid(-radius(1):1:radius(1),-radius(2):1:radius(2));
        R = sqrt(X.^2+Y.^2);
        T = atan2(-Y,X);
        
        % grating colors
        colorBlackAndWhite = 0;
        colorBlueAndYellow = 1;
        colorRedAndGreen   = 2;


        % Calculation for deg/second -> frames/cycle
        % deg/second * cycles/deg * seconds/frame = cycles/frame
        % 1/cycles/frame = frames/cycle

        % number frames for one cycle
        numFrames=round(1/(obj.stimParams.gratingSpeed*obj.stimParams.spatialF*screenProperties.ifi)); % temporal period, in frames, of the drifting grating
        obj.numFrames = numFrames;
        disp('NUMBER OF FRAMES');
        disp(obj.numFrames);
        for i=1:numFrames
            phase=(i/numFrames)*2*pi;
            switch obj.stimParams.gratingColor
                case colorBlackAndWhite
                    grating = zeros([size(R), 1]);
                    grating(:,:,1) = obj.stimParams.mean * ones(size(R)) + obj.stimParams.amplitude*sin(2*pi* cyclePerPixel * R - phase*ones(size(R))) .* sin(2*pi*obj.stimParams.cyclesPerRotation/(2*pi)*T );
                    %grating(:,:,2) = (R <= diameter/2); % alpha mask for circle
                case colorRedAndGreen
                    grating = zeros([size(R), 3]);
                    sinMatrix = sin(2*pi* cyclePerPixel * R - phase*ones(size(R))) .* sin(2*pi*obj.stimParams.cyclesPerRotation/(2*pi)*T );
                    grating(:,:,1) = obj.stimParams.mean * ones(size(R)) + obj.stimParams.amplitude*(sinMatrix.*(sinMatrix >= 0))-obj.stimParams.amplitude/2*abs(sinMatrix.*(sinMatrix <= 0));
                    grating(:,:,2) = obj.stimParams.mean * ones(size(R)) + obj.stimParams.amplitude*abs(sinMatrix.*(sinMatrix <= 0))-obj.stimParams.amplitude/2*(sinMatrix.*(sinMatrix >= 0));
                    grating(:,:,3) = obj.stimParams.mean * ones(size(R)) - obj.stimParams.amplitude/2*(sinMatrix.*(sinMatrix >= 0))-obj.stimParams.amplitude/2*abs(sinMatrix.*(sinMatrix <= 0));
            end

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
      
      function createMovie(obj, movieProperties)
          moviePtr = Screen('CreateMovie', movieProperties.windowPtr, movieProperties.movieFile,movieProperties.width,movieProperties.height,movieProperties.frameRate,':CodecType=VideoCodec=x264enc speed-preset=5 bitrate=20000 profile=3');
          pulseFrames = floor(movieProperties.frameRate*obj.pulseTime)+1;
          disp(pulseFrames);
          disp(obj.pulseTime);
          for i=1:pulseFrames
            disp(i);
            disp('mod values');
            disp(mod(i,obj.numFrames));
            Screen('AddFrameToMovie', obj.tex(mod(i,obj.numFrames)+1));
          end
          for i=pulseFrames:-1:1
            disp(i);              
            Screen('AddFrameToMovie', obj.tex(mod(i,obj.numFrames)+1));
          end
          Screen('FinalizeMovie', moviePtr);
      end
      
   end
end
