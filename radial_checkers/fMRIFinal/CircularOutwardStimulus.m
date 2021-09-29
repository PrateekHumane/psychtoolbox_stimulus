classdef CircularOutwardStimulus < handle
   properties
       stimParams
       tex
       numFrames
   end
   methods (Access = public)
      function obj = CircularOutwardStimulus(checkerStimParams)
        if nargin==1 && isfield(checkerStimParams,'mean') ...
                     && isfield(checkerStimParams,'amplitude') ...
                     && isfield(checkerStimParams,'spatialF') ...
                     && isfield(checkerStimParams,'gratingColor') ...
                     && isfield(checkerStimParams,'gratingSpeed')
            % Passed in stim params
			obj.stimParams = checkerStimParams;
        else
            % Defualt Stim Parameters:
            obj.stimParams.mean = 0.5; % mean color
            obj.stimParams.amplitude = 0.5; % contrast
            obj.stimParams.spatialF = 0.5; %cycles per d
            obj.stimParams.gratingSpeed = 1; %deg per s
            obj.stimParams.gratingColor = 0; %black and white
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
        
        for i=1:numFrames
            phase=(i/numFrames)*2*pi;
            switch obj.stimParams.gratingColor
                case colorBlackAndWhite
                    grating = zeros([size(R), 1]);
                    grating(:,:,1) = obj.stimParams.mean * ones(size(R)) + obj.stimParams.amplitude*sin(2*pi* cyclePerPixel * R - phase*ones(size(R)));
                    % grating(:,:,2) = (R <= diameter/2); % alpha mask for circle
                case colorRedAndGreen
                    grating = zeros([size(R), 3]);
                    sinMatrix = sin(2*pi* cyclePerPixel * R - phase*ones(size(R)));
                    grating(:,:,1) = obj.stimParams.amplitude*(sinMatrix.*(sinMatrix >= 0));
                    grating(:,:,2) = obj.stimParams.amplitude*abs(sinMatrix.*(sinMatrix <= 0));                    
            end

            obj.tex(i) = Screen('MakeTexture', screenProperties.window, grating);
        end
      end
      
      function texture = getNextTexture(obj, timeProperties)
          texture = obj.tex(mod(timeProperties.framecount,obj.numFrames)+1);
      end
      
   end
end
