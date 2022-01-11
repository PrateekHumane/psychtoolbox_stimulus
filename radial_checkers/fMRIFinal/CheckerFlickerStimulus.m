classdef CheckerFlickerStimulus < handle
   properties
       tex
       stimParams
       flickerFrequency {mustBeNumeric}
       lastSwitchTime   {mustBeNumeric}
       show  {mustBeNumeric}
   end
   methods (Access = public)
      function obj = CheckerFlickerStimulus(checkerStimParams,flickerFrequency)
        if nargin>=1  && isfield(checkerStimParams,'mean') ...
                     && isfield(checkerStimParams,'amplitude') ...
                     && isfield(checkerStimParams,'spatialF') ...
                     && isfield(checkerStimParams,'gratingColor') ...
                     && isfield(checkerStimParams,'cyclesPerRotation')
            % Passed in stim params
            obj.stimParams = checkerStimParams;
        else
            % Defualt Stim Parameters:
            obj.stimParams.mean = 0.5; % mean color
            obj.stimParams.amplitude = 0.5; % contrast
            obj.stimParams.spatialF = 0.5; %cycles per d
            obj.stimParams.cyclesPerRotation = 8; % checkers in one rotation
            obj.stimParams.gratingColor = 0; %black and white            
        end
        	
		if nargin==2
            % Passed in pulse time 
			obj.flickerFrequency = flickerFrequency;
		else
            % Defualt pulse time 
			obj.flickerFrequency = 1;
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
        phase=0;
        switch obj.stimParams.gratingColor
                case colorBlackAndWhite
                    grating = zeros([size(R), 1]);
                    grating(:,:,1) = obj.stimParams.mean * ones(size(R)) + obj.stimParams.amplitude*sin(2*pi* cyclePerPixel * R - phase*ones(size(R))) .* sin(2*pi*obj.stimParams.cyclesPerRotation/(2*pi)*T );
                    % grating(:,:,2) = (R <= diameter/2); % alpha mask for circle
                case colorRedAndGreen
                    grating = zeros([size(R), 3]);
                    sinMatrix = sin(2*pi* cyclePerPixel * R - phase*ones(size(R))) .* sin(2*pi*obj.stimParams.cyclesPerRotation/(2*pi)*T );
                    grating(:,:,1) = obj.stimParams.mean * ones(size(R)) + obj.stimParams.amplitude*(sinMatrix.*(sinMatrix >= 0))-obj.stimParams.amplitude/2*abs(sinMatrix.*(sinMatrix <= 0));
                    grating(:,:,2) = obj.stimParams.mean * ones(size(R)) + obj.stimParams.amplitude*abs(sinMatrix.*(sinMatrix <= 0))-obj.stimParams.amplitude/2*(sinMatrix.*(sinMatrix >= 0));
                    grating(:,:,3) = obj.stimParams.mean * ones(size(R)) - obj.stimParams.amplitude/2*(sinMatrix.*(sinMatrix >= 0))-obj.stimParams.amplitude/2*abs(sinMatrix.*(sinMatrix <= 0));
        end
        obj.tex(1) = Screen('MakeTexture', screenProperties.window, grating);

        switch obj.stimParams.gratingColor
                case colorBlackAndWhite
                    % flip contrast
                    grating(:,:,1) = obj.stimParams.mean * ones(size(R)) - obj.stimParams.amplitude*sin(2*pi* cyclePerPixel * R - phase*ones(size(R))) .* sin(2*pi*obj.stimParams.cyclesPerRotation/(2*pi)*T );
                case colorRedAndGreen
                    grating(:,:,2) = obj.stimParams.mean * ones(size(R)) + obj.stimParams.amplitude*(sinMatrix.*(sinMatrix >= 0))-obj.stimParams.amplitude/2*abs(sinMatrix.*(sinMatrix <= 0));
                    grating(:,:,1) = obj.stimParams.mean * ones(size(R)) + obj.stimParams.amplitude*abs(sinMatrix.*(sinMatrix <= 0))-obj.stimParams.amplitude/2*(sinMatrix.*(sinMatrix >= 0));
                    grating(:,:,3) = obj.stimParams.mean * ones(size(R)) - obj.stimParams.amplitude/2*(sinMatrix.*(sinMatrix >= 0))-obj.stimParams.amplitude/2*abs(sinMatrix.*(sinMatrix <= 0));
        end
        obj.tex(2) = Screen('MakeTexture', screenProperties.window, grating);
        
        obj.lastSwitchTime = 0;
        obj.show = 1;
      end
      
      function texture = getNextTexture(obj, timeProperties)
          
        if obj.lastSwitchTime == 0
            obj.lastSwitchTime = timeProperties.t;
        end

        if timeProperties.t > obj.lastSwitchTime + (1/obj.flickerFrequency)/2
			obj.show = obj.show * -1;
            % offset so current frame is same number while going backwards
			obj.lastSwitchTime = timeProperties.t;
        end
                
        if obj.show == 1
            texture = obj.tex(1);
        else
            texture = obj.tex(2);     
        end
      end
      
   end
end
